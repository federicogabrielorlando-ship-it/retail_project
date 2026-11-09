-- Pre-entrega 4: Consultas multicapa para analisis de negocio
-- Autor: Federico Orlando
--
-- Se ejecuta sobre la base retail_project de la pre-entrega 2.
-- Correr antes retail_project.sql para partir de los datos iniciales.


-- PREPARACION: TABLA CATEGORIAS Y MAS VENTAS
-- En la pre-entrega 2 la categoria era un texto dentro de productos.
-- Para esta entrega la paso a su propia tabla y la conecto con una clave foranea.

DROP TABLE IF EXISTS categorias CASCADE;

CREATE TABLE categorias (
    id_categoria  SERIAL PRIMARY KEY,
    nombre        VARCHAR(60) UNIQUE NOT NULL,
    descripcion   VARCHAR(150)
);

BEGIN;

INSERT INTO categorias (nombre, descripcion) VALUES
    ('Alimentos',  'Alimento balanceado para perros y gatos'),
    ('Accesorios', 'Collares, correas y otros accesorios'),
    ('Higiene',    'Productos de limpieza e higiene');

ALTER TABLE productos DROP COLUMN IF EXISTS id_categoria;
ALTER TABLE productos ADD COLUMN id_categoria INT REFERENCES categorias(id_categoria);

-- Asigno a cada producto el id de su categoria segun el texto que ya tenia
UPDATE productos p
SET id_categoria = cat.id_categoria
FROM categorias cat
WHERE cat.nombre = p.categoria;

-- Una clienta nueva que todavia no compro nada
INSERT INTO clientes (nombre, apellido, email, edad, ciudad, fecha_registro) VALUES
    ('Camila', 'Torres', 'camila.torres@mail.com', 29, 'CABA', '2026-10-05');

-- Ventas de octubre y noviembre (los precios de Alimentos ya tienen el aumento del 10%)
INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1, 1, 1, 49500.00, '2026-10-20'),
    (2, 4, 1, 12000.00, '2026-10-18'),
    (3, 2, 1, 41800.00, '2026-10-25'),
    (3, 6, 2,  9000.00, '2026-10-25'),
    (2, 3, 1,  8500.00, '2026-11-01'),
    (5, 6, 3,  9000.00, '2026-11-02'),
    (1, 1, 1, 49500.00, '2026-11-03'),
    (4, 5, 1,  6500.00, '2026-11-05');

COMMIT;


-- CONSULTA 1: RENTABILIDAD POR CATEGORIA
-- Problema de negocio: saber que categorias generan mas ingresos para decidir
-- donde poner el foco en compras y promociones.
-- Uno ventas, productos y categorias, sumo unidades e ingreso por categoria y
-- me quedo solo con las que superan los $50.000 vendidos. El filtro va en HAVING
-- porque se aplica sobre un resultado agregado (la suma), no sobre cada fila.

SELECT cat.nombre                            AS categoria,
       SUM(v.cantidad)                       AS unidades_vendidas,
       SUM(v.cantidad * v.precio_unitario)   AS ingreso_total
FROM ventas v
JOIN productos p    ON p.id_producto = v.id_producto
JOIN categorias cat ON cat.id_categoria = p.id_categoria
GROUP BY cat.nombre
HAVING SUM(v.cantidad * v.precio_unitario) > 50000
ORDER BY ingreso_total DESC;


-- CONSULTA 2: CLIENTES SIN COMPRAS
-- Problema de negocio: encontrar clientes que se registraron pero nunca compraron,
-- para mandarles una promocion de bienvenida.
-- El LEFT JOIN trae a todos los clientes aunque no tengan ventas. Los que no
-- compraron quedan con COUNT = 0, y con COALESCE muestro 0 en el total en lugar de NULL.

SELECT c.id_cliente,
       c.nombre,
       c.apellido,
       c.email,
       c.fecha_registro,
       COUNT(v.id_venta)                                   AS cantidad_compras,
       COALESCE(SUM(v.cantidad * v.precio_unitario), 0)    AS total_comprado
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.email, c.fecha_registro
HAVING COUNT(v.id_venta) = 0
ORDER BY c.fecha_registro;


-- CONSULTA 3: TOP DE COMPRAS POR CLIENTE
-- Problema de negocio: conocer a los mejores clientes, que producto compran mas
-- seguido y cuando fue su ultima compra, para armar ofertas personalizadas.
-- La consulta principal une clientes, ventas y productos y agrupa por cliente.
-- El producto mas comprado sale de una subconsulta que cuenta las compras de cada
-- producto para ese cliente y se queda con el primero. Si hay empate en cantidad
-- de compras, gana el de mas unidades y despues el comprado mas recientemente.
-- El ranking se ordena por el total gastado.

SELECT c.nombre || ' ' || c.apellido           AS cliente,
       COUNT(v.id_venta)                        AS cantidad_compras,
       SUM(v.cantidad * v.precio_unitario)      AS total_gastado,
       (SELECT p2.nombre
        FROM ventas v2
        JOIN productos p2 ON p2.id_producto = v2.id_producto
        WHERE v2.id_cliente = c.id_cliente
        GROUP BY p2.id_producto, p2.nombre
        ORDER BY COUNT(*) DESC, SUM(v2.cantidad) DESC, MAX(v2.fecha_venta) DESC
        LIMIT 1)                                AS producto_mas_comprado,
       COUNT(DISTINCT p.id_producto)            AS productos_distintos,
       MAX(v.fecha_venta)                       AS ultima_compra
FROM clientes c
JOIN ventas v    ON v.id_cliente = c.id_cliente
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY total_gastado DESC;
