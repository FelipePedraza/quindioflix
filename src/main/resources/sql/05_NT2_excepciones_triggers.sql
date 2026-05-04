-- =============================================================================
-- QUINDIOFLIX - PL/SQL: Excepciones y Disparadores
-- Universidad del Quindío · Bases de Datos II 
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- =============================================================================
-- EXCEPCIONES PERSONALIZADAS
-- =============================================================================

-- Ya definidas en Sprint 4, aqui agregamos mas:

-- EX_PERFILES_EXCEDEN_PLAN (-20002)
-- EX_EMAIL_DUPLICADO (-20001)

-- Nuevas excepciones para triggers
CREATE OR REPLACE PROCEDURE SP_EXCEPCIONES_INICIALIZAR IS
    ex_cuenta_inactiva EXCEPTION;
    ex_perfil_infantil EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_cuenta_inactiva, -20010);
    PRAGMA EXCEPTION_INIT(ex_perfil_infantil, -20011);
BEGIN
    NULL;
END;
/

-- =============================================================================
-- DISPARADORES (TRIGGERS)
-- =============================================================================

-- TRG_VALIDAR_CUENTA_ACTIVA: Validar que la cuenta este activa antes de reproducir
CREATE OR REPLACE TRIGGER TRG_VALIDAR_CUENTA_ACTIVA
BEFORE INSERT ON REPRODUCCIONES
FOR EACH ROW
DECLARE
    v_estado_cuenta VARCHAR2(20);
    v_id_usuario NUMBER;
BEGIN
    SELECT p.id_usuario INTO v_id_usuario
    FROM PERFILES p
    WHERE p.id_perfil = :NEW.id_perfil;
    
    SELECT u.estado_cuenta INTO v_estado_cuenta
    FROM USUARIOS u
    WHERE u.id_usuario = v_id_usuario;
    
    IF v_estado_cuenta != 'ACTIVO' THEN
        RAISE_APPLICATION_ERROR(-20010, 
            'No se puede reproducir. La cuenta no esta activa. Estado: ' || v_estado_cuenta);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Perfil no encontrado');
END TRG_VALIDAR_CUENTA_ACTIVA;
/

-- TRG_LIMITE_PERFILES: Validar limite de perfiles segun plan
CREATE OR REPLACE TRIGGER TRG_LIMITE_PERFILES
BEFORE INSERT ON PERFILES
FOR EACH ROW
DECLARE
    v_perfiles_actuales NUMBER;
    v_max_pantallas NUMBER;
    v_id_usuario NUMBER;
BEGIN
    v_id_usuario := :NEW.id_usuario;
    
    SELECT COUNT(*), MAX(p.max_pantallas)
    INTO v_perfiles_actuales, v_max_pantallas
    FROM PERFILES pe
    JOIN USUARIOS u ON pe.id_usuario = u.id_usuario
    JOIN PLANES p ON u.id_plan = p.id_plan
    WHERE u.id_usuario = v_id_usuario;
    
    IF v_perfiles_actuales >= v_max_pantallas THEN
        RAISE_APPLICATION_ERROR(-20011, 
            'Limite de perfiles alcanzado. El plan permite ' || v_max_pantallas || 
            ' perfiles y ya tiene ' || v_perfiles_actuales);
    END IF;
END TRG_LIMITE_PERFILES;
/

-- TRG_VALIDAR_CALIFICACION: Validar que el perfil haya visto el contenido
CREATE OR REPLACE TRIGGER TRG_VALIDAR_CALIFICACION
BEFORE INSERT ON CALIFICACIONES
FOR EACH ROW
DECLARE
    v_existe_reproduccion NUMBER;
    v_porcentaje_min NUMBER := 50;
BEGIN
    SELECT COUNT(*)
    INTO v_existe_reproduccion
    FROM REPRODUCCIONES r
    WHERE r.id_perfil = :NEW.id_perfil
      AND r.id_contenido = :NEW.id_contenido
      AND r.porcentaje_avance >= v_porcentaje_min;
    
    IF v_existe_reproduccion = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 
            'Para calificar debe ver al menos el 50% del contenido');
    END IF;
END TRG_VALIDAR_CALIFICACION;
/

-- TRG_ACTIVAR_CUENTA_PAGO: Activar cuenta si el pago es exitoso
CREATE OR REPLACE TRIGGER TRG_ACTIVAR_CUENTA_PAGO
AFTER INSERT ON PAGOS
FOR EACH ROW
BEGIN
    IF :NEW.estado_pago = 'EXITOSO' THEN
        UPDATE USUARIOS 
        SET estado_cuenta = 'ACTIVO' 
        WHERE id_usuario = :NEW.id_usuario;
    END IF;
END TRG_ACTIVAR_CUENTA_PAGO;
/

