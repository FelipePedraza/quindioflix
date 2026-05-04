-- =============================================================================
-- QUINDIOFLIX - Consultas Avanzadas
-- Universidad del Quindío · Bases de Datos II · 2025-1
-- Sprint 3: Núcleo Temático 1 - Consultas Avanzadas
-- =============================================================================

SET LINESIZE 200;
SET PAGESIZE 100;

-- =============================================================================
-- CONSULTAS PARAMETRIZADAS
-- =============================================================================

-- Q1: Top 10 contenidos más reproducidos en una ciudad
-- Usando variable de sustitucion
DEFINE ciudad = 'Armenia';

SELECT c.titulo, COUNT(r.id_reproduccion) AS total_reproducciones
FROM CONTENIDO c
JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
WHERE u.ciudad = '&ciudad'
GROUP BY c.id_contenido, c.titulo
ORDER BY total_reproducciones DESC
FETCH FIRST 10 ROWS ONLY;

-- Q2: Ingresos por plan de suscripcion en un periodo (mes y anio)
-- Usando && para reutilizacion
DEFINE mes = 1;
DEFINE anio = 2024;

SELECT p.nombre AS plan, SUM(pg.monto) AS ingresos_totales, COUNT(DISTINCT pg.id_usuario) AS usuarios_pagadores
FROM PAGOS pg
JOIN PLANES p ON pg.monto = p.precio_mes
WHERE EXTRACT(MONTH FROM pg.fecha_pago) = &&mes
  AND EXTRACT(YEAR FROM pg.fecha_pago) = &&anio
  AND pg.estado_pago = 'EXITOSO'
GROUP BY p.nombre
ORDER BY ingresos_totales DESC;

-- Q3: Calificacion promedio por categoria para un genero
DEFINE genero = 'DRAMA';

SELECT cat.nombre AS categoria, AVG(cal.estrellas) AS promedio_calificacion, COUNT(*) AS total_calificaciones
FROM CALIFICACIONES cal
JOIN CONTENIDO c ON cal.id_contenido = c.id_contenido
JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido
JOIN GENEROS g ON cg.id_genero = g.id_genero
JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
WHERE g.nombre = '&genero'
GROUP BY cat.nombre
ORDER BY promedio_calificacion DESC;

-- Q4: Historial de reproducciones de un usuario con tiempo total consumido
DEFINE id_usuario = 1;

SELECT 
    u.nombre AS usuario,
    c.titulo AS contenido,
    r.fecha_hora_inicio AS inicio,
    r.fecha_hora_fin AS fin,
    ROUND((r.fecha_hora_fin - r.fecha_hora_inicio) * 24 * 60, 0) AS minutos_consumidos,
    r.porcentaje_avance,
    r.dispositivo
FROM USUARIOS u
JOIN PERFILES p ON u.id_usuario = p.id_usuario
JOIN REPRODUCCIONES r ON p.id_perfil = r.id_perfil
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
WHERE u.id_usuario = &id_usuario
ORDER BY r.fecha_hora_inicio DESC;

-- =============================================================================
-- PIVOT Y UNPIVOT
-- =============================================================================

-- PIVOT_1: Usuarios activos por ciudad y plan (matriz)
-- Filas = ciudades, Columnas = planes, Valor = cantidad de usuarios activos
SELECT * FROM (
    SELECT u.ciudad, p.nombre AS plan, u.id_usuario
    FROM USUARIOS u
    JOIN PLANES p ON u.id_plan = p.id_plan
    WHERE u.estado_cuenta = 'ACTIVO'
)
PIVOT (
    COUNT(id_usuario)
    FOR plan IN ('BASICO' AS basico, 'ESTANDAR' AS estandar, 'PREMIUM' AS premium)
)
ORDER BY ciudad;

-- PIVOT_2: Reproducciones por categoria y dispositivo
-- Filas = categorias, Columnas = dispositivos, Valor = total reproducciones
SELECT * FROM (
    SELECT cat.nombre AS categoria, r.dispositivo, r.id_reproduccion
    FROM REPRODUCCIONES r
    JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
    JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
)
PIVOT (
    COUNT(id_reproduccion)
    FOR dispositivo IN ('CELULAR' AS celular, 'TABLET' AS tablet, 'TV' AS tv, 'COMPUTADOR' AS computador)
)
ORDER BY categoria;

