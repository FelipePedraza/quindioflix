-- =============================================================================
-- QUINDIOFLIX - Transacciones y Concurrencia
-- Universidad del Quindío · Bases de Datos II
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- =============================================================================
-- TRANSACCION 1: REGISTRO COMPLETO DE USUARIO
--Crear usuario + perfil + primer pago. Todo o nada.
-- =============================================================================

CREATE OR REPLACE PROCEDURE SP_REGISTRO_COMPLETO_USUARIO(
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
    v_id_usuario NUMBER;
    v_id_perfil NUMBER;
    v_monto_plan NUMBER;
BEGIN
    p_resultado := 0;
    p_mensaje := '';
    
    -- Iniciar transaccion
    SAVEPOINT sp_usuario_creado;
    
    -- Insertar usuario
    INSERT INTO USUARIOS (
        nombre, email, telefono, fecha_nacimiento, ciudad,
        fecha_registro, estado_cuenta, id_plan, id_referidor
    ) VALUES (
        p_nombre, p_email, p_telefono, p_fecha_nac, p_ciudad,
        SYSDATE, 'PENDIENTE', p_id_plan, p_id_referidor
    ) RETURNING id_usuario INTO v_id_usuario;
    
    SAVEPOINT sp_perfil_creado;
    
    -- Insertar perfil predeterminado
    INSERT INTO PERFILES (id_usuario, nombre, tipo)
    VALUES (v_id_usuario, 'Principal', 'ADULTO')
    RETURNING id_perfil INTO v_id_perfil;
    
    SAVEPOINT sp_pago_creado;
    
    -- Insertar primer pago pendiente
    SELECT precio_mes INTO v_monto_plan FROM PLANES WHERE id_plan = p_id_plan;
    
    INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)
    VALUES (v_id_usuario, SYSDATE, v_monto_plan, 'PENDIENTE', 'PENDIENTE', SYSDATE + 30);
    
    -- Confirmar transaccion
    COMMIT;
    
    p_resultado := v_id_usuario;
    p_mensaje := 'Usuario creado exitosamente con ID: ' || v_id_usuario;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_pago_creado;
        p_resultado := -1;
        p_mensaje := 'Error al crear pago: ' || SQLERRM;
        ROLLBACK;
END SP_REGISTRO_COMPLETO_USUARIO;
/

-- =============================================================================
-- TRANSACCION 2: RENOVACION MENSUAL MASIVA
-- Para cada usuario activo, calcular monto y registrar pago.
-- SAVEPOINT por usuario para no perder los anteriores si uno falla.
-- =============================================================================

CREATE OR REPLACE PROCEDURE SP_RENOVACION_MENSUAL(
    p_mes IN NUMBER,
    p_anio IN NUMBER,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
) IS
    CURSOR c_usuarios_activos IS
        SELECT id_usuario, id_plan FROM USUARIOS WHERE estado_cuenta = 'ACTIVO';
    
    v_usuario c_usuarios_activos%ROWTYPE;
    v_monto NUMBER;
    v_contador_exitosos NUMBER := 0;
    v_contador_fallidos NUMBER := 0;
