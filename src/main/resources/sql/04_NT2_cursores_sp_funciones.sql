-- =============================================================================
-- QUINDIOFLIX - PL/SQL: Cursores, Procedimientos y Funciones
-- Universidad del Quindío · Bases de Datos II · 2025-1
-- Sprint 4: Núcleo Temático 2 - Parte 1
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- =============================================================================
-- CURSORES
-- =============================================================================

-- CUR_SUSCRIPCIONES_VENCIDAS: Recorre usuarios con más de 30 días sin pago exitoso
-- Genera reporte: nombre, email, plan, días de mora, monto adeudado
CREATE OR REPLACE PROCEDURE SP_REPORTE_SUSCRIPCIONES_VENCIDAS IS
    CURSOR c_suscripciones_vencidas IS
        SELECT 
            u.id_usuario,
            u.nombre,
            u.email,
            p.nombre AS nombre_plan,
            p.precio_mes,
            TRUNC(SYSDATE) - TRUNC(MAX(pg.fecha_pago)) AS dias_mora
        FROM USUARIOS u
        JOIN PLANES p ON u.id_plan = p.id_plan
        LEFT JOIN PAGOS pg ON u.id_usuario = pg.id_usuario 
            AND pg.estado_pago = 'EXITOSO'
        WHERE u.estado_cuenta = 'ACTIVO'
        GROUP BY u.id_usuario, u.nombre, u.email, p.nombre, p.precio_mes
        HAVING MAX(pg.fecha_pago) < TRUNC(SYSDATE) - 30
           OR MAX(pg.fecha_pago) IS NULL
        ORDER BY dias_mora DESC;
    
    v_registro c_suscripciones_vencidas%ROWTYPE;
    v_contador NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('REPORTE: SUSCRIPCIONES VENCIDAS (más de 30 días sin pago)');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE(RPAD('NOMBRE', 25) || RPAD('EMAIL', 30) || RPAD('PLAN', 12) || RPAD('MORA(DIAS)', 12) || 'MONTO');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    
    OPEN c_suscripciones_vencidas;
    LOOP
        FETCH c_suscripciones_vencidas INTO v_registro;
        EXIT WHEN c_suscripciones_vencidas%NOTFOUND;
        
        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_registro.nombre, 25) || 
            RPAD(v_registro.email, 30) || 
            RPAD(v_registro.nombre_plan, 12) || 
            RPAD(v_registro.dias_mora, 12) || 
            v_registro.precio_mes
        );
    END LOOP;
    CLOSE c_suscripciones_vencidas;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de suscripciones vencidas: ' || v_contador);
END SP_REPORTE_SUSCRIPCIONES_VENCIDAS;
/

-- CUR_ACTUALIZAR_POPULARIDAD: Recorre catálogo y calcula popularidad
-- Calcula reproducciones completas (porcentaje >= 90) por contenido
-- Actualiza campo popularidad en CONTENIDO
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_POPULARIDAD IS
    CURSOR c_contenido_popular IS
        SELECT 
            c.id_contenido,
            c.titulo,
            c.popularidad,
            COUNT(CASE WHEN r.porcentaje_avance >= 90 THEN 1 END) AS reproducciones_completas
        FROM CONTENIDO c
        LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido
        GROUP BY c.id_contenido, c.titulo, c.popularidad
        ORDER BY c.id_contenido
        FOR UPDATE OF c.popularidad;
    
    v_registro c_contenido_popular%ROWTYPE;
    v_nueva_popularidad NUMBER;
    v_contador NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('ACTUALIZANDO POPULARIDAD DEL CATALOGO');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    
    OPEN c_contenido_popular;
    LOOP
        FETCH c_contenido_popular INTO v_registro;
        EXIT WHEN c_contenido_popular%NOTFOUND;
        
        v_nueva_popularidad := v_registro.reproducciones_completas;
        
        IF v_nueva_popularidad != v_registro.popularidad THEN
            UPDATE CONTENIDO 
            SET popularidad = v_nueva_popularidad
            WHERE CURRENT OF c_contenido_popular;
            
            v_contador := v_contador + 1;
            DBMS_OUTPUT.PUT_LINE(
                'Actualizado: ' || v_registro.titulo || 
                ' (Anterior: ' || v_registro.popularidad || 
                ' -> Nuevo: ' || v_nueva_popularidad || ')'
            );
        END IF;
    END LOOP;
    CLOSE c_contenido_popular;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de contenidos actualizados: ' || v_contador);
END SP_ACTUALIZAR_POPULARIDAD;
/

-- =============================================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =============================================================================

