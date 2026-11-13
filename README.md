# retail_project

Repositorio de las pre-entregas del curso de SQL de Coderhouse, sobre la base `retail_project` de una tienda de mascotas.

## Pre-entrega 2: tablas principales con restricciones y datos iniciales

Archivo: `retail_project.sql`

Crea la base `retail_project` con tres tablas:

- `clientes`: clave primaria, email único y obligatorio, edad mayor o igual a 18.
- `productos`: clave primaria `SERIAL`, precio `DECIMAL` mayor a 0 y stock no negativo.
- `ventas`: clave primaria y dos claves foráneas, una a `clientes` y otra a `productos`. Cantidad y precio unitario mayores a 0.

Después carga 6 registros por tabla dentro de un `BEGIN ... COMMIT`, sube un 10% los precios de la categoría Alimentos con un `UPDATE` y borra una venta de prueba con un `DELETE`. Las dos operaciones usan `WHERE`.

## Pre-entrega 3: valores nulos con IS NULL y COALESCE

Carpeta: `pre-entrega-3/`

Tiene el PDF del entregable con las 4 consultas y un script para probarlas. Usa su propia tabla `productos` de prueba, por eso va en una carpeta aparte y se corre en otra base (ver el README de la carpeta).

## Pre-entrega 4: consultas multicapa para análisis de negocio

Archivo: `pre-entrega-modulo4.sql`

Primero prepara los datos: crea la tabla `categorias`, la conecta con `productos` por clave foránea, agrega una clienta sin compras y algunas ventas de octubre y noviembre. Después tiene tres consultas comentadas:

1. **Rentabilidad por categoría**: une `ventas`, `productos` y `categorias`, y muestra unidades e ingreso de las categorías que superan $50.000 (filtro con `HAVING`).
2. **Clientes sin compras**: `LEFT JOIN` entre `clientes` y `ventas` para encontrar a los que nunca compraron, con `COALESCE` para mostrar 0 en lugar de NULL.
3. **Top de compras por cliente**: une `clientes`, `ventas` y `productos`; muestra el total gastado, el producto que más veces compró cada cliente y la fecha de su última compra.

## Pre-entrega 5: script de análisis avanzado con Window Functions

Archivo: `preentrega_analisis_avanzado.sql`

Reporte de ventas por mes y categoría armado con tres CTEs:

1. `ventas_mensuales`: total vendido por mes (con `DATE_TRUNC`) y categoría.
2. `metricas_ventana`: ranking de cada categoría dentro del mes con `RANK()` y venta acumulada de cada categoría mes a mes con `SUM() OVER (PARTITION BY categoria ORDER BY mes)`.
3. `promedio_categoria`: promedio de venta mensual de cada categoría.

El `SELECT` final usa `CASE WHEN` para marcar cada mes como "Exitoso" o "Bajo el promedio" de su categoría. Noviembre sale bajo el promedio en todas porque solo tiene ventas hasta el día 5.

## Cómo ejecutarlo

Con PostgreSQL instalado (lo probé en la versión 16). El orden importa: la pre-entrega 4 usa las tablas que crea la 2, y la 5 usa las de las dos.

**Desde la terminal (psql):**

```
psql -U postgres -f retail_project.sql
psql -U postgres -d retail_project -f pre-entrega-modulo4.sql
psql -U postgres -d retail_project -f preentrega_analisis_avanzado.sql
```

**Desde pgAdmin o DBeaver:**

1. Ejecutar solo la línea `CREATE DATABASE retail_project;`.
2. Abrir una consulta conectada a `retail_project` y ejecutar el resto de `retail_project.sql` (la línea `\c` es solo para psql, se puede borrar).
3. En la misma conexión, ejecutar `pre-entrega-modulo4.sql` y después `preentrega_analisis_avanzado.sql`.

Si se quiere volver a correr la pre-entrega 4, conviene correr antes `retail_project.sql`, que deja la base otra vez con los datos iniciales.
