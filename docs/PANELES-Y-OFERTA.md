# Catálogo inicial de indicadores
| Panel | Indicadores propuestos | Datos necesarios |
|---|---|---|
| Comercial | Ventas netas, cantidad de pedidos, ticket promedio | Pedidos, estados, montos, devoluciones |
| Inventario | Unidades disponibles, bajo mínimo, antigüedad | Existencias, mínimos y movimientos |
| Atención | Conversaciones entrantes, resueltas, tiempo de respuesta | Eventos/timestamps y responsables |
| Reservas | Horas reservadas, cancelaciones, utilización | Agenda, estados y capacidad disponible |

Son propuestas de configuración; no dashboards preinstalados ni integraciones activas. Usar solo indicadores que los datos permitan calcular. Ticket promedio requiere definición de pedido válido; utilización requiere capacidad, no solo cantidad de citas.

## Flujo de implementación
Inventariar fuentes → definir diccionario KPI → obtener acceso lector → crear vistas/modelos → construir preguntas y panel → conciliar resultados → asignar permisos → capacitar → revisar mensualmente.

El CSV de ejemplos es ficticio. Usarlo en una fuente de pruebas separada; no insertarlo en el esquema de metadatos ni presentarlo como ventas reales. Las consultas de examples asumen una tabla/vista creada en esa fuente de pruebas y requieren adaptación.

## Oferta comercial
Cobrar levantamiento, conexión/modelado, cantidad de paneles/indicadores, capacitación y mantenimiento. Separar limpieza histórica y cambios de API/esquema como alcance adicional. Definir frecuencia de actualización y latencia; no anunciar tiempo real sin medir toda la cadena.

No incluye licencia Pro/Enterprise, SSO avanzado, embedding comercial contratado, sincronización Odoo, RAG o agente IA. Revisar términos de licencia antes de ofrecer marca blanca/embedding a terceros.
