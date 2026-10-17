# Respaldos
`python3 scripts/backup.py` detiene Metabase, exporta public de la base de aplicación, guarda .env/Compose y checksums, e intenta reiniciar. Requiere contexto Compose correcto y Python3.11+. Revisar manifest completed y estado del servicio. No respalda bases comerciales ni complementos personalizados.

Guardar ZIP/repositorio completo, CA y claves junto a copia cifrada fuera del VPS. No se automatiza cifrado, cron, almacenamiento remoto ni retención. El dump contiene configuración sensible aunque las contraseñas de fuentes estén cifradas. Conservar MB_ENCRYPTION_SECRET_KEY original.

## Restaurar
1. Preparar proyecto Supabase nuevo/vacío con SQL inicial y rol. No arrancar Metabase antes de importar.
2. Recuperar configuración original, conservando clave de cifrado. Ajustar conexión, CA y proyecto Compose para aislar destino.
3. Verificar manifest/checksums y ejecutar `python3 scripts/restore_db.py /ruta/respaldo`.
4. El script exige base vacía y omite crear el esquema public ya existente. No usa DROP/--clean. Si falla parcialmente, diagnosticar y repetir en otro destino vacío.
5. Abrir por bootstrap privado; comprobar usuarios, preguntas, paneles, permisos y conexiones. En pruebas, restringir salida a SMTP y a fuentes reales para evitar tareas/notificaciones inesperadas.
6. Publicar URL definitiva tras verificar. En migración real detener origen, respaldar estado final y cambiar DNS de forma controlada.

Actualizar solo después de leer notas oficiales y probar restauración/migración en staging. Volver a imagen anterior puede requerir restaurar la base compatible, no solo cambiar tag.

## Entrega
Transferir proyecto Supabase o restaurar en uno del cliente, repo, VPS/Coolify, dominio, versiones/digest, CA, secreto de cifrado, claves DB, administrador, conexiones lectoras, catálogo KPI y respaldo probado. Secretos aparte mediante gestor seguro. Registrar propietario de cada fuente y soporte.

Exportar un dashboard no sustituye el respaldo de Metabase. Pasar a otra herramienta BI requiere reconstruir o mapear modelos/preguntas/permisos; no hay conversor universal a Odoo incluido.
