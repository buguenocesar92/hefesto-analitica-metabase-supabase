#!/bin/sh
set -eu
[ "$SUPABASE_DEDICATED_CONFIRMED" = true ] || { echo 'Confirme proyecto Supabase exclusivo'; exit 1; }
[ "$SUPABASE_DATA_API_DISABLED" = true ] || { echo 'Desactive Data API y confirme variable'; exit 1; }
# La CA solo es obligatoria para verify-full; con disable/require/no-verify
# el operador la omite (DB_SSLROOTCERT vacio) y JDBC ignora sslrootcert.
if [ "$PGSSLMODE" = "verify-full" ]; then
    [ -s "$PGSSLROOTCERT" ] || { echo 'Falta certificado CA'; exit 1; }
fi
export PGCONNECT_TIMEOUT=15
psql --no-psqlrc -v ON_ERROR_STOP=1 -f /opt/hefesto/preflight.sql
