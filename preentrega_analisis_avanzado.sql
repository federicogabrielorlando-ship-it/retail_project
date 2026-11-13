-- Pre-entrega 5: Script de analisis avanzado con Window Functions
-- Autor: Federico Orlando
--
-- Se ejecuta sobre la base retail_project, despues de retail_project.sql
-- (pre-entrega 2) y pre-entrega-modulo4.sql (que crea la tabla categorias).
-- Solo tiene consultas, no modifica datos, asi que se puede correr las veces que haga falta.
--
-- Reporte: ventas por mes y categoria, con el ranking de cada categoria en el mes,
-- el acumulado de la categoria a lo largo de los meses y si el mes estuvo por
-- encima o por debajo de su promedio.


WITH
-- 1. ventas_mensuales: total vendido por mes y categoria.
-- DATE_TRUNC lleva todas las fechas al primer dia del mes, asi las ventas de un
-- mismo mes quedan agrupadas juntas.
ventas_mensuales AS (
    SELECT DATE_TRUNC('month', v.fecha_venta)::DATE   AS mes,
           cat.nombre                                 AS categoria,
           SUM(v.cantidad * v.precio_unitario)        AS venta_total
    FROM ventas v
    JOIN productos p    ON p.id_producto = v.id_producto
    JOIN categorias cat ON cat.id_categoria = p.id_categoria
    GROUP BY DATE_TRUNC('month', v.fecha_venta)::DATE, cat.nombre
),

-- 2. metricas_ventana: ranking y acumulado sobre los totales mensuales.
-- RANK() con PARTITION BY mes reinicia el ranking en cada mes: la categoria que
-- mas vendio ese mes queda en 1.
-- SUM() OVER con PARTITION BY categoria y ORDER BY mes va sumando mes a mes las
-- ventas de cada categoria. El ORDER BY es necesario, sin el daria el total en todas las filas.
metricas_ventana AS (
    SELECT mes,
           categoria,
           venta_total,
           RANK() OVER (PARTITION BY mes ORDER BY venta_total DESC)       AS ranking_mes,
           SUM(venta_total) OVER (PARTITION BY categoria ORDER BY mes)     AS venta_acumulada
    FROM ventas_mensuales
),

-- 3. promedio_categoria: promedio de venta mensual de cada categoria.
-- Promedio los totales mensuales (no las ventas sueltas) para comparar
-- siempre al mismo nivel: mes contra promedio por mes.
promedio_categoria AS (
    SELECT categoria,
           ROUND(AVG(venta_total), 2) AS promedio_mensual
    FROM ventas_mensuales
    GROUP BY categoria
)

-- 4. Reporte final: uno las metricas con el promedio de su categoria y con
-- CASE WHEN marco si el mes fue exitoso o quedo bajo el promedio.
SELECT m.mes,
       m.categoria,
       m.venta_total,
       m.ranking_mes,
       m.venta_acumulada,
       pc.promedio_mensual,
       CASE
           WHEN m.venta_total >= pc.promedio_mensual THEN 'Exitoso'
           ELSE 'Bajo el promedio'
       END AS comparacion
FROM metricas_ventana m
JOIN promedio_categoria pc ON pc.categoria = m.categoria
ORDER BY m.mes, m.ranking_mes;
