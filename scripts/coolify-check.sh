#!/usr/bin/env bash
# Valida que compose.yaml cumpla el contrato de Coolify para este repo
# (rama coolify). Falla con exit != 0 y un mensaje "servicio: motivo"
# por cada incumplimiento. No usa secretos: los valores del .env temporal
# son ficticios.
#
# Uso: bash scripts/coolify-check.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/compose.yaml"
PROJECT_DIR="${REPO_ROOT}"
DB_KIND="supabase-pg"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
    echo "No existe ${COMPOSE_FILE}" >&2
    exit 1
fi

# Variables ${VAR} y ${VAR:?msg} que aparecen en el compose.
mapfile -t VARS < <(grep -oE '\$\{[A-Z_][A-Z0-9_]*(:[?]?[^}]*)?\}' "${COMPOSE_FILE}" \
    | sed -E 's/^\$\{([^:}]+).*/\1/' | sort -u)

TMP_ENV="$(mktemp)"
trap 'rm -f "${TMP_ENV}"' EXIT

# Genera .env temporal con valores ficticios. POSTGRES_HOST y BI_HOST
# reciben un placeholder de host. El resto recibe un token opaco.
> "${TMP_ENV}"
for v in "${VARS[@]}"; do
    case "${v}" in
        POSTGRES_HOST|BI_HOST)
            printf '%s=https://ejemplo.invalid\n' "${v}" >> "${TMP_ENV}"
            ;;
        *)
            printf '%s=x1234567890abcdef\n' "${v}" >> "${TMP_ENV}"
            ;;
    esac
done

# supabase-pg: forzar DB_SSLMODE=disable (sin verify-full ni ca.crt)
# y DB_NAME=mvp_prueba para validar la parametrizacion.
printf 'DB_SSLMODE=disable\n' >> "${TMP_ENV}"
printf 'DB_NAME=mvp_prueba\n' >> "${TMP_ENV}"

# Renderiza el compose con Docker Compose.
RENDER_JSON="$(docker compose --project-directory "${PROJECT_DIR}" \
    -f "${COMPOSE_FILE}" --env-file "${TMP_ENV}" \
    config --format json)"

ERRORS=()

# --- Texto del compose ---

# name raiz: solo permitido como ${VAR:-default}. Un literal o un
# ${VAR:?...} fijan el proyecto y bloquean a Coolify.
if grep -nE '^name:' "${COMPOSE_FILE}" > /dev/null 2>&1 \
   && ! grep -nE '^name:[[:space:]]*\$\{[A-Za-z_][A-Za-z0-9_]*:-[^}]*\}' "${COMPOSE_FILE}" > /dev/null 2>&1; then
    LINE="$(grep -nE '^name:' "${COMPOSE_FILE}" | head -n1)"
    ERRORS+=("raiz: tiene name: literal o con \${VAR:?...} (${LINE}); Coolify no puede sobrescribir el nombre del proyecto")
fi

# Volumenes top-level con name: fijo (no Coolify lo controla).
if awk '/^volumes:/{flag=1; next} flag && /^[a-zA-Z]/{flag=0} flag' "${COMPOSE_FILE}" \
   | grep -nE '^[[:space:]]+name:[[:space:]]*[^$[:space:]#]' > /dev/null 2>&1; then
    LINE="$(awk '/^volumes:/{flag=1; next} flag && /^[a-zA-Z]/{flag=0} flag' "${COMPOSE_FILE}" \
        | grep -nE '^[[:space:]]+name:' | head -n1)"
    ERRORS+=("volumen: tiene name: literal (${LINE}); Coolify no controla el nombre del volumen")
fi

# Redes top-level con name: fijo (no Coolify lo controla).
if awk '/^networks:/{flag=1; next} flag && /^[a-zA-Z]/{flag=0} flag' "${COMPOSE_FILE}" \
   | grep -nE '^[[:space:]]+name:[[:space:]]*[^$[:space:]#]' > /dev/null 2>&1; then
    LINE="$(awk '/^networks:/{flag=1; next} flag && /^[a-zA-Z]/{flag=0} flag' "${COMPOSE_FILE}" \
        | grep -nE '^[[:space:]]+name:' | head -n1)"
    ERRORS+=("red: tiene name: literal (${LINE}); Coolify no controla el nombre de la red")
fi

# --- Render JSON: servicios sin profiles (los que aparecen) ---

