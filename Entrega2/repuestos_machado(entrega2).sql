-- ENTREGA N° 2

CREATE VIEW vista_detalle_compras AS
SELECT 
    c.id AS id_compra,
    cl.nombre AS cliente,
    p.nombre AS producto,
    dc.cantidad,
    dc.precio_unitario,
    dc.subtotal,
    c.total,
    c.fecha_compra
FROM detalle_compras dc
JOIN compras c ON dc.id_compra = c.id
JOIN productos p ON dc.id_producto = p.id
JOIN clientes cl ON c.id_cliente = cl.id;

CREATE VIEW vista_clientes_gastos AS
SELECT 
    cl.id AS id_cliente,
    cl.nombre,
    cl.telefono,
    SUM(c.total) AS gasto_total
FROM clientes cl
LEFT JOIN compras c ON cl.id = c.id_cliente
GROUP BY cl.id, cl.nombre, cl.telefono;

CREATE VIEW vista_productos_vendidos AS
SELECT 
    p.id AS id_producto,
    p.nombre,
    SUM(dc.cantidad) AS total_vendido,
    SUM(dc.subtotal) AS ingresos_generados
FROM productos p
LEFT JOIN detalle_compras dc ON p.id = dc.id_producto
GROUP BY p.id, p.nombre
ORDER BY total_vendido DESC;

SELECT * FROM vista_detalle_compras;
SELECT * FROM vista_clientes_gastos;
SELECT * FROM vista_productos_vendidos;

-- funciones 
DELIMITER //
CREATE FUNCTION calcular_total_producto (id_prod INT, cantidad_compra INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE precio_unitario INT;
    DECLARE total INT;

    SELECT precio INTO precio_unitario
    FROM productos
    WHERE id = id_prod;

    SET total = precio_unitario * cantidad_compra;

    RETURN total;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION gasto_total_cliente (id_cli INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE gasto_total INT;

    SELECT IFNULL(SUM(total), 0) INTO gasto_total
    FROM compras
    WHERE id_cliente = id_cli;

    RETURN gasto_total;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION producto_mas_vendido ()
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE nombre_producto VARCHAR(50);

    SELECT p.nombre
    INTO nombre_producto
    FROM productos p
    JOIN detalle_compras dc ON p.id = dc.id_producto
    GROUP BY p.id, p.nombre
    ORDER BY SUM(dc.cantidad) DESC
    LIMIT 1;

    RETURN nombre_producto;
END;
//
DELIMITER ;

-- sttore procedure

DELIMITER //
CREATE PROCEDURE registrar_compra (
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE nueva_compra INT;

    -- Inserto en compras
    INSERT INTO compras (id_cliente, fecha_compra, total) VALUES (p_id_cliente, NOW(), 0);
    SET nueva_compra = LAST_INSERT_ID();

    -- Inserto en detalle_compras
    INSERT INTO detalle_compras (id_compra, id_producto, cantidad)
    VALUES (nueva_compra, p_id_producto, p_cantidad);
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE historial_cliente (IN p_id_cliente INT)
BEGIN
    SELECT 
        c.id AS id_compra,
        c.fecha_compra,
        p.nombre AS producto,
        dc.cantidad,
        dc.precio_unitario,
        dc.subtotal,
        c.total
    FROM compras c
    JOIN detalle_compras dc ON c.id = dc.id_compra
    JOIN productos p ON dc.id_producto = p.id
    WHERE c.id_cliente = p_id_cliente
    ORDER BY c.fecha_compra DESC;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE top_productos_vendidos (IN limite INT)
BEGIN
    SELECT 
        p.id AS id_producto,
        p.nombre,
        SUM(dc.cantidad) AS total_vendido,
        SUM(dc.subtotal) AS ingresos_generados
    FROM productos p
    JOIN detalle_compras dc ON p.id = dc.id_producto
    GROUP BY p.id, p.nombre
    ORDER BY total_vendido DESC
    LIMIT limite;
END;
//
DELIMITER ;