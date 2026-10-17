# Conectar datos del negocio
El usuario metabase_app administra metadatos; NO debe utilizarse para consultar bases comerciales. Crear un usuario lector separado en cada fuente. sql/02-lector-ejemplo.sql es una plantilla, no un script para ejecutar indiscriminadamente.

Crear vistas reporting con solo campos/filas aprobados y dar SELECT explícito sobre esas vistas. No otorgar permisos de escritura, propiedad de tablas o funciones administrativas. default_transaction_read_only ayuda, pero no sustituye los grants restrictivos ni la revisión de funciones y vistas.

Añadir fuente PostgreSQL desde Administración > Bases de datos con host, puerto, DB, lector y TLS verificado. Para MySQL/MariaDB u otros motores, usar el driver nativo compatible y validar permisos equivalentes. No abrir puertos de bases al público sin una ruta de red controlada; usar VPN/allowlist cuando corresponda.

## Autorización
- Administrador técnico: configuración de instancia/conexiones.
- Analista: crear preguntas sobre fuentes aprobadas.
- Lector: consultar colecciones/paneles autorizados.

Validar con cuentas sin privilegios. No confundir permiso de colección con acceso SQL ni con filtrado de filas. Para clientes distintos, preferir instancias/fuentes separadas o vistas que materialicen el aislamiento; el paquete no implementa aislamiento multiempresa propio.

Deshabilitar acciones de escritura y carga de CSV a bases productivas salvo diseño separado. Revisar si la conexión permite ejecutar SQL nativo y qué funciones/vistas quedan accesibles. No conectar usuarios de superadministración para simplificar la instalación.

## Calidad y conciliación
Definir moneda, zona horaria, estado de venta y tratamiento de anulaciones/devoluciones antes de crear KPIs. Conciliar con un período conocido del sistema de origen. La existencia de un gráfico no prueba exactitud contable.