-- SP_REGISTRAR_USUARIO: Registra usuario + perfil + primer pago
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_USUARIO(
    p_nombre IN VARCHAR2,
    p_email IN VARCHAR2,
    p_telefono IN VARCHAR2,
    p_fecha_nac IN DATE,
    p_ciudad IN VARCHAR2,
    p_id_plan IN NUMBER,
    p_id_referidor IN NUMBER DEFAULT NULL,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
) IS
    v_existe_email NUMBER;
    v_existe_plan NUMBER;
    v_max_pantallas NUMBER;
    v_id_usuario NUMBER;
    v_id_perfil NUMBER;
    v_monto_plan NUMBER;
    ex_email_dup EXCEPTION;
    ex_plan_no_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_email_dup, -20001);
    PRAGMA EXCEPTION_INIT(ex_plan_no_existe, -20002);
BEGIN
    p_resultado := 0;
    p_mensaje := '';
    
    SELECT COUNT(*) INTO v_existe_email FROM USUARIOS WHERE email = p_email;
    IF v_existe_email > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El email ' || p_email || ' ya está registrado');
    END IF;
    
    SELECT COUNT(*), MAX(precio_mes), MAX(max_pantallas) 
    INTO v_existe_plan, v_monto_plan, v_max_pantallas 
    FROM PLANES WHERE id_plan = p_id_plan;
    
    IF v_existe_plan = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El plan especificado no existe');
    END IF;
    
    INSERT INTO USUARIOS (
        nombre, email, telefono, fecha_nacimiento, ciudad, 
        fecha_registro, estado_cuenta, id_plan, id_referidor
    ) VALUES (
        p_nombre, p_email, p_telefono, p_fecha_nac, p_ciudad,
        SYSDATE, 'ACTIVO', p_id_plan, p_id_referidor
    ) RETURNING id_usuario INTO v_id_usuario;
    
    INSERT INTO PERFILES (id_usuario, nombre, tipo)
    VALUES (v_id_usuario, 'Principal', 'ADULTO')
    RETURNING id_perfil INTO v_id_perfil;
    
    INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)
    VALUES (v_id_usuario, SYSDATE, v_monto_plan, 'PENDIENTE', 'PENDIENTE', SYSDATE + 30);
    
    COMMIT;
    
    p_resultado := v_id_usuario;
    p_mensaje := 'Usuario registrado exitosamente. ID: ' || v_id_usuario;
    
EXCEPTION
    WHEN ex_email_dup THEN
        p_resultado := -1;
        p_mensaje := SQLERRM;
        ROLLBACK;
    WHEN ex_plan_no_existe THEN
        p_resultado := -2;
        p_mensaje := SQLERRM;
        ROLLBACK;
    WHEN OTHERS THEN
        p_resultado := -99;
        p_mensaje := 'Error: ' || SQLERRM;
        ROLLBACK;
END SP_REGISTRAR_USUARIO;
/

-- SP_CAMBIAR_PLAN: Cambia el plan de un usuario
CREATE OR REPLACE PROCEDURE SP_CAMBIAR_PLAN(
    p_id_usuario IN NUMBER,
    p_id_plan_nuevo IN NUMBER,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
) IS
    v_perfiles_actuales NUMBER;
    v_max_nuevo_plan NUMBER;
    v_plan_actual NUMBER;
    v_monto_nuevo NUMBER;
    v_existe_plan NUMBER;
    ex_perfiles_exceden EXCEPTION;
    ex_usuario_no_existe EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_perfiles_exceden, -20003);
    PRAGMA EXCEPTION_INIT(ex_usuario_no_existe, -20004);
BEGIN
    p_resultado := 0;
    p_mensaje := '';
    
    SELECT COUNT(*) INTO v_perfiles_actuales FROM PERFILES WHERE id_usuario = p_id_usuario;
    
    IF v_perfiles_actuales = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El usuario no existe');
    END IF;
    
    SELECT MAX(id_plan), MAX(precio_mes), MAX(max_pantallas)
    INTO v_plan_actual, v_monto_nuevo, v_max_nuevo_plan
    FROM PLANES WHERE id_plan = p_id_plan_nuevo;
    
    IF v_max_nuevo_plan IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'El plan especificado no existe');
    END IF;
    
    IF v_perfiles_actuales > v_max_nuevo_plan THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'El usuario tiene ' || v_perfiles_actuales || 
            ' perfiles activos. El plan seleccionado solo permite ' || 
            v_max_nuevo_plan || '. Cancele un perfil antes de cambiar al plan.');
    END IF;
    
    UPDATE USUARIOS SET id_plan = p_id_plan_nuevo WHERE id_usuario = p_id_usuario;
    
    INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)
    VALUES (p_id_usuario, SYSDATE, v_monto_nuevo, 'PENDIENTE', 'PENDIENTE', SYSDATE + 30);
    
    COMMIT;
    
    p_resultado := 1;
    p_mensaje := 'Plan actualizado exitosamente. Perfiles: ' || v_perfiles_actuales;
    
