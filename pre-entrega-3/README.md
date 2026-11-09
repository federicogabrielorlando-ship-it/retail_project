# Pre-entrega 3: valores nulos con IS NULL y COALESCE

Consultas sobre una tabla `productos` (nombre, precio_lista, descuento_promocional, categoria) donde algunos datos vienen vacíos.

Archivos:

- `PreEntrega3_ValoresNulos.pdf`: el entregable, con las 4 consultas, una explicación corta de cada una y el resultado que devolvió PostgreSQL.
- `valores_nulos.sql`: el script para probarlas. Crea la tabla con seis productos de prueba y después tiene las 4 consultas.

Las consultas:

1. Productos sin categoría, con `IS NULL`.
2. Reporte de precios: `COALESCE(precio_lista, 0) AS precio_final`.
3. Categorías vacías reemplazadas por `'Sin Categorizar'`.
4. Precio con descuento: `precio_lista - COALESCE(descuento_promocional, 0)`, para que un descuento vacío no deje el resultado en NULL.

## Cómo ejecutarlo

En PostgreSQL, en una base de prueba aparte (no en `retail_project`, que ya tiene otra tabla `productos` con columnas distintas):

```
psql -U postgres -d nombre_de_tu_base -f valores_nulos.sql
```

O abrir el archivo en pgAdmin o DBeaver y ejecutarlo completo.
