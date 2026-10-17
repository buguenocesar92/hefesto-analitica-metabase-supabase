-- Plantilla para la BASE DE NEGOCIO, NO para metadatos Metabase.
-- Revisar con su administrador antes de ejecutar.
-- Supone base llamada postgres y esquema reporting con vistas aprobadas.
CREATE ROLE hefesto_bi_reader LOGIN;
GRANT CONNECT ON DATABASE postgres TO hefesto_bi_reader;
GRANT USAGE ON SCHEMA reporting TO hefesto_bi_reader;
-- Sustituir por vistas concretas previamente revisadas:
-- GRANT SELECT ON reporting.ventas_resumen TO hefesto_bi_reader;
-- GRANT SELECT ON reporting.inventario_resumen TO hefesto_bi_reader;
ALTER ROLE hefesto_bi_reader SET default_transaction_read_only=on;
-- Asignar clave por psql: \password hefesto_bi_reader
-- No otorgar INSERT/UPDATE/DELETE, propiedad de tablas ni rol privilegiado.
-- El modo read_only no reemplaza permisos restrictivos ni revision de funciones/vistas.