EXCEPTION
    WHEN ex_perfiles_exceden THEN
        p_resultado := -3;
        p_mensaje := SQLERRM;
        ROLLBACK;
    WHEN ex_usuario_no_existe THEN
        p_resultado := -4;
        p_mensaje := SQLERRM;
        ROLLBACK;
    WHEN OTHERS THEN
        p_resultado := -99;
        p_mensaje := 'Error: ' || SQLERRM;
        ROLLBACK;
END SP_CAMBIAR_PLAN;
/

-- SP_REPORTE_CONSUMO: Reporte de consumo por usuario y rango de fechas
CREATE OR REPLACE PROCEDURE SP_REPORTE_CONSUMO(
    p_id_usuario IN NUMBER,
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE
) IS
    CURSOR c_perfiles IS
        SELECT id_perfil, nombre, tipo FROM PERFILES WHERE id_usuario = p_id_usuario;
    
    CURSOR c_reproducciones(p_id_perfil NUMBER) IS
        SELECT 
            cat.nombre AS categoria,
            c.titulo,
            r.fecha_hora_inicio,
            r.fecha_hora_fin,
            ROUND((r.fecha_hora_fin - r.fecha_hora_inicio) * 24 * 60, 0) AS minutos
        FROM REPRODUCCIONES r
        JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
        JOIN CATEGORIAS cat ON c.id_categoria = cat.id_categoria
        WHERE r.id_perfil = p_id_perfil
          AND TRUNC(r.fecha_hora_inicio) BETWEEN p_fecha_inicio AND p_fecha_fin
        ORDER BY r.fecha_hora_inicio;
    
    v_perfil c_perfiles%ROWTYPE;
    v_rep c_reproducciones%ROWTYPE;
    v_total_minutos NUMBER;
    v_total_global NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('REPORTE DE CONSUMO: Usuario ' || p_id_usuario);
    DBMS_OUTPUT.PUT_LINE('Periodo: ' || p_fecha_inicio || ' al ' || p_fecha_fin);
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    
    OPEN c_perfiles;
    LOOP
        FETCH c_perfiles INTO v_perfil;
        EXIT WHEN c_perfiles%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('>>> Perfil: ' || v_perfil.nombre || ' (' || v_perfil.tipo || ')');
        DBMS_OUTPUT.PUT_LINE(RPAD('CATEGORIA', 15) || RPAD('TITULO', 30) || RPAD('INICIO', 20) || 'MINUTOS');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        
        v_total_minutos := 0;
        OPEN c_reproducciones(v_perfil.id_perfil);
        LOOP
            FETCH c_reproducciones INTO v_rep;
            EXIT WHEN c_reproducciones%NOTFOUND;
            
            IF v_rep.minutos IS NOT NULL THEN
                v_total_minutos := v_total_minutos + v_rep.minutos;
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(v_rep.categoria, 15) || 
                    RPAD(SUBSTR(v_rep.titulo, 1, 28), 30) || 
                    RPAD(TO_CHAR(v_rep.fecha_hora_inicio, 'YYYY-MM-DD HH24:MI'), 20) || 
                    v_rep.minutos
                );
            END IF;
        END LOOP;
        CLOSE c_reproducciones;
        
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total minutos perfil: ' || v_total_minutos);
        v_total_global := v_total_global + v_total_minutos;
    END LOOP;
    CLOSE c_perfiles;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL GENERAL: ' || v_total_global || ' minutos');
    DBMS_OUTPUT.PUT_LINE('=======================================================');
    
END SP_REPORTE_CONSUMO;
/

-- =============================================================================
-- FUNCIONES
-- =============================================================================

-- FN_CALCULAR_MONTO: Calcula monto a pagar con descuentos
CREATE OR REPLACE FUNCTION FN_CALCULAR_MONTO(p_id_usuario NUMBER) 
RETURN NUMBER IS
    v_monto_base NUMBER;
    v_meses_antiguedad NUMBER;
    v_tiene_referidor NUMBER;
    v_descuento NUMBER := 0;
    v_monto_final NUMBER;
