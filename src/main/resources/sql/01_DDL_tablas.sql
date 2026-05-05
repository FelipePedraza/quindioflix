-- =============================================================================
-- QUINDIOFLIX - DDL: Creación del Modelo de Datos
-- Universidad del Quindío · Bases de Datos II
-- =============================================================================

-- =============================================================================
-- DOMINIO: PLANES Y USUARIOS
-- =============================================================================

-- Tabla PLANES
CREATE TABLE PLANES (
    id_plan NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    max_pantallas NUMBER(2) NOT NULL,
    calidad VARCHAR2(20) NOT NULL,
    precio_mes NUMBER(10, 2) NOT NULL,
    CONSTRAINT chk_plan_nombre CHECK (nombre IN ('BASICO', 'ESTANDAR', 'PREMIUM'))
);

COMMENT ON TABLE PLANES IS 'Planes de suscripción de QuindioFlix';
COMMENT ON COLUMN PLANES.id_plan IS 'Identificador único del plan';
COMMENT ON COLUMN PLANES.nombre IS 'Nombre del plan (BASICO, ESTANDAR, PREMIUM)';
COMMENT ON COLUMN PLANES.max_pantallas IS 'Cantidad máxima de perfiles simultáneos';
COMMENT ON COLUMN PLANES.calidad IS 'Calidad de streaming (SD, HD, 4K)';
COMMENT ON COLUMN PLANES.precio_mes IS 'Precio mensual del plan';

-- Tabla USUARIOS
CREATE TABLE USUARIOS (
    id_usuario NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    telefono VARCHAR2(20),
    fecha_nacimiento DATE NOT NULL,
    ciudad VARCHAR2(50) NOT NULL,
    fecha_registro DATE NOT NULL,
    estado_cuenta VARCHAR2(20) NOT NULL,
    id_plan NUMBER(10) NOT NULL,
    id_referidor NUMBER(10),
    CONSTRAINT fk_usuario_plan FOREIGN KEY (id_plan) REFERENCES PLANES(id_plan),
    CONSTRAINT fk_usuario_referidor FOREIGN KEY (id_referidor) REFERENCES USUARIOS(id_usuario),
    CONSTRAINT chk_estado_cuenta CHECK (estado_cuenta IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO'))
);

COMMENT ON TABLE USUARIOS IS 'Usuarios registrados en la plataforma';
COMMENT ON COLUMN USUARIOS.id_usuario IS 'Identificador único del usuario';
COMMENT ON COLUMN USUARIOS.nombre IS 'Nombre completo del usuario';
COMMENT ON COLUMN USUARIOS.email IS 'Correo electrónico único del usuario';
COMMENT ON COLUMN USUARIOS.telefono IS 'Número de teléfono de contacto';
COMMENT ON COLUMN USUARIOS.fecha_nacimiento IS 'Fecha de nacimiento';
COMMENT ON COLUMN USUARIOS.ciudad IS 'Ciudad de residencia';
COMMENT ON COLUMN USUARIOS.fecha_registro IS 'Fecha de registro en la plataforma';
COMMENT ON COLUMN USUARIOS.estado_cuenta IS 'Estado de la cuenta (ACTIVO, INACTIVO, SUSPENDIDO)';
COMMENT ON COLUMN USUARIOS.id_plan IS 'Plan de suscripción actual';
COMMENT ON COLUMN USUARIOS.id_referidor IS 'Usuario que referenció (auto-referencia)';

-- Tabla PERFILES
CREATE TABLE PERFILES (
    id_perfil NUMBER(10) PRIMARY KEY,
    id_usuario NUMBER(10) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    avatar BLOB,
    tipo VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_perfil_tipo CHECK (tipo IN ('ADULTO', 'INFANTIL'))
);

COMMENT ON TABLE PERFILES IS 'Perfiles de usuario dentro de una cuenta';
COMMENT ON COLUMN PERFILES.id_perfil IS 'Identificador único del perfil';
COMMENT ON COLUMN PERFILES.id_usuario IS 'Usuario padre al que pertenece el perfil';
COMMENT ON COLUMN PERFILES.nombre IS 'Nombre del perfil';
COMMENT ON COLUMN PERFILES.avatar IS 'Imagen de avatar del perfil';
COMMENT ON COLUMN PERFILES.tipo IS 'Tipo de perfil (ADULTO, INFANTIL)';

-- =============================================================================
-- DOMINIO: CONTENIDO
-- =============================================================================

-- Tabla CATEGORIAS
CREATE TABLE CATEGORIAS (
    id_categoria NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_categoria_nombre CHECK (nombre IN ('PELICULAS', 'SERIES', 'DOCUMENTALES', 'MUSICA', 'PODCASTS'))
);

COMMENT ON TABLE CATEGORIAS IS 'Categorías del contenido audiovisual';
COMMENT ON COLUMN CATEGORIAS.id_categoria IS 'Identificador único de la categoría';
COMMENT ON COLUMN CATEGORIAS.nombre IS 'Nombre de la categoría';

-- Tabla GENEROS
CREATE TABLE GENEROS (
    id_genero NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL UNIQUE
);

COMMENT ON TABLE GENEROS IS 'Géneros del contenido';
COMMENT ON COLUMN GENEROS.id_genero IS 'Identificador único del género';
COMMENT ON COLUMN GENEROS.nombre IS 'Nombre del género';

-- Tabla CONTENIDO
CREATE TABLE CONTENIDO (
    id_contenido NUMBER(10) PRIMARY KEY,
    titulo VARCHAR2(200) NOT NULL,
    anio_lanzamiento NUMBER(4) NOT NULL,
    duracion_min NUMBER(5),
    sinopsis CLOB,
    clasificacion_edad VARCHAR2(10) NOT NULL,
    fecha_catalogo DATE NOT NULL,
    es_original CHAR(1),
    id_categoria NUMBER(10) NOT NULL,
    id_empleado_responsable NUMBER(10),
    popularidad NUMBER(5),
    CONSTRAINT fk_contenido_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria),
    CONSTRAINT chk_clasificacion CHECK (clasificacion_edad IN ('TP', '+7', '+13', '+16', '+18')),
    CONSTRAINT chk_es_original CHECK (es_original IN ('S', 'N'))
);

