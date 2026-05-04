-- =============================================================================
-- QUINDIOFLIX - Indices y Analisis de Rendimiento
-- Universidad del Quindío · Bases de Datos II · 2025-1
-- Sprint 7: Nucleo Tematico 4
-- =============================================================================

SET LINESIZE 200;
SET PAGESIZE 100;

-- =============================================================================
-- INDICES
-- =============================================================================

-- IDX1: Historial de reproducciones por perfil ordenado por fecha
-- Justificacion: consulta mas frecuente del sistema es el historial
-- de un perfil. Sin indice hace full scan de 200k+ filas.
CREATE INDEX IDX_REPRO_PERFIL_FECHA 
    ON REPRODUCCIONES(id_perfil, fecha_hora_inicio);

-- IDX2: Login y validacion de email duplicado en registro
-- Justificacion: cada login y cada registro valida unicidad de email.
-- Con indice: busqueda O(log n). Sin el: full scan.
CREATE UNIQUE INDEX IDX_USUARIOS_EMAIL 
    ON USUARIOS(email);

-- IDX3: Busquedas de catalogo por categoria y anio
-- Justificacion: las busquedas del catalogo siempre filtran por
-- categoria y opcionalmente por rango de anios.
CREATE INDEX IDX_CONTENIDO_CAT_ANIO 
    ON CONTENIDO(id_categoria, anio_lanzamiento);

-- IDX4: Consultas de pagos por usuario y fecha
-- Justificacion: FN_CALCULAR_MONTO y los reportes financieros consultan
-- pagos de un usuario en un periodo; este indice cubre ambos filtros.
CREATE INDEX IDX_PAGOS_USUARIO_FECHA 
    ON PAGOS(id_usuario, fecha_pago, estado_pago);

-- IDX5: Calificaciones por contenido (para promedio)
CREATE INDEX IDX_CALIFICACIONES_CONTENIDO 
    ON CALIFICACIONES(id_contenido, estrellas);

-- IDX6: Favoritos por perfil
CREATE INDEX IDX_FAVORITOS_PERFIL 
    ON FAVORITOS(id_perfil);

-- =============================================================================
-- ANALISIS DE RENDIMIENTO: EXPLAIN PLAN
-- =============================================================================

-- Eliminar cache de criterios
EXEC DBMS_STATS.CLEAR_TABLE_STATS(user_name => USER, table_name => 'REPRODUCCIONES');

-- Consulta elegida: top 10 contenidos mas reproducidos
-- filtrando por ciudad y rango de fechas
EXPLAIN PLAN SET STATEMENT_ID = 'SIN_IDX'
FOR
SELECT c.titulo, COUNT(r.id_reproduccion) AS total_reproducciones
FROM CONTENIDO c
JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
WHERE u.ciudad = 'Armenia'
  AND r.fecha_hora_inicio BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') 
                            AND TO_DATE('2024-12-31', 'YYYY-MM-DD')
GROUP BY c.id_contenido, c.titulo
ORDER BY total_reproducciones DESC
FETCH FIRST 10 ROWS ONLY;

-- Ver plan SIN indice
SELECT 
    LPAD(' ', 2 * (LEVEL - 1)) || OPERATION || ' ' || OPTIONS AS operation,
    OBJECT_NAME,
    COST,
    CARDINALITY
FROM PLAN_TABLE
CONNECT BY PRIOR ID = PARENT_ID
    AND STATEMENT_ID = 'SIN_IDX'
START WITH ID = 0
    AND STATEMENT_ID = 'SIN_IDX'
ORDER BY ID;

-- CREAR LOS INDICES
-- (Ya creados arriba, aqui solo para referencia)

-- Limpiar cache despues de crear indices
EXEC DBMS_STATS.CLEAR_TABLE_STATS(user_name => USER, table_name => 'REPRODUCCIONES');

-- Ejecutar plan CON indice
EXPLAIN PLAN SET STATEMENT_ID = 'CON_IDX'
FOR
SELECT c.titulo, COUNT(r.id_reproduccion) AS total_reproducciones
FROM CONTENIDO c
JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
WHERE u.ciudad = 'Armenia'
  AND r.fecha_hora_inicio BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') 
                            AND TO_DATE('2024-12-31', 'YYYY-MM-DD')
