-- Pre-entrega 3: Manejando valores ausentes con IS NULL y COALESCE
-- Autor: Federico Orlando
--
-- Ejecutar en una base de prueba aparte (no en retail_project, que ya tiene
-- otra tabla productos con columnas distintas).


-- DATOS DE PRUEBA
-- Tabla productos con nulos en distintas columnas para probar las consultas.

DROP TABLE IF EXISTS productos;

CREATE TABLE productos (
    nombre                 VARCHAR(100),
    precio_lista           NUMERIC(10,2),
    descuento_promocional  NUMERIC(10,2),
    categoria              VARCHAR(50)
);

INSERT INTO productos (nombre, precio_lista, descuento_promocional, categoria) VALUES
    ('Alimento perro 15 kg',  45000.00, 4500.00, 'Alimentos'),
    ('Alimento gato 7,5 kg',  38000.00, NULL,    'Alimentos'),
    ('Collar regulable',       8500.00, 500.00,  NULL),
    ('Correa extensible',     12000.00, NULL,    'Accesorios'),
    ('Shampoo antipulgas',     NULL,    300.00,  'Higiene'),
    ('Rascador para gatos',    NULL,    NULL,    NULL);


-- Consulta 1: productos que no tienen una categoria asignada
-- Se usa IS NULL porque categoria = NULL nunca da verdadero.
SELECT nombre, precio_lista, descuento_promocional, categoria
FROM productos
WHERE categoria IS NULL;


-- Consulta 2: reporte de precios para el cliente
-- Si el precio de lista es NULL se muestra 0.
SELECT nombre,
       COALESCE(precio_lista, 0) AS precio_final
FROM productos;


-- Consulta 3: limpieza de categorias
-- Las categorias vacias se muestran como 'Sin Categorizar'.
SELECT nombre,
       COALESCE(categoria, 'Sin Categorizar') AS categoria
FROM productos;


-- Consulta 4: calculo de descuentos
-- Si no hay descuento se toma como 0, asi la resta no da NULL.
SELECT nombre,
       precio_lista,
       descuento_promocional,
       precio_lista - COALESCE(descuento_promocional, 0)
           AS precio_con_descuento
FROM productos;
