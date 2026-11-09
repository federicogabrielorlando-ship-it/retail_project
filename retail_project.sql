-- Pre-entrega 2: Tablas principales con restricciones y datos iniciales
-- Proyecto retail (tienda PetStop)
-- Autor: Federico Orlando


-- 1. CREACION DE LA BASE DE DATOS

CREATE DATABASE retail_project;

-- Me conecto a la base nueva (comando de psql).
-- En pgAdmin o DBeaver: ejecutar solo la linea anterior, abrir una consulta
-- conectada a retail_project y correr desde aca para abajo.
\c retail_project


-- 2. DDL: ESTRUCTURA DE LAS TABLAS

-- Borro las tablas si ya existen, asi el script se puede correr mas de una vez.
-- Primero ventas porque depende de las otras dos.
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- Clientes de la tienda
CREATE TABLE clientes (
    id_cliente      SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    edad            INT CHECK (edad >= 18),          -- solo clientes mayores de edad
    ciudad          VARCHAR(80),
    fecha_registro  DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Productos que se venden
CREATE TABLE productos (
    id_producto  SERIAL PRIMARY KEY,
    nombre       VARCHAR(120) NOT NULL,
    categoria    VARCHAR(60) NOT NULL,
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),   -- no hay precios en cero ni negativos
    stock        INT NOT NULL DEFAULT 0 CHECK (stock >= 0)    -- el stock no puede quedar negativo
);

-- Ventas: se crea al final porque tiene claves foraneas a clientes y productos
CREATE TABLE ventas (
    id_venta         SERIAL PRIMARY KEY,
    id_cliente       INT NOT NULL REFERENCES clientes(id_cliente),
    id_producto      INT NOT NULL REFERENCES productos(id_producto),
    cantidad         INT NOT NULL CHECK (cantidad > 0),             -- minimo 1 unidad
    precio_unitario  DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    fecha_venta      DATE NOT NULL DEFAULT CURRENT_DATE
);


-- 3. DML: CARGA INICIAL DE DATOS
-- Todo dentro de una transaccion: si falla un insert no se guarda nada.

BEGIN;

INSERT INTO clientes (nombre, apellido, email, edad, ciudad, fecha_registro) VALUES
    ('Lucia',    'Fernandez', 'lucia.fernandez@mail.com',  34, 'CABA',         '2026-08-03'),
    ('Martin',   'Gomez',     'martin.gomez@mail.com',     41, 'La Plata',     '2026-08-10'),
    ('Sofia',    'Ramirez',   'sofia.ramirez@mail.com',    27, 'CABA',         '2026-08-21'),
    ('Diego',    'Sosa',      'diego.sosa@mail.com',       52, 'Quilmes',      '2026-09-02'),
    ('Valentina','Acosta',    'valentina.acosta@mail.com', 23, 'Avellaneda',   '2026-09-15'),
    ('Pablo',    'Herrera',   'pablo.herrera@mail.com',    38, 'Lomas de Zamora', '2026-09-28');

INSERT INTO productos (nombre, categoria, precio, stock) VALUES
    ('Alimento perro adulto 15 kg', 'Alimentos',  45000.00, 20),
    ('Alimento gato adulto 7,5 kg', 'Alimentos',  38000.00, 15),
    ('Collar regulable mediano',    'Accesorios',  8500.00, 30),
    ('Correa extensible 5 m',       'Accesorios', 12000.00, 12),
    ('Shampoo antipulgas 500 ml',   'Higiene',     6500.00, 25),
    ('Piedras sanitarias 4 kg',     'Higiene',     9000.00, 40);

INSERT INTO ventas (id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1, 1, 1, 45000.00, '2026-09-05'),
    (2, 3, 2,  8500.00, '2026-09-12'),
    (3, 2, 1, 38000.00, '2026-09-20'),
    (1, 5, 3,  6500.00, '2026-10-01'),
    (4, 4, 1, 12000.00, '2026-10-08'),
    (5, 6, 2,  9000.00, '2026-10-15'),
    (6, 1, 1, 45000.00, '2026-10-22');   -- venta de prueba, se borra en el punto 5

COMMIT;


-- 4. UPDATE: AUMENTO DE PRECIOS DE UNA CATEGORIA
-- Subo un 10% los productos de Alimentos.
-- Antes miro con un SELECT cuales son las filas que se van a modificar.

SELECT id_producto, nombre, precio
FROM productos
WHERE categoria = 'Alimentos';

BEGIN;

UPDATE productos
SET precio = ROUND(precio * 1.10, 2)
WHERE categoria = 'Alimentos';

COMMIT;


-- 5. DELETE: BORRADO DE UNA VENTA ESPECIFICA
-- Elimino la venta de prueba (id_venta = 7). Filtro por la clave primaria
-- para no tocar ninguna otra fila.

SELECT * FROM ventas WHERE id_venta = 7;

BEGIN;

DELETE FROM ventas
WHERE id_venta = 7;

COMMIT;


-- 6. CONTROL FINAL

SELECT COUNT(*) AS total_clientes FROM clientes;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT COUNT(*) AS total_ventas FROM ventas;
SELECT nombre, categoria, precio FROM productos ORDER BY id_producto;
