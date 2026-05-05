-- =============================================================================
-- 00_INICIO.sql
-- Crear usuario de la aplicación
-- EJECUTAR como SYS en SQL Developer
-- =============================================================================

-- 1. Crear usuario
CREATE USER C##quindioflix_owner IDENTIFIED BY quindioflix2025;

-- 2. Dar permisos
GRANT CONNECT TO C##quindioflix_owner;
GRANT RESOURCE TO C##quindioflix_owner;

-- 3. Dar quota
ALTER USER C##quindioflix_owner QUOTA UNLIMITED ON USERS;

-- Verificar
SELECT 'Usuario creado' AS resultado FROM dual;

-- Eliminar usuario (descomentar si se desea eliminar)
--DROP USER C##quindioflix_owner CASCADE;