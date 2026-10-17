# Despliegue
Completar primero bootstrap privado del README. Crear administrador con contraseña única, configurar idioma/zona horaria y revisar acceso de grupos. No añadir datos reales antes de validar permisos.

1. Detener bootstrap con `docker compose -f compose.yaml -f compose.bootstrap.yaml down` (no borrar recursos).
2. Subir archivos versionables a repositorio privado, sin .env/backups.
3. Crear recurso Compose con compose.yaml; completar variables reales desde .env.
4. Montar certs/ca.crt en el directorio del recurso. La CA no es una clave privada; puede distribuirse por el repositorio privado si se decide. Mantener ops/ disponible.
5. Asignar https://panel.cliente.cl al servicio metabase, puerto3000. No publicar preflight/dbtools ni override bootstrap.
6. Desplegar: preflight debe terminar correctamente y /api/health alcanzar estado sano. Confirmar que no reaparece setup y que la URL externa es correcta.

Configurar SMTP desde administración nativa si se requieren invitaciones/recuperación/reportes por correo. No se configura proveedor ni se envían mensajes desde este ZIP. Probar con destinatario autorizado antes de activar suscripciones.

Desactivar compartir públicamente y embedding hasta decidir alcance. Revisar permisos del grupo general/todos y de colecciones. Un enlace público no proporciona aislamiento entre clientes. No prometer seguridad por fila de planes pagados dentro de OSS.

No se incluyen drivers externos ni personalizaciones en /plugins. Si se añaden, versionarlos, registrar procedencia/licencia y respaldar archivos de forma independiente. Las conexiones SQL y certificados de cada fuente requieren permisos/red propios.