BEGIN
    SELECT precio_mes INTO v_monto_base
    FROM PLANES p
    JOIN USUARIOS u ON u.id_plan = p.id_plan
    WHERE u.id_usuario = p_id_usuario;
    
    SELECT MONTHS_BETWEEN(SYSDATE, u.fecha_registro) INTO v_meses_antiguedad
    FROM USUARIOS u WHERE u.id_usuario = p_id_usuario;
    
    SELECT COUNT(*) INTO v_tiene_referidor
    FROM USUARIOS u 
    WHERE u.id_usuario = p_id_usuario 
      AND u.id_referidor IS NOT NULL;
    
    IF v_meses_antiguedad > 24 THEN
        v_descuento := 0.15;
    ELSIF v_meses_antiguedad > 12 THEN
        v_descuento := 0.10;
    END IF;
    
    IF v_tiene_referidor > 0 AND v_descuento < 0.10 THEN
        v_descuento := GREATEST(v_descuento, 0.05);
    ELSIF v_tiene_referidor > 0 AND v_descuento >= 0.10 THEN
        v_descuento := v_descuento + 0.05;
    END IF;
    
    v_monto_final := v_monto_base * (1 - v_descuento);
    
    RETURN ROUND(v_monto_final, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END FN_CALCULAR_MONTO;
/

-- FN_CONTENIDO_RECOMENDADO: Recomienda contenido basado en preferencias
CREATE OR REPLACE FUNCTION FN_CONTENIDO_RECOMENDADO(p_id_perfil NUMBER)
RETURN VARCHAR2 IS
    v_tipo_perfil VARCHAR2(20);
    v_genero_favorito NUMBER;
    v_id_contenido NUMBER;
    v_titulo VARCHAR2(200);
BEGIN
    SELECT tipo INTO v_tipo_perfil
    FROM PERFILES WHERE id_perfil = p_id_perfil;
    
    SELECT cg.id_genero INTO v_genero_favorito
    FROM (
        SELECT cg.id_genero, COUNT(*) AS total
        FROM REPRODUCCIONES r
        JOIN CONTENIDO_GENERO cg ON r.id_contenido = cg.id_contenido
        WHERE r.id_perfil = p_id_perfil
        GROUP BY cg.id_genero
        ORDER BY total DESC
    ) WHERE ROWNUM = 1;
    
    IF v_tipo_perfil = 'INFANTIL' THEN
        SELECT c.id_contenido, c.titulo INTO v_id_contenido, v_titulo
        FROM CONTENIDO c
        JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido
        LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido AND r.id_perfil = p_id_perfil
        WHERE cg.id_genero = v_genero_favorito
          AND c.clasificacion_edad IN ('TP', '+7', '+13')
          AND r.id_reproduccion IS NULL
          AND c.popularidad > 0
        ORDER BY c.popularidad DESC
        OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY;
    ELSE
        SELECT c.id_contenido, c.titulo INTO v_id_contenido, v_titulo
        FROM CONTENIDO c
        JOIN CONTENIDO_GENERO cg ON c.id_contenido = cg.id_contenido
        LEFT JOIN REPRODUCCIONES r ON c.id_contenido = r.id_contenido AND r.id_perfil = p_id_perfil
        WHERE cg.id_genero = v_genero_favorito
          AND r.id_reproduccion IS NULL
          AND c.popularidad > 0
        ORDER BY c.popularidad DESC
        OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY;
    END IF;
    
    RETURN v_titulo;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No hay recomendaciones disponibles';
    WHEN OTHERS THEN
        RETURN 'Error al generar recomendación';
END FN_CONTENIDO_RECOMENDADO;
/

-- =============================================================================
-- VERIFICACIONES
-- =============================================================================

-- Compilar objetos
SHOW ERRORS PROCEDURE SP_REPORTE_SUSCRIPCIONES_VENCIDAS;
SHOW ERRORS PROCEDURE SP_ACTUALIZAR_POPULARIDAD;
SHOW ERRORS PROCEDURE SP_REGISTRAR_USUARIO;
SHOW ERRORS PROCEDURE SP_CAMBIAR_PLAN;
SHOW ERRORS PROCEDURE SP_REPORTE_CONSUMO;
SHOW ERRORS FUNCTION FN_CALCULAR_MONTO;
SHOW ERRORS FUNCTION FN_CONTENIDO_RECOMENDADO;

-- Pruebas
SELECT SP_REPORTE_SUSCRIPCIONES_VENCIDAS() FROM DUAL;

BEGIN
    SP_ACTUALIZAR_POPULARIDAD();
END;
/

DECLARE
    v_resultado NUMBER;
    v_mensaje VARCHAR2(200);
BEGIN
    SP_REGISTRAR_USUARIO(
        'Nuevo Usuario', 'nuevo@test.com', '3001234567',
        TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'Armenia', 1, NULL,
        v_resultado, v_mensaje
    );
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
END;
/

DECLARE
    v_monto NUMBER;
BEGIN
    v_monto := FN_CALCULAR_MONTO(1);
    DBMS_OUTPUT.PUT_LINE('Monto a pagar usuario 1: ' || v_monto);
END;
/

DECLARE
    v_recomendacion VARCHAR2(200);
BEGIN
    v_recomendacion := FN_CONTENIDO_RECOMENDADO(1);
    DBMS_OUTPUT.PUT_LINE('Contenido recomendado: ' || v_recomendacion);
END;
/