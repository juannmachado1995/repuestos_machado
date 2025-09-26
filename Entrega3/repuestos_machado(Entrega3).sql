-- Casos de prueba
-- 1. Registrar una compra del cliente con id = 6
--  que va a compra 2 unidades del producto con id = 3 
CALL registrar_compra(6, 3, 2);

SELECT * FROM compras WHERE id_cliente = 6 ORDER BY fecha_compra DESC LIMIT 1;

--  Verificar el detalle de la compra en detalle_compras
SELECT * FROM detalle_compras WHERE id_compra = (SELECT MAX(id) FROM compras WHERE id_cliente = 6);

-- Usar la vista para ver el resumen
SELECT * FROM vista_detalle_compras WHERE cliente = 'Lucía Morales' ORDER BY fecha_compra DESC;

-- Caso prueba num 2 
-- Calcular el gasto total de un cliente con id = 2
SELECT gasto_total_cliente(2) AS gasto_total_maria;

-- Verificar el producto más vendido
SELECT producto_mas_vendido() AS producto_top;

--  Ver los 5 productos más vendidos y su facturación
CALL top_productos_vendidos(5);

-- Ver el gasto acumulado de todos los clientes
SELECT * FROM vista_clientes_gastos ORDER BY gasto_total DESC;

-- Caso de prueba num3
-- Ver el historial de compras del cliente con id = 1 
CALL historial_cliente(1);

SELECT * 
FROM vista_detalle_compras 
WHERE cliente = 'Juan Pérez'
ORDER BY fecha_compra DESC;


