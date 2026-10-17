# Base de aplicación
Usar un proyecto NUEVO exclusivo para Metabase, en región cercana al VPS y con PostgreSQL16/17. No usar la base de Chatwoot, Moodle ni otra app. Deshabilitar Data API; las tablas contienen configuración sensible y no deben exponerse al navegador.

Ejecutar sql/01-supabase-app.sql como postgres en SQL Editor. El script exige public vacío y crea rol metabase_app sin contraseña pública. Después de generar .env, asignar el valor POSTGRES_PASSWORD al rol mediante psql administrativo con `\password metabase_app`. No pegar claves en repositorios ni usar postgres como conexión habitual de Metabase.

Conectar directamente al host de Supabase, puerto5432, base postgres, usuario metabase_app. Si solo hay IPv4, usar pooler en modo SESSION5432 con el nombre metabase_app.PROJECT_REF indicado para el proyecto. Evitar modo transacción6543 para migraciones y sesiones persistentes.

Guardar CA válida para el hostname en certs/ca.crt. Tanto JDBC como herramientas usan verify-full. No se necesita pgvector para este paquete. El preflight comprueba rol, permisos, versión y estado del esquema. Las variables de confirmación son declaraciones del operador: no consultan el estado de Data API por API administrativa.

Metabase ejecuta sus migraciones de metadatos al arrancar; permitir una sola instancia durante preparación/actualización. No cambiar nombres/tablas manualmente. Si hay migración parcial y preflight falla, diagnosticar y recuperar respaldo; no borrar public ni desactivar comprobaciones sin revisar.

Conservar MB_ENCRYPTION_SECRET_KEY: cifra credenciales de fuentes guardadas en la base. Sin ella, un dump puede resultar insuficiente para recuperar conexiones. No regenerarla al mover el servicio.

Configurar límites de conexiones y capacidad según el plan; revisar concurrencia del panel, sincronización de fuentes y tareas. No asumir disponibilidad continua o retención de backups de un plan sin verificar sus condiciones.