BEGIN
    p_resultado := 0;
    
    FOR v_usuario IN c_usuarios_activos LOOP
        SAVEPOINT sp_usuario_actual;
        
        BEGIN
            SELECT precio_mes INTO v_monto 
            FROM PLANES WHERE id_plan = v_usuario.id_plan;
            
            INSERT INTO PAGOS (
                id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento
            ) VALUES (
                v_usuario.id_usuario, 
                TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD'),
                v_monto, 'RENOVACION', 'EXITOSO',
                ADD_MONTHS(TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD'), 1)
            );
            
            v_contador_exitosos := v_contador_exitosos + 1;
            
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO sp_usuario_actual;
                v_contador_fallidos := v_contador_fallidos + 1;
        END;
    END LOOP;
    
    COMMIT;
    
    p_resultado := v_contador_exitosos;
    p_mensaje := 'Renovacion completada. Exitosos: ' || v_contador_exitosos || 
                 ', Fallidos: ' || v_contador_fallidos;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := -1;
        p_mensaje := 'Error en renovacion: ' || SQLERRM;
END SP_RENOVACION_MENSUAL;
/

-- =============================================================================
-- TRANSACCION 3: ELIMINACION DE CUENTA (TODO O NADA)
-- Eliminar en cascada respetando FK:
-- calificaciones -> favoritos -> reproducciones -> reportes -> perfiles -> pagos -> usuario
-- =============================================================================

CREATE OR REPLACE PROCEDURE SP_ELIMINAR_CUENTA(
    p_id_usuario IN NUMBER,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
) IS
    v_existe NUMBER;
BEGIN
    p_resultado := 0;
    
    SELECT COUNT(*) INTO v_existe FROM USUARIOS WHERE id_usuario = p_id_usuario;
    IF v_existe = 0 THEN
        p_resultado := -1;
        p_mensaje := 'Usuario no encontrado';
        RETURN;
    END IF;
    
    SAVEPOINT sp_cal;
    
    -- Eliminar calificaciones
    DELETE FROM CALIFICACIONES WHERE id_perfil IN 
        (SELECT id_perfil FROM PERFILES WHERE id_usuario = p_id_usuario);
    
    SAVEPOINT sp_fav;
    
    -- Eliminar favoritos
    DELETE FROM FAVORITOS WHERE id_perfil IN 
        (SELECT id_perfil FROM PERFILES WHERE id_usuario = p_id_usuario);
    
    SAVEPOINT sp_rep;
    
    -- Eliminar reproducciones
    DELETE FROM REPRODUCCIONES WHERE id_perfil IN 
        (SELECT id_perfil FROM PERFILES WHERE id_usuario = p_id_usuario);
    
    SAVEPOINT sp_rep_cont;
    
    -- Eliminar reportes
    DELETE FROM REPORTES_CONTENIDO WHERE id_perfil IN 
        (SELECT id_perfil FROM PERFILES WHERE id_usuario = p_id_usuario);
    
    SAVEPOINT sp_perfiles;
    
    -- Eliminar perfiles
    DELETE FROM PERFILES WHERE id_usuario = p_id_usuario;
    
    SAVEPOINT sp_pagos;
    
    -- Eliminar pagos
    DELETE FROM PAGOS WHERE id_usuario = p_id_usuario;
    
    SAVEPOINT sp_usuario;
    
    -- Eliminar usuario
    DELETE FROM USUARIOS WHERE id_usuario = p_id_usuario;
    
    COMMIT;
    
    p_resultado := 1;
    p_mensaje := 'Cuenta eliminada exitosamente';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_usuario;
        p_resultado := -1;
        p_mensaje := 'Error al eliminar cuenta: ' || SQLERRM;
        ROLLBACK;
END SP_ELIMINAR_CUENTA;
/

-- =============================================================================
-- ESCENARIO DE CONCURRENCIA: CAMBIO DE PLAN SIMULTANEO
-- =============================================================================

-- Este escenario demuestra el bloqueo de fila con SELECT FOR UPDATE
-- y la concurrencia optimista en Oracle.

--PASO 1: En SQL Developer, abrir Sesion A y ejecutar:
/*
-- SESION A (Usuario 1)
-- Bloquea la fila del usuario 5 para actualizacion
SELECT * FROM USUARIOS WHERE id_usuario = 5 FOR UPDATE;
*/

--PASO 2: Abrir Sesion B y ejecutar:
/*
-- SESION B (Usuario 2)
-- Intenta actualizar el mismo usuario
-- Quedara en espera hasta que Sesion A haga COMMIT o ROLLBACK
UPDATE USUARIOS SET id_plan = 2 WHERE id_usuario = 5;
*/

--PASO 3: En Sesion A, verificar bloqueo:
/*
-- Ver transacciones bloqueadas
SELECT 
    s.sid,
    s.serial#,
    s.username,
    o.object_name,
    s.lockwait,
    s.status
FROM v$session s
JOIN v$access a ON s.sid = a.sid
JOIN user_objects o ON a.object = o.object_name
WHERE a.object = 'USUARIOS';
*/

-- Explicacion del comportamiento:
/*
1. SESION A ejecuta SELECT...FOR UPDATE y obtiene un bloqueo exclusivo (RX)
   sobre la fila del usuario 5.

2. SESION B intenta UPDATE pero queda en espera (estado: WAITING)
   porque Oracle detecta el bloqueo.

3. Cuando SESION A hace COMMIT o ROLLBACK, se libera el bloqueo
   y el UPDATE de SESION B se ejecuta.

4. Si SESION A hace ROLLBACK, los cambios de SESION A no se aplican
   y los de SESION B se aplican.

5. Si SESION A hace COMMIT, los cambios de SESION A se aplican
   y los de SESION B se aplicaran despues.
*/

-- Procedimiento para demostrar bloquear y esperar
CREATE OR REPLACE PROCEDURE SP_BLOQUEO_EJEMPLO(
    p_id_usuario IN NUMBER,
    p_nuevo_plan IN NUMBER
) IS
    v_fila USUARIOS%ROWTYPE;
BEGIN
    -- Bloquear la fila
    SELECT * INTO v_fila 
    FROM USUARIOS 
    WHERE id_usuario = p_id_usuario 
    FOR UPDATE;
    
    DBMS_OUTPUT.PUT_LINE('Fila bloqueada: ' || p_id_usuario);
    
    -- Simular procesamiento largo (esperar 10 segundos)
    DBMS_OUTPUT.PUT_LINE('Procesando...');
    DBMS_LOCK.SLEEP(10);
    
    -- Actualizar
    UPDATE USUARIOS 
    SET id_plan = p_nuevo_plan 
    WHERE id_usuario = p_id_usuario;
    
    DBMS_OUTPUT.PUT_LINE('Actualizado a plan: ' || p_nuevo_plan);
    
    COMMIT;
END SP_BLOQUEO_EJEMPLO;
/

-- =============================================================================
-- VERIFICACIONES
-- =============================================================================

-- Mostrar errores de compilacion
SHOW ERRORS PROCEDURE SP_REGISTRO_COMPLETO_USUARIO;
SHOW ERRORS PROCEDURE SP_RENOVACION_MENSUAL;
SHOW ERRORS PROCEDURE SP_ELIMINAR_CUENTA;
SHOW ERRORS PROCEDURE SP_BLOQUEO_EJEMPLO;

-- =============================================================================
-- PRUEBAS DE TRANSACCIONES
-- =============================================================================

-- Prueba 1: Registro completo
DECLARE
    v_resultado NUMBER;
    v_mensaje VARCHAR2(200);
BEGIN
    SP_REGISTRO_COMPLETO_USUARIO(
        'Test Usuario', 'test@email.com', '3001111111',
        TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'Armenia', 1,
        NULL, v_resultado, v_mensaje
    );
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
END;
/

-- Limpiar usuario de prueba
DELETE FROM USUARIOS WHERE email = 'test@email.com';

-- Prueba 2: Renovacion mensual
DECLARE
    v_resultado NUMBER;
    v_mensaje VARCHAR2(200);
BEGIN
    SP_RENOVACION_MENSUAL(6, 2025, v_resultado, v_mensaje);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
END;
/

-- =============================================================================
-- DOCUMENTACION DEL ESCENARIO DE CONCURRENCIA
-- =============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('DOCUMENTACION: CONCURRENCIA EN ORACLE');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('ESCENARIO: Cambio de plan simultaneo');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.PUT_LINE('Objetivo: Demostrar bloqueo de fila (FOR UPDATE)');
    DBMS_OUTPUT.PUT_LINE('y manejo de concurrencia en Oracle.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Pasos para ejecutar:');
    DBMS_OUTPUT.PUT_LINE('1. SESION A: SELECT * FROM USUARIOS');
    DBMS_OUTPUT.PUT_LINE('   WHERE id_usuario = 5 FOR UPDATE;');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. SESION B: UPDATE USUARIOS SET');
    DBMS_OUTPUT.PUT_LINE('   id_plan = 2 WHERE id_usuario = 5;');
    DBMS_OUTPUT.PUT_LINE('   (Queda en espera)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. SESION A: COMMIT;');
    DBMS_OUTPUT.PUT_LINE('   (Sesion B se ejecuta)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Tipo de bloqueo:');
    DBMS_OUTPUT.PUT_LINE('- SELECT FOR UPDATE: Bloqueo exclusivo (RX)');
    DBMS_OUTPUT.PUT_LINE('- UPDATE: Bloqueo exclusivo (RX)');
    DBMS_OUTPUT.PUT_LINE('- Modo: WAIT (espera por defecto)');
    DBMS_OUTPUT.PUT_LINE('- NOWAIT: levanta error inmediatamente');
    DBMS_OUTPUT.PUT_LINE('- SKIP LOCK: salta fila bloqueada');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/