-- UNPIVOT_1: Invertir PIVOT_2 para analisis cruzado
SELECT categoria, dispositivo, total_reproducciones
FROM (
    SELECT * FROM (
        SELECT cat.nombre AS categoria, r.dispositivo, r.id_reproduccion
        FROM REPRODUCCIONES r
        JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
        JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
    )
    PIVOT (
        COUNT(id_reproduccion)
        FOR dispositivo IN ('CELULAR' AS celular, 'TABLET' AS tablet, 'TV' AS tv, 'COMPUTADOR' AS computador)
    )
)
UNPIVOT (
    total_reproducciones
    FOR dispositivo IN (celular, tablet, tv, computador)
)
ORDER BY categoria, dispositivo;

-- =============================================================================
-- GROUP BY AVANZADO: ROLLUP, CUBE, GROUPING SETS
-- =============================================================================

-- ROLLUP_1: Ingresos por ciudad y plan con subtotales
-- Muestra: subtotal por ciudad, luego gran total
SELECT 
    CASE 
        WHEN GROUPING(u.ciudad) = 1 THEN 'TOTAL GENERAL'
        WHEN GROUPING(p.nombre) = 1 THEN 'Subtotal ' || u.ciudad
        ELSE u.ciudad
    END AS ciudad,
    CASE WHEN GROUPING(p.nombre) = 1 THEN '' ELSE p.nombre END AS plan,
    SUM(pg.monto) AS ingresos
FROM PAGOS pg
JOIN USUARIOS u ON pg.id_usuario = u.id_usuario
JOIN PLANES p ON u.id_plan = p.id_plan
WHERE pg.estado_pago = 'EXITOSO'
GROUP BY ROLLUP (u.ciudad, p.nombre)
ORDER BY u.ciudad, p.nombre;

-- CUBE_1: Reproducciones por categoria y dispositivo
-- Todas las combinaciones posibles de categoria y dispositivo
SELECT 
    CASE WHEN GROUPING(cat.nombre) = 1 THEN 'TOTAL' ELSE cat.nombre END AS categoria,
    CASE WHEN GROUPING(r.dispositivo) = 1 THEN 'TOTAL' ELSE r.dispositivo END AS dispositivo,
    COUNT(*) AS reproducciones
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
GROUP BY CUBE (cat.nombre, r.dispositivo)
ORDER BY categoria, dispositivo;

-- GROUPING_SETS_1: Solo totales por categoria y por ciudad
-- Sin cruce entre categoria y ciudad
SELECT 
    CASE WHEN GROUPING(cat.nombre) = 1 THEN NULL ELSE cat.nombre END AS categoria,
    CASE WHEN GROUPING(u.ciudad) = 1 THEN NULL ELSE u.ciudad END AS ciudad,
    COUNT(DISTINCT r.id_reproduccion) AS reproducciones
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
GROUP BY GROUPING SETS (cat.nombre, u.ciudad)
ORDER BY categoria, ciudad;

-- =============================================================================
-- VISTAS MATERIALIZADAS
-- =============================================================================

-- MV_CONTENIDO_POPULAR: Contenido con metricas de popularidad
CREATE MATERIALIZED VIEW MV_CONTENIDO_POPULAR
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    c.id_contenido,
    c.titulo,
    c.clasificacion_edad,
    COUNT(r.id_reproduccion) AS total_reproducciones,
    ROUND(AVG(r.porcentaje_avance), 2) AS promedio_avance,
    COUNT(CASE WHEN r.porcentaje_avance >= 90 THEN 1 END) AS reproducciones_completas,
    ROUND(AVG(cal.estrellas), 2) AS promedio_calificacion,
    COUNT(DISTINCT cal.id_perfil) AS usuarios_calificadores
FROM CONTENIDO c
LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
LEFT JOIN CALIFICACIONES cal ON c.id_contenido = cal.id_contenido
GROUP BY c.id_contenido, c.titulo, c.clasificacion_edad;

