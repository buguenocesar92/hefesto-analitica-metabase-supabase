# Datos personales — Analitica (Metabase)

Contrato del kit `hefesto-analitica-metabase-supabase` bajo la **Ley 21.719** (Proteccion de Datos
Personales, Chile). Este documento es normativo para el kit: el despliegue no
se considera completo sin el.

## 1. Inventario de datos

El kit no almacena datos personales por si mismo: es la capa que **proyecta** los datos de negocio. Los paneles pueden exponer nombre, correo, telefono o documento de personas, ademas de la cache de resultados y las consultas guardadas. El kit NO administra identidad legal, nominas ni datos de salud.

## 2. Control de acceso y roles

Metabase separa por roles internos: administrador, editor de dashboard y visor. Las colecciones con datos personales deben quedar en un grupo separado, con acceso restringido. Eso es configuracion del panel, no del kit: el kit lo documenta y no lo implementa.

## 3. Minimizacion

Un panel de analitica debe mostrar agregados, no filas identificables. Por defecto se excluyen los campos identificables de los paneles. `MB_ENCRYPTION_SECRET_KEY` cifra la sesion, pero **no** sustituye la minimizacion: cifra el transporte interno, no lo que el panel muestra.

## 4. Retencion

Retencion propuesta: **90 dias** para la cache de resultados, **12 meses** para las consultas guardadas y **7 dias** para el respaldo verificado. La purga de la cache es una operacion del panel y la documenta el cliente.

## 5. Supresion, rectificacion y acceso del titular

La supresion la ejecuta el cliente: si un panel proyecta datos de una persona, esa persona debe poder exigir que se deje de mostrar, y en el caso de datos fuente, que se rectifiquen o supriman en el sistema de origen. El kit no borra datos por su cuenta.

## 6. Acceso al respaldo, auditoria y transito

El `MB_ENCRYPTION_SECRET_KEY` protege las sesiones del panel: se guarda en el gestor de secretos y nunca en el repositorio. El respaldo sale cifrado cuando hay receptor age y cada restauracion deja auditoria.

### Acceso al respaldo y transito

`DB_SSLMODE` por defecto `verify-full` con CA de Supabase. El TLS de la publicacion lo pone el proxy de Coolify.

## 7. Que NO decide el kit

Los plazos definitivos, la base legal y la incorporacion de los titulares al
registro de actividades de tratamiento son decisiones **del cliente**, no del
kit. Este documento deja la propuesta escrita y verificable; su validacion es
una tarea pendiente de coordinacion.

## 8. Verificacion

```bash
bats tests/                              # ciclo de respaldo con datos sinteticos
python3 scripts/check-env.py --modo real # contrato del .env, sin imprimir valores
python3 scripts/check_backup.py <respaldo>
```
