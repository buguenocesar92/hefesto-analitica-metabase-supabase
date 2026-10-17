-- Solo sobre una fuente DE PRUEBAS con ventas_demo creada/importada aparte.
-- Una fila por pedido. No incluye devoluciones ni ajustes contables.
SELECT fecha, SUM(importe_neto_clp) AS ventas_demo,
       COUNT(*) AS pedidos_demo, AVG(importe_neto_clp) AS ticket_demo
FROM ventas_demo
WHERE estado = 'completado'
GROUP BY fecha
ORDER BY fecha;
-- Control esperado sobre el CSV entregado: 3 pedidos, total57000, ticket19000.