COMMENT ON TABLE CONTENIDO IS 'Catálogo de contenido audiovisual';
COMMENT ON COLUMN CONTENIDO.id_contenido IS 'Identificador único del contenido';
COMMENT ON COLUMN CONTENIDO.titulo IS 'Título del contenido';
COMMENT ON COLUMN CONTENIDO.anio_lanzamiento IS 'Año de lanzamiento';
COMMENT ON COLUMN CONTENIDO.duracion_min IS 'Duración en minutos';
COMMENT ON COLUMN CONTENIDO.sinopsis IS 'Sinopsis o descripción del contenido';
COMMENT ON COLUMN CONTENIDO.clasificacion_edad IS 'Clasificación por edad (TP, +7, +13, +16, +18)';
COMMENT ON COLUMN CONTENIDO.fecha_catalogo IS 'Fecha de inclusión al catálogo';
COMMENT ON COLUMN CONTENIDO.es_original IS 'Indica si es contenido original de QuindioFlix (S/N)';
COMMENT ON COLUMN CONTENIDO.id_categoria IS 'Categoría a la que pertenece';
COMMENT ON COLUMN CONTENIDO.id_empleado_responsable IS 'Empleado responsable del contenido';
COMMENT ON COLUMN CONTENIDO.popularidad IS 'Puntuación de popularidad basada en reproducciones';

-- Tabla RELACIÓN N:M CONTENIDO_GENERO
CREATE TABLE CONTENIDO_GENERO (
    id_contenido NUMBER(10) NOT NULL,
    id_genero NUMBER(10) NOT NULL,
    CONSTRAINT pk_contenido_genero PRIMARY KEY (id_contenido, id_genero),
    CONSTRAINT fk_cg_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT fk_cg_genero FOREIGN KEY (id_genero) REFERENCES GENEROS(id_genero)
);

COMMENT ON TABLE CONTENIDO_GENERO IS 'Relación N:M entre contenido y géneros';
COMMENT ON COLUMN CONTENIDO_GENERO.id_contenido IS 'Identificador del contenido';
COMMENT ON COLUMN CONTENIDO_GENERO.id_genero IS 'Identificador del género';

-- Tabla RELACIÓN REFLEXIVA CONTENIDO_RELACIONADO
CREATE TABLE CONTENIDO_RELACIONADO (
    id_contenido NUMBER(10) NOT NULL,
    id_contenido_rel NUMBER(10) NOT NULL,
    tipo_relacion VARCHAR2(30) NOT NULL,
    CONSTRAINT pk_contenido_relacionado PRIMARY KEY (id_contenido, id_contenido_rel),
    CONSTRAINT fk_cr_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT fk_cr_contenido_rel FOREIGN KEY (id_contenido_rel) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT chk_tipo_relacion CHECK (tipo_relacion IN ('SECUELA', 'PRECUELA', 'REMAKE', 'SPIN_OFF', 'VERSION_EXTENDIDA')),
    CONSTRAINT chk_no_auto CHECK (id_contenido <> id_contenido_rel)
);

