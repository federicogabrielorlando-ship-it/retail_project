# retail_project

Pre-entrega 2 del curso de SQL de Coderhouse: tablas principales con restricciones y carga inicial de datos.

El script `retail_project.sql` crea la base `retail_project` con tres tablas de una tienda de mascotas:

- `clientes`: clave primaria, email único y obligatorio, edad mayor o igual a 18.
- `productos`: clave primaria `SERIAL`, precio `DECIMAL` mayor a 0 y stock no negativo.
- `ventas`: clave primaria y dos claves foráneas, una a `clientes` y otra a `productos`. Cantidad y precio unitario mayores a 0.

Después carga 6 registros por tabla dentro de un `BEGIN ... COMMIT`, sube un 10% los precios de la categoría Alimentos con un `UPDATE` y borra una venta de prueba con un `DELETE`. Las dos operaciones usan `WHERE`.

## Cómo ejecutarlo

Con PostgreSQL instalado (lo probé en la versión 16).

**Desde la terminal (psql):**

```
psql -U postgres -f retail_project.sql
```

El script crea la base, se conecta con `\c retail_project` y ejecuta todo lo demás.

**Desde pgAdmin o DBeaver:**

1. Ejecutar solo la línea `CREATE DATABASE retail_project;`.
2. Abrir una consulta nueva conectada a `retail_project`.
3. Pegar y ejecutar el resto del script, desde el punto 2 (la línea `\c` es solo para psql, se puede borrar).

El script empieza con `DROP TABLE IF EXISTS`, así que se puede correr más de una vez sin errores.