-- TRG_RESTRICCION_PERFIL_INFANTIL: Validar contenido para infantiles
CREATE OR REPLACE TRIGGER TRG_RESTRICCION_PERFIL_INFANTIL
BEFORE INSERT ON REPRODUCCIONES
FOR EACH ROW
DECLARE
    v_tipo_perfil VARCHAR2(20);
    v_clasificacion VARCHAR2(10);
BEGIN
    SELECT p.tipo INTO v_tipo_perfil
    FROM PERFILES p
    WHERE p.id_perfil = :NEW.id_perfil;
    
    IF v_tipo_perfil = 'INFANTIL' THEN
        SELECT c.clasificacion_edad INTO v_clasificacion
        FROM CONTENIDO c
        WHERE c.id_contenido = :NEW.id_contenido;
        
        IF v_clasificacion IN ('+16', '+18') THEN
            RAISE_APPLICATION_ERROR(-20013, 
                'Perfil infantil no puede reproducir contenido ' || 
                'clasificado para mayores de ' || v_clasificacion);
        END IF;
    END IF;
END TRG_RESTRICCION_PERFIL_INFANTIL;
/

-- =============================================================================
-- VERIFICAR COMPILACION
-- =============================================================================

SELECT trigger_name, status 
FROM user_triggers 
WHERE trigger_name LIKE 'TRG_%';

-- =============================================================================
-- PRUEBAS DE TRIGGERS
-- =============================================================================

-- Prueba 1: Insertar reproduccion con cuenta INACTIVA (debe fallar)
-- Primero cambiar estado de usuario 10 a INACTIVO
UPDATE USUARIOS SET estado_cuenta = 'INACTIVO' WHERE id_usuario = 10;

-- Intentar reproducir (debe fallar con -20010)
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)
VALUES (28, 1, SYSDATE, SYSDATE + 1/24, 'CELULAR', 100);

-- Prueba 2: Intentar crear mas perfiles de los permitidos (debe fallar)
-- Usuario 1 tiene plan BASICO (max 2 perfiles), ya tiene 3
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (1, 'NuevoPerfil', 'ADULTO');

-- Prueba 3: Calificar contenido sin haberlo visto (debe fallar)
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion)
VALUES (1, 40, 5, SYSDATE);

-- Prueba 4: Insertar pago EXITOSO (debe activar cuenta)
-- Usuario 10 tiene cuenta inactiva, insertar pago exitoso
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)
VALUES (10, SYSDATE, 24990, 'TARJETA_CREDITO', 'EXITOSO', SYSDATE + 30);

-- Verificar estado de cuenta
SELECT id_usuario, nombre, estado_cuenta FROM USUARIOS WHERE id_usuario = 10;

-- Prueba 5: Perfil infantil trying to watch (+18) content
-- Insertar reproduccion con perfil infantil para contenido +18
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)
VALUES (2, 9, SYSDATE, SYSDATE + 1/24, 'TV', 100);

-- =============================================================================
--LIMPIEZA PARA PRUEBAS
-- =============================================================================

-- Restaurar estado de cuenta usuario 10
UPDATE USUARIOS SET estado_cuenta = 'ACTIVO' WHERE id_usuario = 10;

-- Eliminar registros de prueba
DELETE FROM REPRODUCCIONES WHERE id_contenido = 40;
DELETE FROM REPRODUCCIONES WHERE id_usuario = 10;
DELETE FROM PAGOS WHERE id_usuario = 10 AND monto = 24990;
DELETE FROM PERFILES WHERE id_usuario = 1 AND nombre = 'NuevoPerfil';

COMMIT;

-- =============================================================================
-- RESUMEN DE TRIGGERS CREADOS
-- =============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TRIGGERS CREADOS');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('1. TRG_VALIDAR_CUENTA_ACTIVA:');
    DBMS_OUTPUT.PUT_LINE('   - Valida cuenta ACTIVA antes de reproducir');
    DBMS_OUTPUT.PUT_LINE('   - Codigo error: -20010');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. TRG_LIMITE_PERFILES:');
    DBMS_OUTPUT.PUT_LINE('   - Valida limite de perfiles segun plan');
    DBMS_OUTPUT.PUT_LINE('   - Codigo error: -20011');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. TRG_VALIDAR_CALIFICACION:');
    DBMS_OUTPUT.PUT_LINE('   - Requiere 50% visto para calificar');
    DBMS_OUTPUT.PUT_LINE('   - Codigo error: -20012');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. TRG_ACTIVAR_CUENTA_PAGO:');
    DBMS_OUTPUT.PUT_LINE('   - Activa cuenta con pago EXITOSO');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('5. TRG_RESTRICCION_PERFIL_INFANTIL:');
    DBMS_OUTPUT.PUT_LINE('   - Restringe contenido +16/+18 para infants');
    DBMS_OUTPUT.PUT_LINE('   - Codigo error: -20013');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/