COMMENT ON TABLE CONTENIDO_RELACIONADO IS 'Relaciones entre contenidos (secuelas, precuelas, remakes, etc.)';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.id_contenido IS 'Contenido principal';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.id_contenido_rel IS 'Contenido relacionado';
COMMENT ON COLUMN CONTENIDO_RELACIONADO.tipo_relacion IS 'Tipo de relación';

-- Tabla TEMPORADAS
CREATE TABLE TEMPORADAS (
    id_temporada NUMBER(10) PRIMARY KEY,
    id_contenido NUMBER(10) NOT NULL,
    numero_temporada NUMBER(2) NOT NULL,
    titulo VARCHAR2(100),
    CONSTRAINT fk_temporada_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE
);

COMMENT ON TABLE TEMPORadas IS 'Temporadas de series y podcasts';
COMMENT ON COLUMN TEMPORADAS.id_temporada IS 'Identificador único de la temporada';
COMMENT ON COLUMN TEMPORADAS.id_contenido IS 'Serie o podcast al que pertenece';
COMMENT ON COLUMN TEMPORADAS.numero_temporada IS 'Número de temporada';
COMMENT ON COLUMN TEMPORADAS.titulo IS 'Título de la temporada';

-- Tabla EPISODIOS
CREATE TABLE EPISODIOS (
    id_episodio NUMBER(10) PRIMARY KEY,
    id_temporada NUMBER(10) NOT NULL,
    numero_episodio NUMBER(3) NOT NULL,
    titulo VARCHAR2(100) NOT NULL,
    duracion_min NUMBER(5),
    CONSTRAINT fk_episodio_temporada FOREIGN KEY (id_temporada) REFERENCES TEMPORADAS(id_temporada) ON DELETE CASCADE
);

COMMENT ON TABLE EPISODIOS IS 'Episodios de las temporadas';
COMMENT ON COLUMN EPISODIOS.id_episodio IS 'Identificador único del episodio';
COMMENT ON COLUMN EPISODIOS.id_temporada IS 'Temporada a la que pertenece';
COMMENT ON COLUMN EPISODIOS.numero_episodio IS 'Número del episodio';
COMMENT ON COLUMN EPISODIOS.titulo IS 'Título del episodio';
COMMENT ON COLUMN EPISODIOS.duracion_min IS 'Duración en minutos';

-- =============================================================================
-- DOMINIO: EMPLEADOS
-- =============================================================================

-- Tabla DEPARTAMENTOS (sin FK, se agregara despues)
CREATE TABLE DEPARTAMENTOS (
    id_departamento NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL UNIQUE,
    id_jefe NUMBER(10)
);

COMMENT ON TABLE DEPARTAMENTOS IS 'Departamentos de la empresa';
COMMENT ON COLUMN DEPARTAMENTOS.id_departamento IS 'Identificador único del departamento';
COMMENT ON COLUMN DEPARTAMENTOS.nombre IS 'Nombre del departamento';
COMMENT ON COLUMN DEPARTAMENTOS.id_jefe IS 'Empleado jefe del departamento';

-- Tabla EMPLEADOS
CREATE TABLE EMPLEADOS (
    id_empleado NUMBER(10) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    id_departamento NUMBER(10),
    id_supervisor NUMBER(10),
    rol VARCHAR2(20) NOT NULL,
    CONSTRAINT fk_empleado_departamento FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTOS(id_departamento),
    CONSTRAINT fk_empleado_supervisor FOREIGN KEY (id_supervisor) REFERENCES EMPLEADOS(id_empleado),
    CONSTRAINT chk_rol_empleado CHECK (rol IN ('CONTENIDO', 'SOPORTE', 'MODERADOR', 'ADMIN', 'ANALISTA', 'MARKETING', 'FINANZAS'))
);

