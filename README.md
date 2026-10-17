# Hefesto Analítica · Metabase OSS0.64.1 + Supabase
Paquete para implementar paneles e informes sobre datos de empresas, con preguntas, colecciones y visualizaciones nativas de Metabase.

## Dos bases con funciones distintas
1. **Metadatos de Metabase:** proyecto Supabase exclusivo que guarda usuarios, conexiones cifradas, preguntas y dashboards. Usa rol metabase_app con permiso para migrar su esquema.
2. **Datos del negocio:** bases de ventas/operaciones externas, conectadas posteriormente mediante usuarios de solo lectura y vistas aprobadas. El ZIP no copia ni conecta automáticamente esas bases.

Stack: imagen oficial Metabase OSS0.64.1 fijada por digest, PostgreSQL16/17 de Supabase y proxy HTTPS de Coolify. No usa H2 para guardar configuración de producción. Supabase Auth/Storage/Realtime no se integran automáticamente.

## Estado
Compatibilidad documental revisada; archivos y scripts verificados estáticamente. No se ejecutaron Metabase, migraciones, conexión Supabase ni paneles con datos reales. No hay usuarios creados, credenciales de terceros ni métricas comerciales calculadas. Validar en destino con docs/ACEPTACION.md.

## Inicio
1. Crear proyecto Supabase exclusivo y ejecutar sql/01-supabase-app.sql conforme docs/SUPABASE.md.
2. `python3 scripts/configure.py cliente-demo panel.tudominio.cl`
3. Asignar POSTGRES_PASSWORD generado al rol metabase_app; completar host/login y CA en certs/ca.crt.
4. Deshabilitar Data API y confirmar ambas variables de aislamiento en .env.
5. `docker compose -f compose.yaml -f compose.bootstrap.yaml up -d`
6. Túnel desde tu computador: `ssh -L 3000:127.0.0.1:3000 usuario@IP_DEL_VPS`.
7. Abrir http://127.0.0.1:3000, crear administrador y configurar opciones sin publicar enlaces. Seguir docs/COOLIFY.md.

Docker descarga la aplicación. El ZIP incluye configuración, SQL, respaldo/recuperación, catálogo de indicadores y un conjunto ficticio para planificar demostraciones; no incluye un dashboard ya instalado.

## Recursos y alcance
Punto inicial orientativo:2vCPU,4GB RAM para VPS con heap Java2GB; ajustar a consultas/usuarios. Supabase y bases analizadas requieren capacidad propia. Una instancia por cliente si tendrá administración independiente.

Se usa edición OSS. Funciones avanzadas de SSO, permisos por fila/columna o embedding pueden requerir otra edición/licencia; no se prometen aquí. Conservar licencia AGPL y atribuciones aplicables. Hefesto cobra implementación, modelado de indicadores, capacitación y soporte.
