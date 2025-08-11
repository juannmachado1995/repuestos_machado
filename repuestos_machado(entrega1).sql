-- creacion y uso de la nueva bbdd
CREATE DATABASE repuestos_machado;
USE repuestos_machado;

-- ´primera tabla de productos
CREATE TABLE IF NOT EXISTS productos (
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    nombre VARCHAR(40),
    precio INT (20),
    cantidad INT(10)
    );
    
-- lista aleatoria de productos
INSERT INTO productos (nombre, precio, cantidad) VALUES
('Filtro de aceite', 2500, 15),
('Filtro de aire', 3200, 20),
('Bujía de encendido', 800, 35),
('Pastillas de freno delanteras', 9500, 12),
('Pastillas de freno traseras', 8800, 10),
('Disco de freno delantero', 15000, 8),
('Disco de freno trasero', 14000, 7),
('Amortiguador delantero', 28000, 5),
('Amortiguador trasero', 24000, 6),
('Correa de distribución', 6000, 18),
('Batería 12V', 45000, 4),
('Radiador', 32000, 3),
('Alternador', 70000, 2),
('Bomba de agua', 18000, 9),
('Bomba de combustible', 25000, 7),
('Espejo retrovisor izquierdo', 5000, 14),
('Espejo retrovisor derecho', 5000, 14),
('Paragolpes delantero', 40000, 3),
('Paragolpes trasero', 40000, 3),
('Farol delantero izquierdo', 16000, 6),
('Farol delantero derecho', 16000, 6),
('Farol trasero izquierdo', 9000, 8),
('Farol trasero derecho', 9000, 8),
('Parabrisas', 35000, 2),
('Ventana lateral', 15000, 5),
('Llanta de aleación', 25000, 10),
('Cubierta 195/65 R15', 20000, 12),
('Kit de embrague', 40000, 3),
('Palanca de cambios', 8000, 6),
('Volante', 12000, 5);

-- ahora hacemos una tabla donde guardaremos todos los clientes 
CREATE TABLE IF NOT EXISTS clientes (
 id INT PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
 nombre VARCHAR(30),
 direccion VARCHAR(40),
 telefono VARCHAR(20) UNIQUE
);

-- guardamos lsta de clientes con usuarios y datos.
INSERT INTO clientes (nombre, direccion, telefono) VALUES
('Juan Pérez', 'Av. Siempre Viva 123', '3512456789'),
('María López', 'Calle San Martín 456', '3419876543'),
('Carlos Gómez', 'Belgrano 789', '2614567890'),
('Laura Fernández', 'Mitre 101', '3812345678'),
('Diego Ramírez', 'Av. Rivadavia 202', '2999876543'),
('Lucía Morales', 'Calle Córdoba 333', '3516547890'),
('Federico Castro', 'San Juan 55', '3871234567'),
('Ana Gutiérrez', 'Av. Colón 1200', '3434567890'),
('Martín Herrera', 'Urquiza 876', '3882345678'),
('Sofía Díaz', 'Calle Mendoza 540', '3629876543'),
('Pablo Álvarez', 'Lavalle 444', '2643456789'),
('Valentina Torres', 'Corrientes 999', '3798765432'),
('Gabriel Méndez', 'Av. Libertad 150', '3819876543'),
('Camila Ruiz', 'Saavedra 220', '3541234567'),
('Rodrigo Vargas', 'Catamarca 300', '2618765432');

/* elimino columna cantidad porque en mi idea original queria que cuando
un cliente hace una comra baje la cantidad, pero complica todo el proceso
y prefiero hacerlo mas simple para comienzo */
ALTER TABLE productos DROP COLUMN cantidad ;


-- tabla intermedia de compra/clientes 
CREATE TABLE compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    total INT(10),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);
-- tabla donde guardo detalle de lo que cada cleinte compra

CREATE TABLE detalle_compras (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario INT,
    subtotal INT GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    FOREIGN KEY (id_compra) REFERENCES compras(id),
    FOREIGN KEY (id_producto) REFERENCES productos(id)
);
-- ahroa necesito calcular el valor total de la compra con precio de cada producto
DELIMITER //
CREATE TRIGGER precio_total_compra
AFTER INSERT ON detalle_compras
FOR EACH ROW
BEGIN
    UPDATE compras
    SET total = (
        SELECT SUM(subtotal)
        FROM detalle_compras
        WHERE id_compra = NEW.id_compra
    )
    WHERE id = NEW.id_compra;
END;
//

DELIMITER ;
-- trigger para setear correctamente el precio de los productos 
DELIMITER //
CREATE TRIGGER setar_precio_unitario BEFORE INSERT ON detalle_compras
FOR EACH ROW
BEGIN
    IF NEW.precio_unitario IS NULL OR NEW.precio_unitario = 0 THEN
        SET NEW.precio_unitario = (SELECT precio FROM productos WHERE id = NEW.id_producto);
    END IF;
END;
//
DELIMITER ;

-- agregamos varias compras aleatorias con distintas fechas
INSERT INTO compras (id_cliente, fecha_compra) VALUES
(1, '2025-07-01 10:00:00'),
(2, '2025-07-02 15:30:00'),
(3, '2025-07-03 09:45:00'),
(4, '2025-07-04 14:20:00'),
(5, '2025-07-05 18:00:00');

INSERT INTO detalle_compras (id_compra, id_producto, cantidad) VALUES
(1, 1, 2),
(1, 11, 1),
(2, 5, 1),
(2, 7, 2),
(3, 20, 4),
(3, 28, 1),
(4, 3, 6),
(4, 9, 2),
(5, 13, 1),
(5, 22, 1);
--
SELECT * FROM compras;
SELECT * FROM clientes;
SHOW TRIGGERS LIKE 'detalle_compras';