COMMENT ON TABLE EMPLEADOS IS 'Empleados de QuindioFlix';
COMMENT ON COLUMN EMPLEADOS.id_empleado IS 'Identificador único del empleado';
COMMENT ON COLUMN EMPLEADOS.nombre IS 'Nombre completo del empleado';
COMMENT ON COLUMN EMPLEADOS.email IS 'Correo electrónico institucional';
COMMENT ON COLUMN EMPLEADOS.id_departamento IS 'Departamento al que pertence';
COMMENT ON COLUMN EMPLEADOS.id_supervisor IS 'Supervisor directo (auto-referencia)';
COMMENT ON COLUMN EMPLEADOS.rol IS 'Rol del empleado en el sistema';

-- Agregar FK deferrable para DEPARTAMENTOS.id_jefe después de crear EMPLEADOS
ALTER TABLE DEPARTAMENTOS
ADD CONSTRAINT fk_departamento_jefe FOREIGN KEY (id_jefe) REFERENCES EMPLEADOS(id_empleado) DEFERRABLE INITIALLY DEFERRED;

-- Agregar FK deferrable para CONTENIDO.id_empleado_responsable
ALTER TABLE CONTENIDO
ADD CONSTRAINT fk_contenido_empleado FOREIGN KEY (id_empleado_responsable) REFERENCES EMPLEADOS(id_empleado) DEFERRABLE INITIALLY DEFERRED;

-- =============================================================================
-- DOMINIO: CONSUMO Y PAGOS
-- =============================================================================

-- Tabla REPRODUCCIONES (Particionada por rango de fecha)
CREATE TABLE REPRODUCCIONES (
    id_reproduccion NUMBER(10) PRIMARY KEY,
    id_perfil NUMBER(10) NOT NULL,
    id_contenido NUMBER(10) NOT NULL,
    id_episodio NUMBER(10),
    fecha_hora_inicio DATE NOT NULL,
    fecha_hora_fin DATE,
    dispositivo VARCHAR2(20) NOT NULL,
    porcentaje_avance NUMBER(5, 2),
    CONSTRAINT fk_reproduccion_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil) ON DELETE CASCADE,
    CONSTRAINT fk_reproduccion_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT fk_reproduccion_episodio FOREIGN KEY (id_episodio) REFERENCES EPISODIOS(id_episodio),
    CONSTRAINT chk_dispositivo CHECK (dispositivo IN ('CELULAR', 'TABLET', 'TV', 'COMPUTADOR')),
    CONSTRAINT chk_avance CHECK (porcentaje_avance >= 0 AND porcentaje_avance <= 100)
)

PARTITION BY RANGE (fecha_hora_inicio) (
    PARTITION TS_REPRO_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION TS_REPRO_2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD')),
    PARTITION TS_REPRO_2026 VALUES LESS THAN (MAXVALUE)
);

COMMENT ON TABLE REPRODUCCIONES IS 'Registro de reproducciones de contenido por perfiles';
COMMENT ON COLUMN REPRODUCCIONES.id_reproduccion IS 'Identificador único de la reproducción';
COMMENT ON COLUMN REPRODUCCIONES.id_perfil IS 'Perfil que reprodujo el contenido';
COMMENT ON COLUMN REPRODUCCIONES.id_contenido IS 'Contenido reproducido';
COMMENT ON COLUMN REPRODUCCIONES.id_episodio IS 'Episodio reproducido (nullable, solo para series)';
COMMENT ON COLUMN REPRODUCCIONES.fecha_hora_inicio IS 'Fecha y hora de inicio de reproducción';
COMMENT ON COLUMN REPRODUCCIONES.fecha_hora_fin IS 'Fecha y hora de fin de reproducción';
COMMENT ON COLUMN REPRODUCCIONES.dispositivo IS 'Dispositivo usado para reproducir';
COMMENT ON COLUMN REPRODUCCIONES.porcentaje_avance IS 'Porcentaje de avance (0-100)';

-- Tabla FAVORITOS
CREATE TABLE FAVORITOS (
    id_favorito NUMBER(10) PRIMARY KEY,
    id_perfil NUMBER(10) NOT NULL,
    id_contenido NUMBER(10) NOT NULL,
    fecha_agregado DATE NOT NULL,
    CONSTRAINT fk_favorito_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil) ON DELETE CASCADE,
    CONSTRAINT fk_favorito_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT uk_favorito_perfil_contenido UNIQUE (id_perfil, id_contenido)
);