mapfile -t SERVICES < <(echo "${RENDER_JSON}" | jq -r '.services | keys[]')

for svc in "${SERVICES[@]}"; do
    SVC_JSON="$(echo "${RENDER_JSON}" | jq -c ".services.\"${svc}\"")"

    # ports: solo expose + Traefik publica el dominio.
    PORTS_LEN="$(echo "${SVC_JSON}" | jq -r '.ports // [] | length')"
    if [[ "${PORTS_LEN}" != "0" ]]; then
        ERRORS+=("${svc}: expone ports=${PORTS_LEN}; debe usar expose y Traefik publica el dominio")
    fi

    # container_name: lo asigna Coolify por proyecto.
    if echo "${SVC_JSON}" | jq -e 'has("container_name")' > /dev/null 2>&1; then
        ERRORS+=("${svc}: usa container_name fijo; Coolify asigna el nombre por proyecto")
    fi

    # privileged/cap_add/devices.
    if [[ "$(echo "${SVC_JSON}" | jq -r '.privileged // false')" == "true" ]]; then
        ERRORS+=("${svc}: usa privileged: true")
    fi
    if echo "${SVC_JSON}" | jq -e 'has("cap_add")' > /dev/null 2>&1; then
        ERRORS+=("${svc}: usa cap_add")
    fi
    if echo "${SVC_JSON}" | jq -e 'has("devices")' > /dev/null 2>&1; then
        ERRORS+=("${svc}: usa devices")
    fi

    # network_mode / pid / ipc host.
    NM="$(echo "${SVC_JSON}" | jq -r '.network_mode // ""')"
    [[ "${NM}" == "host" ]] && ERRORS+=("${svc}: usa network_mode: host")
    PV="$(echo "${SVC_JSON}" | jq -r '.pid // ""')"
    [[ "${PV}" == "host" ]] && ERRORS+=("${svc}: usa pid: host")
    IV="$(echo "${SVC_JSON}" | jq -r '.ipc // ""')"
    [[ "${IV}" == "host" ]] && ERRORS+=("${svc}: usa ipc: host")

    # security_opt unconfined (seccomp:unconfined, seccomp=unconfined, apparmor:unconfined).
    if echo "${SVC_JSON}" | jq -r '.security_opt // [] | .[]' 2>/dev/null \
       | grep -qE '(^|[:=])unconfined$'; then
        ERRORS+=("${svc}: usa security_opt unconfined")
    fi

    # Volumes: docker.sock o absoluto fuera del repo no permitidos.
    # Docker convierte './certs' a path absoluto bajo REPO_ROOT; eso es valido.
    while IFS=$'\n' read -r src; do
        [[ -z "${src}" ]] && continue
        case "${src}" in
            /var/run/docker.sock) ERRORS+=("${svc}: monta docker.sock") ;;
            /*)
                case "${src}" in
                    "${REPO_ROOT}"/*) ;;
                    *) ERRORS+=("${svc}: bind absoluto fuera del repo: ${src}") ;;
                esac
                ;;
        esac
    done < <(echo "${SVC_JSON}" | jq -r '.volumes // [] | .[] | (.source // "")')
done

# --- supabase-pg: DB_NAME=mvp_prueba y DB_SSLMODE=disable en render ---

if [[ "${DB_KIND}" == "supabase-pg" ]]; then
    RENDER_STRINGS="$(echo "${RENDER_JSON}" \
        | jq -r '.. | objects | to_entries[] | .value | strings')"

    if ! grep -qx 'mvp_prueba' <(echo "${RENDER_STRINGS}"); then
        ERRORS+=("supabase-pg: DB_NAME=mvp_prueba no aparece en el render; PGDATABASE/MB_DB_CONNECTION_URI no lo leen")
    fi

    # disable puede aparecer como sslmode=disable, PGSSLMODE=disable, etc.
    if ! grep -Eq '(^|[^A-Za-z0-9])disable([^A-Za-z0-9]|$)' <(echo "${RENDER_STRINGS}"); then
        ERRORS+=("supabase-pg: DB_SSLMODE=disable no aparece en el render; sslmode/PGSSLMODE esta fijo en verify-full")
    fi
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
    echo "FAIL coolify-check:"
    for e in "${ERRORS[@]}"; do
        echo "  ${e}"
    done
    exit 1
fi

echo "OK coolify-check: contrato cumplido"
exit 0