COMMENT ON MATERIALIZED VIEW MV_CONTENIDO_POPULAR IS 'Vista materializada de contenido popular con metricas';

-- MV_INGRESOS_MENSUALES: Ingresos mensuales por ciudad y plan
CREATE MATERIALIZED VIEW MV_INGRESOS_MENSUALES
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT 
    u.ciudad,
    p.nombre AS nombre_plan,
    EXTRACT(MONTH FROM pg.fecha_pago) AS mes,
    EXTRACT(YEAR FROM pg.fecha_pago) AS anio,
    SUM(pg.monto) AS total_ingresos,
    COUNT(DISTINCT pg.id_usuario) AS total_usuarios,
    COUNT(pg.id_pago) AS total_pagos
FROM PAGOS pg
JOIN USUARIOS u ON pg.id_usuario = u.id_usuario
JOIN PLANES p ON u.id_plan = p.id_plan
WHERE pg.estado_pago = 'EXITOSO'
GROUP BY u.ciudad, p.nombre, EXTRACT(MONTH FROM pg.fecha_pago), EXTRACT(YEAR FROM pg.fecha_pago);

COMMENT ON MATERIALIZED VIEW MV_INGRESOS_MENSUALES IS 'Vista materializada de ingresos mensuales';

-- Verificar vistas materializadas
SELECT mv_name, build_mode, refresh_mode, last_refresh_date
FROM user_mviews
WHERE mv_name LIKE 'MV_%';

-- =============================================================================
-- CONSULTAS DE EJEMPLO USANDO VISTAS MATERIALIZADAS
-- =============================================================================

-- Contenido más popular (usando MV)
SELECT titulo, total_reproducciones, promedio_calificacion, reproducciones_completas
FROM MV_CONTENIDO_POPULAR
ORDER BY total_reproducciones DESC
FETCH FIRST 10 ROWS ONLY;

-- Ingresos mensuales (usando MV)
SELECT ciudad, nombre_plan, mes, anio, total_ingresos, total_usuarios
FROM MV_INGRESOS_MENSUALES
WHERE anio = 2024
ORDER BY ciudad, anio DESC, mes DESC;

-- =============================================================================
-- CONSULTAS ADICIONALES DE ANALISIS
-- =============================================================================

-- Usuarios activos por mes
SELECT 
    EXTRACT(MONTH FROM fecha_registro) AS mes,
    EXTRACT(YEAR FROM fecha_registro) AS anio,
    COUNT(*) AS nuevos_usuarios
FROM USUARIOS
GROUP BY EXTRACT(MONTH FROM fecha_registro), EXTRACT(YEAR FROM fecha_registro)
ORDER BY anio, mes;

-- Contenido por año de lanzamiento
SELECT 
    anio_lanzamiento,
    COUNT(*) AS total_contenido,
    SUM(CASE WHEN es_original = 'S' THEN 1 ELSE 0 END) AS originales
FROM CONTENIDO
GROUP BY anio_lanzamiento
ORDER BY anio_lanzamiento DESC;

-- Top usuarios por tiempo de reproduccion
SELECT 
    u.nombre AS usuario,
    SUM(ROUND((r.fecha_hora_fin - r.fecha_hora_inicio) * 24 * 60, 0)) AS minutos_totales
FROM USUARIOS u
JOIN PERFILES p ON u.id_usuario = p.id_usuario
JOIN REPRODUCCIONES r ON p.id_perfil = r.id_perfil
WHERE r.fecha_hora_fin IS NOT NULL
GROUP BY u.id_usuario, u.nombre
ORDER BY minutos_totales DESC
FETCH FIRST 10 ROWS ONLY;

-- Calificacion promedio por contenido (minimo 5 calificaciones)
SELECT 
    c.titulo,
    ROUND(AVG(cal.estrellas), 2) AS promedio,
    COUNT(*) AS total_calificaciones
FROM CONTENIDO c
JOIN CALIFICACIONES cal ON c.id_contenido = cal.id_contenido
GROUP BY c.id_contenido, c.titulo
HAVING COUNT(*) >= 5
ORDER BY promedio DESC, total_calificaciones DESC;