COMMENT ON TABLE FAVORITOS IS 'Contenidos marcados como favoritos por perfiles';
COMMENT ON COLUMN FAVORITOS.id_favorito IS 'Identificador único del favorito';
COMMENT ON COLUMN FAVORITOS.id_perfil IS 'Perfil que agregó el favorito';
COMMENT ON COLUMN FAVORITOS.id_contenido IS 'Contenido marcado como favorito';
COMMENT ON COLUMN FAVORITOS.fecha_agregado IS 'Fecha de inclusión a favoritos';

-- Tabla CALIFICACIONES
CREATE TABLE CALIFICACIONES (
    id_calificacion NUMBER(10) PRIMARY KEY,
    id_perfil NUMBER(10) NOT NULL,
    id_contenido NUMBER(10) NOT NULL,
    estrellas NUMBER(1) NOT NULL,
    reseña CLOB,
    fecha_calificacion DATE NOT NULL,
    CONSTRAINT fk_calificacion_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil) ON DELETE CASCADE,
    CONSTRAINT fk_calificacion_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT uk_calificacion_perfil_contenido UNIQUE (id_perfil, id_contenido),
    CONSTRAINT chk_estrellas CHECK (estrellas BETWEEN 1 AND 5)
);

COMMENT ON TABLE CALIFICACIONES IS 'Calificaciones y reseñas de contenido';
COMMENT ON COLUMN CALIFICACIONES.id_calificacion IS 'Identificador único de la calificación';
COMMENT ON COLUMN CALIFICACIONES.id_perfil IS 'Perfil que calificó';
COMMENT ON COLUMN CALIFICACIONES.id_contenido IS 'Contenido calificado';
COMMENT ON COLUMN CALIFICACIONES.estrellas IS 'Calificación (1-5 estrellas)';
COMMENT ON COLUMN CALIFICACIONES.reseña IS 'Reseña escrita por el usuario';
COMMENT ON COLUMN CALIFICACIONES.fecha_calificacion IS 'Fecha de la calificación';

-- Tabla PAGOS
CREATE TABLE PAGOS (
    id_pago NUMBER(10) PRIMARY KEY,
    id_usuario NUMBER(10) NOT NULL,
    fecha_pago DATE NOT NULL,
    monto NUMBER(10, 2) NOT NULL,
    metodo_pago VARCHAR2(20) NOT NULL,
    estado_pago VARCHAR2(20) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    CONSTRAINT fk_pago_usuario FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('TARJETA_CREDITO', 'TARJETA_DEBITO', 'PSE', 'NEQUI', 'DAVIPLATA')),
    CONSTRAINT chk_estado_pago CHECK (estado_pago IN ('EXITOSO', 'FALLIDO', 'PENDIENTE', 'REEMBOLSADO'))
);

COMMENT ON TABLE PAGOS IS 'Historial de pagos de suscripciones';
COMMENT ON COLUMN PAGOS.id_pago IS 'Identificador único del pago';
COMMENT ON COLUMN PAGOS.id_usuario IS 'Usuario que realizó el pago';
COMMENT ON COLUMN PAGOS.fecha_pago IS 'Fecha de realización del pago';
COMMENT ON COLUMN PAGOS.monto IS 'Monto pagado';
COMMENT ON COLUMN PAGOS.metodo_pago IS 'Método de pago utilizado';
COMMENT ON COLUMN PAGOS.estado_pago IS 'Estado del pago';
COMMENT ON COLUMN PAGOS.fecha_vencimiento IS 'Fecha de vencimiento de la suscripción';

-- Tabla REPORTES_CONTENIDO
CREATE TABLE REPORTES_CONTENIDO (
    id_reporte NUMBER(10) PRIMARY KEY,
    id_perfil NUMBER(10) NOT NULL,
    id_contenido NUMBER(10) NOT NULL,
    descripcion CLOB NOT NULL,
    fecha_reporte DATE NOT NULL,
    estado VARCHAR2(20) NOT NULL,
    id_moderador NUMBER(10),
    fecha_resolucion DATE,
    CONSTRAINT fk_reporte_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil) ON DELETE CASCADE,
    CONSTRAINT fk_reporte_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido) ON DELETE CASCADE,
    CONSTRAINT fk_reporte_moderador FOREIGN KEY (id_moderador) REFERENCES EMPLEADOS(id_empleado),
    CONSTRAINT chk_estado_reporte CHECK (estado IN ('PENDIENTE', 'EN_REVISION', 'RESUELTO', 'RECHAZADO'))
);