GROUP BY c.id_contenido, c.titulo
ORDER BY total_reproducciones DESC
FETCH FIRST 10 ROWS ONLY;

-- Ver plan CON indice
SELECT 
    LPAD(' ', 2 * (LEVEL - 1)) || OPERATION || ' ' || OPTIONS AS operation,
    OBJECT_NAME,
    COST,
    CARDINALITY
FROM PLAN_TABLE
CONNECT BY PRIOR ID = PARENT_ID
    AND STATEMENT_ID = 'CON_IDX'
START WITH ID = 0
    AND STATEMENT_ID = 'CON_IDX'
ORDER BY ID;

-- =============================================================================
-- COMPARACION DE COSTOS
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_costo_sin_idx NUMBER;
    v_costo_con_idx NUMBER;
BEGIN
    SELECT SUM(COST) INTO v_costo_sin_idx
    FROM PLAN_TABLE
    WHERE STATEMENT_ID = 'SIN_IDX';
    
    SELECT SUM(COST) INTO v_costo_con_idx
    FROM PLAN_TABLE
    WHERE STATEMENT_ID = 'CON_IDX';
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('ANALISIS DE RENDIMIENTO');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Consulta: Top 10 contenidos Armenia 2024');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE('Costo SIN indice:  ' || v_costo_sin_idx);
    DBMS_OUTPUT.PUT_LINE('Costo CON indice: ' || v_costo_con_idx);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE('Mejora: ' || 
        ROUND((v_costo_sin_idx - v_costo_con_idx) / v_costo_sin_idx * 100, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =============================================================================
-- ANALISIS DETALLADO
-- =============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('JUSTIFICACION DE INDICES');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('IDX_REPRO_PERFIL_FECHA:');
    DBMS_OUTPUT.PUT_LINE('  - Tabla: REPRODUCCIONES');
    DBMS_OUTPUT.PUT_LINE('  - Columnas: (id_perfil, fecha_hora_inicio)');
    DBMS_OUTPUT.PUT_LINE('  -justificacion: Historial por perfil es la consulta');
    DBMS_OUTPUT.PUT_LINE('    mas frecuente del sistema');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('IDX_USUARIOS_EMAIL:');
    DBMS_OUTPUT.PUT_LINE('  - Tabla: USUARIOS');
    DBMS_OUTPUT.PUT_LINE('  - Columnas: (email)');
    DBMS_OUTPUT.PUT_LINE('  -justificacion: Validacion de unicidad en');
    DBMS_OUTPUT.PUT_LINE('    registro y login');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('IDX_CONTENIDO_CAT_ANIO:');
    DBMS_OUTPUT.PUT_LINE('  - Tabla: CONTENIDO');
    DBMS_OUTPUT.PUT_LINE('  - Columnas: (id_categoria, anio_lanzamiento)');
    DBMS_OUTPUT.PUT_LINE('  -justificacion: Busquedas por categoria y');
    DBMS_OUTPUT.PUT_LINE('    rango de anios');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('IDX_PAGOS_USUARIO_FECHA:');
    DBMS_OUTPUT.PUT_LINE('  - Tabla: PAGOS');
    DBMS_OUTPUT.PUT_LINE('  - Columnas: (id_usuario, fecha_pago, estado_pago)');
    DBMS_OUTPUT.PUT_LINE('  -justificacion: Reportes financieros y');
    DBMS_OUTPUT.PUT_LINE('    FN_CALCULAR_MONTO');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- =============================================================================
-- VERIFICAR INDICES CREADOS
-- =============================================================================

SELECT 
    index_name, 
    table_name, 
    column_name,
    CASE WHEN descendable = 'DESC' THEN 'DESC' ELSE 'ASC' END AS orden
FROM user_ind_columns
WHERE table_name IN (
    'REPRODUCCIONES', 'USUARIOS', 'CONTENIDO', 
    'PAGOS', 'CALIFICACIONES', 'FAVORITOS'
)
ORDER BY table_name, column_position;

-- =============================================================================
-- LIMPIEZA
-- =============================================================================

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID IN ('SIN_IDX', 'CON_IDX');
COMMIT;