COMMENT ON TABLE REPORTES_CONTENIDO IS 'Reportes de contenido por usuarios';
COMMENT ON COLUMN REPORTES_CONTENIDO.id_reporte IS 'Identificador único del reporte';
COMMENT ON COLUMN REPORTES_CONTENIDO.id_reporte IS 'Perfil que reporta';
COMMENT ON COLUMN REPORTES_CONTENIDO.id_contenido IS 'Contenido reportado';
COMMENT ON COLUMN REPORTES_CONTENIDO.descripcion IS 'Descripción del reporte';
COMMENT ON COLUMN REPORTES_CONTENIDO.fecha_reporte IS 'Fecha de creación del reporte';
COMMENT ON COLUMN REPORTES_CONTENIDO.estado IS 'Estado del reporte';
COMMENT ON COLUMN REPORTES_CONTENIDO.id_moderador IS 'Moderador que atiende el reporte';
COMMENT ON COLUMN REPORTES_CONTENIDO.fecha_resolucion IS 'Fecha de resolución del reporte';

-- =============================================================================
-- SECUENCIAS PARA IDs AUTOINCREMENTALES
-- =============================================================================

CREATE SEQUENCE SEQ_PLANES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_USUARIOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PERFILES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CATEGORIAS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_GENEROS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CONTENIDO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_TEMPORADAS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_EPISODIOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_DEPARTAMENTOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_EMPLEADOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_REPRODUCCIONES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_FAVORITOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_CALIFICACIONES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PAGOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_REPORTES START WITH 1 INCREMENT BY 1;

-- =============================================================================
-- TRIGGERS PARA AUTOINCREMENTO
-- =============================================================================

CREATE OR REPLACE TRIGGER TRG_PLANES_ID
BEFORE INSERT ON PLANES FOR EACH ROW
BEGIN
    :NEW.id_plan := SEQ_PLANES.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_USUARIOS_ID
BEFORE INSERT ON USUARIOS FOR EACH ROW
BEGIN
    :NEW.id_usuario := SEQ_USUARIOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_PERFILES_ID
BEFORE INSERT ON PERFILES FOR EACH ROW
BEGIN
    :NEW.id_perfil := SEQ_PERFILES.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_CATEGORIAS_ID
BEFORE INSERT ON CATEGORIAS FOR EACH ROW
BEGIN
    :NEW.id_categoria := SEQ_CATEGORIAS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_GENEROS_ID
BEFORE INSERT ON GENEROS FOR EACH ROW
BEGIN
    :NEW.id_genero := SEQ_GENEROS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_CONTENIDO_ID
BEFORE INSERT ON CONTENIDO FOR EACH ROW
BEGIN
    :NEW.id_contenido := SEQ_CONTENIDO.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_TEMPORADAS_ID
BEFORE INSERT ON TEMPORADAS FOR EACH ROW
BEGIN
    :NEW.id_temporada := SEQ_TEMPORADAS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_EPISODIOS_ID
BEFORE INSERT ON EPISODIOS FOR EACH ROW
BEGIN
    :NEW.id_episodio := SEQ_EPISODIOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_DEPARTAMENTOS_ID
BEFORE INSERT ON DEPARTAMENTOS FOR EACH ROW
BEGIN
    :NEW.id_departamento := SEQ_DEPARTAMENTOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_EMPLEADOS_ID
BEFORE INSERT ON EMPLEADOS FOR EACH ROW
BEGIN
    :NEW.id_empleado := SEQ_EMPLEADOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_REPRODUCCIONES_ID
BEFORE INSERT ON REPRODUCCIONES FOR EACH ROW
BEGIN
    :NEW.id_reproduccion := SEQ_REPRODUCCIONES.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_FAVORITOS_ID
BEFORE INSERT ON FAVORITOS FOR EACH ROW
BEGIN
    :NEW.id_favorito := SEQ_FAVORITOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_CALIFICACIONES_ID
BEFORE INSERT ON CALIFICACIONES FOR EACH ROW
BEGIN
    :NEW.id_calificacion := SEQ_CALIFICACIONES.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_PAGOS_ID
BEFORE INSERT ON PAGOS FOR EACH ROW
BEGIN
    :NEW.id_pago := SEQ_PAGOS.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER TRG_REPORTES_ID
BEFORE INSERT ON REPORTES_CONTENIDO FOR EACH ROW
BEGIN
    :NEW.id_reporte := SEQ_REPORTES.NEXTVAL;
END;
/

-- =============================================================================
-- VERIFICACIÓN
-- =============================================================================

SELECT table_name FROM user_tables ORDER BY table_name;