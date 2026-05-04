-- =============================================================================
-- QUINDIOFLIX - DML: Datos de Prueba
-- Universidad del Quindío · Bases de Datos II
-- =============================================================================

SET DEFINE OFF;

-- =============================================================================
-- INSERTAR PLANES
-- =============================================================================
INSERT INTO PLANES (nombre, max_pantallas, calidad, precio_mes) VALUES ('BASICO', 2, 'SD', 12990);
INSERT INTO PLANES (nombre, max_pantallas, calidad, precio_mes) VALUES ('ESTANDAR', 3, 'HD', 18990);
INSERT INTO PLANES (nombre, max_pantallas, calidad, precio_mes) VALUES ('PREMIUM', 5, '4K', 24990);

-- =============================================================================
-- INSERTAR CATEGORÍAS
-- =============================================================================
INSERT INTO CATEGORIAS (nombre) VALUES ('PELICULAS');
INSERT INTO CATEGORIAS (nombre) VALUES ('SERIES');
INSERT INTO CATEGORIAS (nombre) VALUES ('DOCUMENTALES');
INSERT INTO CATEGORIAS (nombre) VALUES ('MUSICA');
INSERT INTO CATEGORIAS (nombre) VALUES ('PODCASTS');

-- =============================================================================
-- INSERTAR GÉNEROS
-- =============================================================================
INSERT INTO GENEROS (nombre) VALUES ('ACCION');
INSERT INTO GENEROS (nombre) VALUES ('COMEDIA');
INSERT INTO GENEROS (nombre) VALUES ('DRAMA');
INSERT INTO GENEROS (nombre) VALUES ('TERROR');
INSERT INTO GENEROS (nombre) VALUES ('CIENCIA_FICCION');
INSERT INTO GENEROS (nombre) VALUES ('ROMANCE');
INSERT INTO GENEROS (nombre) VALUES ('DOCUMENTAL');
INSERT INTO GENEROS (nombre) VALUES ('ANIMACION');
INSERT INTO GENEROS (nombre) VALUES ('MUSICAL');
INSERT INTO GENEROS (nombre) VALUES ('SUSPENSO');
INSERT INTO GENEROS (nombre) VALUES ('AVENTURA');
INSERT INTO GENEROS (nombre) VALUES ('MISTERIO');

-- =============================================================================
-- INSERTAR DEPARTAMENTOS
-- =============================================================================
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('CONTENIDO');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('SOPORTE_TECNICO');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('MODERACION');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('MARKETING');
INSERT INTO DEPARTAMENTOS (nombre) VALUES ('FINANZAS');

-- =============================================================================
-- INSERTAR EMPLEADOS
-- =============================================================================
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Carlos Mendoza', 'carlos.mendoza@quindioflix.com', 1, 'CONTENIDO');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Ana Lopez', 'ana.lopez@quindioflix.com', 1, 'CONTENIDO');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Jorge Ruiz', 'jorge.ruiz@quindioflix.com', 1, 'ADMIN');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Maria Gonzalez', 'maria.gonzalez@quindioflix.com', 2, 'SOPORTE');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Luis Perez', 'luis.perez@quindioflix.com', 2, 'SOPORTE');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Sofia Castro', 'sofia.castro@quindioflix.com', 2, 'ADMIN');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Diego Hernandez', 'diego.hernandez@quindioflix.com', 3, 'MODERADOR');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Laura Martinez', 'laura.martinez@quindioflix.com', 3, 'MODERADOR');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Andres Torres', 'andres.torres@quindioflix.com', 3, 'ADMIN');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Carmen Diaz', 'carmen.diaz@quindioflix.com', 4, 'MARKETING');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Ricardo Sanchez', 'ricardo.sanchez@quindioflix.com', 4, 'MARKETING');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Patricia Moreno', 'patricia.moreno@quindioflix.com', 4, 'ANALISTA');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Fernando Gil', 'fernando.gil@quindioflix.com', 5, 'FINANZAS');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Isabel Romero', 'isabel.romero@quindioflix.com', 5, 'FINANZAS');
INSERT INTO EMPLEADOS (nombre, email, id_departamento, rol) VALUES ('Roberto Arias', 'roberto.arias@quindioflix.com', 5, 'ADMIN');

-- Actualizar Jefes de Departamento
UPDATE DEPARTAMENTOS SET id_jefe = 3 WHERE id_departamento = 1;
UPDATE DEPARTAMENTOS SET id_jefe = 6 WHERE id_departamento = 2;
UPDATE DEPARTAMENTOS SET id_jefe = 9 WHERE id_departamento = 3;
UPDATE DEPARTAMENTOS SET id_jefe = 12 WHERE id_departamento = 4;
UPDATE DEPARTAMENTOS SET id_jefe = 15 WHERE id_departamento = 5;

-- Actualizar supervisores
UPDATE EMPLEADOS SET id_supervisor = 3 WHERE id_empleado IN (1, 2);
UPDATE EMPLEADOS SET id_supervisor = 6 WHERE id_empleado IN (4, 5);
UPDATE EMPLEADOS SET id_supervisor = 9 WHERE id_empleado IN (7, 8);
UPDATE EMPLEADOS SET id_supervisor = 12 WHERE id_empleado IN (10, 11);
UPDATE EMPLEADOS SET id_supervisor = 15 WHERE id_empleado IN (13, 14);

COMMIT;

-- =============================================================================
-- INSERTAR USUARIOS (30)
-- Armenia: 12, Cali: 10, Bogota: 8
-- Basico: 10, Estandar: 12, Premium: 8
-- =============================================================================

-- Armenia (12)
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Juan Pablo Torres', 'juan.torres@email.com', '3101234567', TO_DATE('1985-03-15', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Maria Camila Garcia', 'maria.garcia@email.com', '3102345678', TO_DATE('1990-07-22', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Carlos Lopez', 'carlos.lopez@email.com', '3103456789', TO_DATE('1988-11-10', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-03-12', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Ana Sofia Moreno', 'ana.moreno@email.com', '3104567890', TO_DATE('1995-05-03', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Luis Fernando Rojas', 'luis.rojas@email.com', '3105678901', TO_DATE('1982-09-25', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-05-20', 'YYYY-MM-DD'), 'ACTIVO', 2, 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Carmen Lite', 'carmen.lite@email.com', '3106789012', TO_DATE('1992-12-08', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-06-15', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Daniel Castro', 'daniel.castro@email.com', '3107890123', TO_DATE('1987-04-30', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-07-22', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Laura Vanessa Diaz', 'laura.diaz@email.com', '3108901234', TO_DATE('1993-08-14', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-08-10', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Andres Felipe Mejia', 'andres.mejia@email.com', '3109012345', TO_DATE('1991-02-28', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-09-05', 'YYYY-MM-DD'), 'ACTIVO', 2, 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Patricia Soto', 'patricia.soto@email.com', '3110123456', TO_DATE('1989-06-18', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-10-12', 'YYYY-MM-DD'), 'INACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Roberto Navarro', 'roberto.navarro@email.com', '3111234567', TO_DATE('1984-10-05', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-11-20', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Isabel Cristina Beltran', 'isabel.beltran@email.com', '3112345678', TO_DATE('1996-01-12', 'YYYY-MM-DD'), 'Armenia', TO_DATE('2024-12-08', 'YYYY-MM-DD'), 'ACTIVO', 2, 5);

-- Cali (10)
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Santiago Agudelo', 'santiago.agudelo@email.com', '3151234567', TO_DATE('1990-03-20', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-01-25', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Valentina Torres', 'valentina.torres@email.com', '3152345678', TO_DATE('1994-07-15', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-02-18', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Mateo Hernandez', 'mateo.hernandez@email.com', '3153456789', TO_DATE('1986-11-22', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Natalia Ramirez', 'natalia.ramirez@email.com', '3154567890', TO_DATE('1992-04-08', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-04-30', 'YYYY-MM-DD'), 'ACTIVO', 2, 13);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('David Salazar', 'david.salazar@email.com', '3155678901', TO_DATE('1988-08-30', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-05-15', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Mariana Londono', 'mariana.londono@email.com', '3156789012', TO_DATE('1993-12-03', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-06-22', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Alejandro Jimenez', 'alejandro.jimenez@email.com', '3157890123', TO_DATE('1991-05-17', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-07-10', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Gabriela Munera', 'gabriela.munera@email.com', '3158901234', TO_DATE('1989-09-25', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-08-28', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Emmanuel Vargas', 'emmanuel.vargas@email.com', '3159012345', TO_DATE('1995-02-10', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-09-15', 'YYYY-MM-DD'), 'ACTIVO', 2, 15);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Sofia Cuellar', 'sofia.cuellar@email.com', '3150123456', TO_DATE('1987-06-28', 'YYYY-MM-DD'), 'Cali', TO_DATE('2024-10-22', 'YYYY-MM-DD'), 'SUSPENDIDO', 3);

-- Bogota (8)
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Miguel Angel Reyes', 'miguel.reyes@email.com', '3201234567', TO_DATE('1983-04-12', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Daniela Moreno', 'daniela.moreno@email.com', '3202345678', TO_DATE('1991-08-05', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-02-28', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor) VALUES ('Sergio Parra', 'sergio.parra@email.com', '3203456789', TO_DATE('1986-12-18', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-03-15', 'YYYY-MM-DD'), 'ACTIVO', 2, 20);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Jessica Garcia', 'jessica.garcia@email.com', '3204567890', TO_DATE('1994-01-22', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Edgar Cruz', 'edgar.cruz@email.com', '3205678901', TO_DATE('1989-07-08', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-05-28', 'YYYY-MM-DD'), 'ACTIVO', 3);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Katherine Bohorquez', 'katherine.bohorquez@email.com', '3206789012', TO_DATE('1992-11-30', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-06-12', 'YYYY-MM-DD'), 'ACTIVO', 1);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Cristian Vega', 'cristian.vega@email.com', '3207890123', TO_DATE('1988-03-14', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-07-25', 'YYYY-MM-DD'), 'ACTIVO', 2);
INSERT INTO USUARIOS (nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan) VALUES ('Yesenia Vargas', 'yesenia.vargas@email.com', '3208901234', TO_DATE('1990-09-05', 'YYYY-MM-DD'), 'Bogota', TO_DATE('2024-08-18', 'YYYY-MM-DD'), 'ACTIVO', 3);

COMMIT;

-- =============================================================================
-- INSERTAR PERFILES (55)
-- =============================================================================
-- Usuario 1 (3 perfiles)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (1, 'Juan', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (1, 'Sofia', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (1, 'Mateo', 'INFANTIL');

-- Usuario 2 (2)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (2, 'Cami', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (2, 'Benja', 'INFANTIL');

-- Usuario 3 (4)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (3, 'Carlitos', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (3, 'Paula', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (3, 'Lucas', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (3, 'Emilia', 'INFANTIL');

-- Usuario 4 (2)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (4, 'Anita', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (4, 'Valen', 'INFANTIL');

-- Usuario 5 (3)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (5, 'Lufe', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (5, 'Maria', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (5, 'Tomas', 'INFANTIL');

-- Usuario 6-30 (perfiles variados)
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (6, 'Carmen', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (6, 'Diego', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (7, 'Dani', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (7, 'Noah', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (8, 'Lau', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (8, 'Sofia', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (8, 'Samuel', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (9, 'Andres', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (9, 'Isabella', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (10, 'Patty', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (11, 'Rober', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (11, 'Alejandro', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (12, 'Isa', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (12, 'Vicente', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (13, 'Santi', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (13, 'Ana', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (13, 'Natalia', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (13, 'Juan', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (14, 'Vale', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (14, 'Matias', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (15, 'Mateo', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (15, 'Camila', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (15, 'Luis', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (16, 'Natalia', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (16, 'Emma', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (17, 'David', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (17, 'Martina', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (18, 'Mari', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (18, 'Sara', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (18, 'Daniel', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (19, 'Alejo', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (19, 'Maria', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (20, 'Gaby', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (20, 'Juan', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (21, 'Emma', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (21, 'Gabriel', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (22, 'Sofia', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (23, 'Miguel', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (23, 'Laura', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (23, 'Carlos', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (24, 'Dani', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (24, 'Luz', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (25, 'Sergio', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (25, 'Elena', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (26, 'Jessi', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (26, 'Santiago', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (27, 'Edgar', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (27, 'Valentina', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (27, 'Alex', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (28, 'Kathy', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (28, 'Adrian', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (29, 'Cris', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (29, 'Andrea', 'INFANTIL');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (30, 'Yese', 'ADULTO');
INSERT INTO PERFILES (id_usuario, nombre, tipo) VALUES (30, 'Diego', 'INFANTIL');

COMMIT;

-- =============================================================================
-- INSERTAR CONTENIDO (40)
-- =============================================================================

-- Peliculas (12)
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Ultimo Horizonte', 2024, 118, 'Mision espacial para salvar a la humanidad', '+13', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 'S', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Noche de Lluvia', 2023, 95, 'Thriller en una noche de tormenta', '+16', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 'N', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Amor en el Quindio', 2024, 102, 'Romance en las montanas colombianas', 'TP', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 'S', 1, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Siguiente Capitulo', 2024, 125, 'Comedia sobre una familia disfuncional', '+13', TO_DATE('2024-04-20', 'YYYY-MM-DD'), 'N', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Sombras del Pasado', 2023, 110, 'Drama sobre secretos familiares', '+16', TO_DATE('2024-05-12', 'YYYY-MM-DD'), 'N', 1, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Aventuras del Abuelo', 2024, 88, 'Comedia familiar', 'TP', TO_DATE('2024-06-18', 'YYYY-MM-DD'), 'S', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Codigo Rojo', 2023, 130, 'Accion y suspenso en el cyberespacio', '+16', TO_DATE('2024-07-25', 'YYYY-MM-DD'), 'N', 1, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Jardin Secreto', 2024, 98, 'Drama romantico victorialno', '+13', TO_DATE('2024-08-08', 'YYYY-MM-DD'), 'N', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Terror en el Lago', 2024, 105, 'Pelicula de terror', '+18', TO_DATE('2024-09-15', 'YYYY-MM-DD'), 'S', 1, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('La Gran Migracion', 2023, 115, 'Documental sobre migracion de animales', 'TP', TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'N', 1, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Estrellas del Sur', 2024, 92, 'Musical sobre una banda de rock', '+13', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'S', 1, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Duelo Final', 2024, 140, 'Accion extrema', '+18', TO_DATE('2024-12-12', 'YYYY-MM-DD'), 'N', 1, 1);

-- Series (10)
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Cafe del Centro', 2024, 45, 'Comedia sobre empleados de oficina', '+13', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'S', 2, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Misterio de la Casa', 2024, 50, 'Serie de suspenso y misterio', '+16', TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'N', 2, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Historias del Rio', 2023, 55, 'Drama sobre una familia colombiana', '+13', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'S', 2, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Detectives del Aire', 2024, 48, 'Comedia de investigadores', '+7', TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'N', 2, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('La Familia Complete', 2023, 52, 'Comedia familiar', '+13', TO_DATE('2024-05-15', 'YYYY-MM-DD'), 'N', 2, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Rescate en el Tiempo', 2024, 60, 'Ciencia ficcion', '+13', TO_DATE('2024-06-20', 'YYYY-MM-DD'), 'S', 2, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Bajo la Lluvia', 2024, 45, 'Drama romantico', '+16', TO_DATE('2024-07-12', 'YYYY-MM-DD'), 'N', 2, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Cocina del Chef', 2023, 60, 'Reality de cocina', 'TP', TO_DATE('2024-08-18', 'YYYY-MM-DD'), 'S', 2, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Noches de Gala', 2024, 55, 'Serie de moda', '+13', TO_DATE('2024-09-25', 'YYYY-MM-DD'), 'N', 2, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Ultimo Heroe', 2024, 50, 'Accion y aventura', '+16', TO_DATE('2024-10-30', 'YYYY-MM-DD'), 'S', 2, 2);

-- Documentales (6)
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Colombia Sagrada', 2024, 90, 'Documental sobre templos coloniales', 'TP', TO_DATE('2024-02-20', 'YYYY-MM-DD'), 'S', 3, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('El Cafe del Quindio', 2023, 75, 'Tradicion cafetera', 'TP', TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'S', 3, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Biodiversidad', 2024, 85, 'Fauna y flora de Colombia', 'TP', TO_DATE('2024-05-30', 'YYYY-MM-DD'), 'N', 3, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Historias de Ferrocarril', 2023, 100, 'Ferrocarril en Colombia', '+7', TO_DATE('2024-07-08', 'YYYY-MM-DD'), 'N', 3, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Vallenato: La Leyenda', 2024, 95, 'Musica y cultura Vallenata', '+13', TO_DATE('2024-09-12', 'YYYY-MM-DD'), 'S', 3, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Senderos de Montana', 2024, 80, 'Turismo ecologico', 'TP', TO_DATE('2024-11-18', 'YYYY-MM-DD'), 'S', 3, 2);

-- Musica (6)
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Concerto de Guitarra', 2024, 120, 'Recital de musica clasica', 'TP', TO_DATE('2024-01-28', 'YYYY-MM-DD'), 'N', 4, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Salsa en Vivo', 2023, 90, 'Concierto de salsa', '+13', TO_DATE('2024-03-15', 'YYYY-MM-DD'), 'S', 4, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Rock Nacional', 2024, 100, 'Mejores bandas de rock', '+13', TO_DATE('2024-05-22', 'YYYY-MM-DD'), 'N', 4, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Sesiones Acusticas', 2024, 60, 'Versiones acusticas', 'TP', TO_DATE('2024-07-30', 'YYYY-MM-DD'), 'S', 4, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Electronica Total', 2023, 110, 'Festival de musica electronica', '+16', TO_DATE('2024-09-05', 'YYYY-MM-DD'), 'N', 4, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Jazz en el Parque', 2024, 95, 'Festival de jazz', '+7', TO_DATE('2024-11-25', 'YYYY-MM-DD'), 'S', 4, 2);

-- Podcasts (6)
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Historias Insolitas', 2024, 45, 'Cuentos cortos para dormir', 'TP', TO_DATE('2024-02-05', 'YYYY-MM-DD'), 'S', 5, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Consultorio Legal', 2024, 30, 'Asesoria juridica', '+13', TO_DATE('2024-04-12', 'YYYY-MM-DD'), 'S', 5, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Cocina Express', 2023, 25, 'Recetas rapidas', 'TP', TO_DATE('2024-06-18', 'YYYY-MM-DD'), 'S', 5, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Tecnologia Hoy', 2024, 40, 'Noticias tecnologicas', '+13', TO_DATE('2024-08-22', 'YYYY-MM-DD'), 'N', 5, 2);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Bienestar Mental', 2024, 35, 'Consejos de salud mental', '+13', TO_DATE('2024-10-28', 'YYYY-MM-DD'), 'S', 5, 1);
INSERT INTO CONTENIDO (titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable) VALUES ('Economia Basica', 2023, 50, 'Educacion financiera', '+13', TO_DATE('2024-12-05', 'YYYY-MM-DD'), 'S', 5, 2);

COMMIT;

-- =============================================================================
-- INSERTAR GENEROS POR CONTENIDO
-- =============================================================================
INSERT INTO CONTENIDO_GENERO VALUES (1, 5); INSERT INTO CONTENIDO_GENERO VALUES (1, 11);
INSERT INTO CONTENIDO_GENERO VALUES (2, 8); INSERT INTO CONTENIDO_GENERO VALUES (2, 10);
INSERT INTO CONTENIDO_GENERO VALUES (3, 6);
INSERT INTO CONTENIDO_GENERO VALUES (4, 2);
INSERT INTO CONTENIDO_GENERO VALUES (5, 3);
INSERT INTO CONTENIDO_GENERO VALUES (6, 2); INSERT INTO CONTENIDO_GENERO VALUES (6, 9);
INSERT INTO CONTENIDO_GENERO VALUES (7, 1); INSERT INTO CONTENIDO_GENERO VALUES (7, 10);
INSERT INTO CONTENIDO_GENERO VALUES (8, 6); INSERT INTO CONTENIDO_GENERO VALUES (8, 3);
INSERT INTO CONTENIDO_GENERO VALUES (9, 4);
INSERT INTO CONTENIDO_GENERO VALUES (10, 7);
INSERT INTO CONTENIDO_GENERO VALUES (11, 9);
INSERT INTO CONTENIDO_GENERO VALUES (12, 1);
INSERT INTO CONTENIDO_GENERO VALUES (13, 2);
INSERT INTO CONTENIDO_GENERO VALUES (14, 10);
INSERT INTO CONTENIDO_GENERO VALUES (15, 3);
INSERT INTO CONTENIDO_GENERO VALUES (16, 2);
INSERT INTO CONTENIDO_GENERO VALUES (17, 2); INSERT INTO CONTENIDO_GENERO VALUES (17, 3);
INSERT INTO CONTENIDO_GENERO VALUES (18, 5);
INSERT INTO CONTENIDO_GENERO VALUES (19, 6);
INSERT INTO CONTENIDO_GENERO VALUES (20, 2);
INSERT INTO CONTENIDO_GENERO VALUES (21, 3);
INSERT INTO CONTENIDO_GENERO VALUES (22, 1); INSERT INTO CONTENIDO_GENERO VALUES (22, 11);
INSERT INTO CONTENIDO_GENERO VALUES (23, 7);
INSERT INTO CONTENIDO_GENERO VALUES (24, 7);
INSERT INTO CONTENIDO_GENERO VALUES (25, 7);
INSERT INTO CONTENIDO_GENERO VALUES (26, 7);
INSERT INTO CONTENIDO_GENERO VALUES (27, 7); INSERT INTO CONTENIDO_GENERO VALUES (27, 9);
INSERT INTO CONTENIDO_GENERO VALUES (28, 7);
INSERT INTO CONTENIDO_GENERO VALUES (29, 9);
INSERT INTO CONTENIDO_GENERO VALUES (30, 9);
INSERT INTO CONTENIDO_GENERO VALUES (31, 9);
INSERT INTO CONTENIDO_GENERO VALUES (32, 9);
INSERT INTO CONTENIDO_GENERO VALUES (33, 9);
INSERT INTO CONTENIDO_GENERO VALUES (34, 9);
INSERT INTO CONTENIDO_GENERO VALUES (35, 3);
INSERT INTO CONTENIDO_GENERO VALUES (36, 3);
INSERT INTO CONTENIDO_GENERO VALUES (37, 2);
INSERT INTO CONTENIDO_GENERO VALUES (38, 5);
INSERT INTO CONTENIDO_GENERO VALUES (39, 3);
INSERT INTO CONTENIDO_GENERO VALUES (40, 3);

-- =============================================================================
-- INSERTAR RELACIONES ENTRE CONTENIDOS
-- =============================================================================
INSERT INTO CONTENIDO_RELACIONADO VALUES (2, 9, 'SECUELA');
INSERT INTO CONTENIDO_RELACIONADO VALUES (9, 2, 'PRECUELA');
INSERT INTO CONTENIDO_RELACIONADO VALUES (13, 17, 'SPIN_OFF');
INSERT INTO CONTENIDO_RELACIONADO VALUES (22, 18, 'SECUELA');
INSERT INTO CONTENIDO_RELACIONADO VALUES (18, 22, 'PRECUELA');
INSERT INTO CONTENIDO_RELACIONADO VALUES (1, 18, 'REMAKE');
INSERT INTO CONTENIDO_RELACIONADO VALUES (12, 1, 'VERSION_EXTENDIDA');
INSERT INTO CONTENIDO_RELACIONADO VALUES (3, 19, 'SPIN_OFF');
INSERT INTO CONTENIDO_RELACIONADO VALUES (30, 27, 'VERSION_EXTENDIDA');

COMMIT;

-- =============================================================================
-- INSERTAR TEMPORADAS Y EPISODIOS
-- =============================================================================
-- Cafe del Centro (series 13)
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (13, 1, 'Primera Temporada');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (13, 2, 'Segunda Temporada');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (13, 3, 'Tercera Temporada');
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (1, 1, 'El Primer Dia', 45);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (1, 2, 'Nuevos Companiaeros', 45);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (1, 3, 'El Proyecto', 45);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (1, 4, 'La Presentacion', 45);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (1, 5, 'Ascenso', 45);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (2, 1, 'Nuevos Retos', 48);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (2, 2, 'Conflictos', 48);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (2, 3, 'Secretos', 48);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (2, 4, 'Despedidas', 48);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (2, 5, 'Renovacion', 48);

-- El Misterio de la Casa (serie 14)
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (14, 1, 'Temporada 1');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (14, 2, 'Temporada 2');
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (6, 1, 'La Casa Encantada', 50);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (6, 2, 'Los Secretos', 50);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (6, 3, 'La Verdad', 50);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (7, 1, 'Nuevos Misterios', 52);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (7, 2, 'El Regreso', 52);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (7, 3, 'Final', 52);

-- Historias del Rio (serie 15)
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (15, 1, 'Primera Parte');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (15, 2, 'Segunda Parte');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (15, 3, 'Final');
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (8, 1, 'El Comienzo', 55);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (8, 2, 'La Familia', 55);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (9, 1, 'Los Conflictos', 55);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (9, 2, 'La Reconciliacion', 55);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (10, 1, 'El Final', 60);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (10, 2, 'Epilogo', 55);

-- Rescate en el Tiempo (serie 18)
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (18, 1, 'Viaje Inicial');
INSERT INTO TEMPORADAS (id_contenido, numero_temporada, titulo) VALUES (18, 2, 'El Regreso');
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (13, 1, 'El Portal', 60);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (13, 2, 'Pasado', 60);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (13, 3, 'Futuro', 60);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (14, 1, 'Paradoja', 58);
INSERT INTO EPISODIOS (id_temporada, numero_episodio, titulo, duracion_min) VALUES (14, 2, 'Rescate', 58);

COMMIT;

-- =============================================================================
-- INSERTAR REPRODUCCIONES (200+)
-- =============================================================================
-- Primeras 50 reproducciones manuales
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (1, 1, NULL, TO_DATE('2024-01-15 14:30', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-15 16:28', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (1, 2, NULL, TO_DATE('2024-01-16 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-16 19:35', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (2, 3, NULL, TO_DATE('2024-01-17 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-17 21:42', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (3, 1, NULL, TO_DATE('2024-01-18 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-18 16:58', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (4, 13, NULL, TO_DATE('2024-01-19 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-19 19:45', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (5, 14, NULL, TO_DATE('2024-01-20 21:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-20 21:50', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (6, 4, NULL, TO_DATE('2024-01-21 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-21 18:05', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (7, 5, NULL, TO_DATE('2024-01-22 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-22 15:50', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (8, 15, 1, TO_DATE('2024-01-23 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-23 20:55', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (9, 15, 2, TO_DATE('2024-01-23 21:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-23 21:55', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (10, 22, NULL, TO_DATE('2024-01-24 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-24 18:50', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (11, 6, NULL, TO_DATE('2024-01-25 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-25 16:28', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (12, 7, NULL, TO_DATE('2024-01-26 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-26 21:10', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (13, 8, NULL, TO_DATE('2024-01-27 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-27 17:38', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (14, 9, NULL, TO_DATE('2024-01-28 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-28 21:45', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (15, 23, NULL, TO_DATE('2024-01-29 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-29 15:30', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (16, 10, NULL, TO_DATE('2024-01-30 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-30 20:15', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (17, 11, NULL, TO_DATE('2024-01-31 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-01-31 16:32', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (18, 12, NULL, TO_DATE('2024-02-01 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-01 21:20', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (19, 24, NULL, TO_DATE('2024-02-02 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-02 17:15', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (20, 25, NULL, TO_DATE('2024-02-03 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-03 21:25', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (21, 1, NULL, TO_DATE('2024-02-04 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-04 15:50', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 95);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (22, 2, NULL, TO_DATE('2024-02-05 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-05 19:30', 'YYYY-MM-DD HH24:MI'), 'TV', 95);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (23, 3, NULL, TO_DATE('2024-02-06 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-06 16:40', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 98);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (24, 4, NULL, TO_DATE('2024-02-07 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-07 21:05', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (25, 5, NULL, TO_DATE('2024-02-08 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-08 17:50', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (26, 13, 1, TO_DATE('2024-02-09 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-09 20:45', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (27, 14, 1, TO_DATE('2024-02-10 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-10 18:50', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (28, 15, 1, TO_DATE('2024-02-11 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-11 14:55', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (29, 16, NULL, TO_DATE('2024-02-12 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-12 19:48', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (30, 17, NULL, TO_DATE('2024-02-13 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-13 17:00', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (31, 18, NULL, TO_DATE('2024-02-14 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-14 21:00', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (32, 19, NULL, TO_DATE('2024-02-15 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-15 18:45', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (33, 20, NULL, TO_DATE('2024-02-16 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-16 15:00', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (34, 21, NULL, TO_DATE('2024-02-17 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-17 20:00', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (35, 22, NULL, TO_DATE('2024-02-18 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-18 17:00', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (36, 23, NULL, TO_DATE('2024-02-19 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-19 21:30', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (37, 24, NULL, TO_DATE('2024-02-20 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-20 19:15', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (38, 25, NULL, TO_DATE('2024-02-21 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-21 15:25', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (39, 26, NULL, TO_DATE('2024-02-22 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-22 20:40', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (40, 27, NULL, TO_DATE('2024-02-23 16:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-23 17:35', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (41, 1, NULL, TO_DATE('2024-02-24 20:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-24 22:00', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (42, 2, NULL, TO_DATE('2024-02-25 18:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-25 19:35', 'YYYY-MM-DD HH24:MI'), 'COMPUTADOR', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (43, 3, NULL, TO_DATE('2024-02-26 15:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-26 16:42', 'YYYY-MM-DD HH24:MI'), 'TABLET', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (44, 4, NULL, TO_DATE('2024-02-27 19:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-27 21:05', 'YYYY-MM-DD HH24:MI'), 'TV', 100);
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance) VALUES (45, 5, NULL, TO_DATE('2024-02-28 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-02-28 15:50', 'YYYY-MM-DD HH24:MI'), 'CELULAR', 100);

-- Mas reproducciones (generar con query)
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)
SELECT 1 + MOD(ROWNUM, 30), 1 + MOD(ROWNUM * 7, 35), NULL,
    TO_DATE('2024-03-01', 'YYYY-MM-DD') + ROWNUM/48,
    TO_DATE('2024-03-01', 'YYYY-MM-DD') + ROWNUM/48 + 1/24,
    DECODE(MOD(ROWNUM, 4), 0, 'CELULAR', 1, 'TABLET', 2, 'TV', 3, 'COMPUTADOR'),
    50 + MOD(ROWNUM * 13, 50)
FROM DUAL CONNECT BY ROWNUM <= 100;

-- Reproducciones 2025
INSERT INTO REPRODUCCIONES (id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)
SELECT 1 + MOD(ROWNUM, 40), 1 + MOD(ROWNUM * 11, 35), NULL,
    TO_DATE('2025-01-01', 'YYYY-MM-DD') + ROWNUM/48,
    TO_DATE('2025-01-01', 'YYYY-MM-DD') + ROWNUM/48 + 1/24,
    DECODE(MOD(ROWNUM, 4), 0, 'CELULAR', 1, 'TABLET', 2, 'TV', 3, 'COMPUTADOR'),
    30 + MOD(ROWNUM * 17, 70)
FROM DUAL CONNECT BY ROWNUM <= 100;

COMMIT;

-- =============================================================================
-- INSERTAR CALIFICACIONES (60)
-- =============================================================================
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (1, 1, 5, 'Excelente pelicula de ciencia ficcion', TO_DATE('2024-01-20', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (2, 1, 4, 'Muy buena historia', TO_DATE('2024-01-21', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (3, 1, 5, TO_DATE('2024-01-22', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (4, 2, 3, 'Buena pero muy larga', TO_DATE('2024-01-23', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (5, 2, 4, TO_DATE('2024-01-24', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (6, 3, 5, 'Me encanto el romance', TO_DATE('2024-01-25', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (7, 3, 4, TO_DATE('2024-01-26', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (8, 4, 3, TO_DATE('2024-01-27', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (9, 4, 4, 'Divertida', TO_DATE('2024-01-28', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (10, 5, 5, TO_DATE('2024-01-29', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (11, 5, 4, TO_DATE('2024-01-30', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (12, 6, 4, 'Para toda la familia', TO_DATE('2024-01-31', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (13, 6, 5, TO_DATE('2024-02-01', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (14, 7, 4, TO_DATE('2024-02-02', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (15, 7, 5, 'Gran accion', TO_DATE('2024-02-03', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (16, 8, 4, TO_DATE('2024-02-04', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (17, 8, 3, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (18, 9, 2, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (19, 9, 5, 'Muy aterradora', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (20, 10, 5, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (21, 10, 4, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (22, 11, 5, 'Excelente musica', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (23, 11, 4, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (24, 12, 3, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (25, 12, 4, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (26, 13, 5, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, reseña, fecha_calificacion) VALUES (27, 13, 4, 'Muy divertida', TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (28, 14, 4, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (29, 14, 5, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (30, 15, 3, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (31, 15, 4, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (32, 15, 5, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (33, 16, 4, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (34, 16, 3, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (35, 17, 5, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (36, 17, 4, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (37, 18, 4, TO_DATE('2024-02-25', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (38, 18, 5, TO_DATE('2024-02-26', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (39, 19, 4, TO_DATE('2024-02-27', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (40, 19, 3, TO_DATE('2024-02-28', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (41, 20, 5, TO_DATE('2024-03-01', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (42, 20, 4, TO_DATE('2024-03-02', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (43, 21, 5, TO_DATE('2024-03-03', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (44, 21, 4, TO_DATE('2024-03-04', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (45, 22, 3, TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (46, 22, 4, TO_DATE('2024-03-06', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (47, 23, 5, TO_DATE('2024-03-07', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (48, 23, 4, TO_DATE('2024-03-08', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (49, 24, 5, TO_DATE('2024-03-09', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (50, 24, 4, TO_DATE('2024-03-10', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (51, 25, 3, TO_DATE('2024-03-11', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (52, 25, 5, TO_DATE('2024-03-12', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (53, 29, 4, TO_DATE('2024-03-13', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (54, 30, 5, TO_DATE('2024-03-14', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (55, 31, 4, TO_DATE('2024-03-15', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (1, 35, 5, TO_DATE('2024-03-16', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (2, 36, 4, TO_DATE('2024-03-17', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (3, 37, 3, TO_DATE('2024-03-18', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (4, 38, 5, TO_DATE('2024-03-19', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (5, 39, 4, TO_DATE('2024-03-20', 'YYYY-MM-DD'));
INSERT INTO CALIFICACIONES (id_perfil, id_contenido, estrellas, fecha_calificacion) VALUES (6, 40, 5, TO_DATE('2024-03-21', 'YYYY-MM-DD'));

-- =============================================================================
-- INSERTAR FAVORITOS (40)
-- =============================================================================
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (1, 1, TO_DATE('2024-01-18', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (2, 2, TO_DATE('2024-01-19', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (3, 3, TO_DATE('2024-01-20', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (4, 4, TO_DATE('2024-01-21', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (5, 5, TO_DATE('2024-01-22', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (6, 6, TO_DATE('2024-01-23', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (7, 7, TO_DATE('2024-01-24', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (8, 8, TO_DATE('2024-01-25', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (9, 9, TO_DATE('2024-01-26', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (10, 10, TO_DATE('2024-01-27', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (11, 11, TO_DATE('2024-01-28', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (12, 12, TO_DATE('2024-01-29', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (13, 13, TO_DATE('2024-01-30', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (14, 14, TO_DATE('2024-01-31', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (15, 15, TO_DATE('2024-02-01', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (16, 16, TO_DATE('2024-02-02', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (17, 17, TO_DATE('2024-02-03', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (18, 18, TO_DATE('2024-02-04', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (19, 19, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (20, 20, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (21, 21, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (22, 22, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (23, 23, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (24, 24, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (25, 25, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (26, 1, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (27, 2, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (28, 3, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (29, 4, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (30, 5, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (31, 6, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (32, 7, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (33, 8, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (34, 9, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (35, 10, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (36, 11, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (37, 12, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (38, 13, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (39, 14, TO_DATE('2024-02-25', 'YYYY-MM-DD'));
INSERT INTO FAVORITOS (id_perfil, id_contenido, fecha_agregado) VALUES (40, 15, TO_DATE('2024-02-26', 'YYYY-MM-DD'));

-- =============================================================================
-- INSERTAR PAGOS (80)
-- =============================================================================
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (1, TO_DATE('2024-01-10', 'YYYY-MM-DD'), 12990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (1, TO_DATE('2024-02-10', 'YYYY-MM-DD'), 12990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-03-10', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (1, TO_DATE('2024-03-10', 'YYYY-MM-DD'), 12990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-04-10', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (2, TO_DATE('2024-02-05', 'YYYY-MM-DD'), 18990, 'NEQUI', 'EXITOSO', TO_DATE('2024-03-05', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (2, TO_DATE('2024-03-05', 'YYYY-MM-DD'), 18990, 'NEQUI', 'EXITOSO', TO_DATE('2024-04-05', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (3, TO_DATE('2024-03-12', 'YYYY-MM-DD'), 24990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-04-12', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (3, TO_DATE('2024-04-12', 'YYYY-MM-DD'), 24990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-05-12', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (4, TO_DATE('2024-04-18', 'YYYY-MM-DD'), 12990, 'PSE', 'EXITOSO', TO_DATE('2024-05-18', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (5, TO_DATE('2024-05-20', 'YYYY-MM-DD'), 18990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-06-20', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (5, TO_DATE('2024-06-20', 'YYYY-MM-DD'), 18990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-07-20', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (6, TO_DATE('2024-06-15', 'YYYY-MM-DD'), 18990, 'DAVIPLATA', 'EXITOSO', TO_DATE('2024-07-15', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (7, TO_DATE('2024-07-22', 'YYYY-MM-DD'), 12990, 'NEQUI', 'EXITOSO', TO_DATE('2024-08-22', 'YYYY-MM-DD'));
-- Cali
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (13, TO_DATE('2024-01-25', 'YYYY-MM-DD'), 18990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-02-25', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (13, TO_DATE('2024-02-25', 'YYYY-MM-DD'), 18990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-03-25', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (14, TO_DATE('2024-02-18', 'YYYY-MM-DD'), 12990, 'PSE', 'EXITOSO', TO_DATE('2024-03-18', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (15, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 24990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-04-25', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (16, TO_DATE('2024-04-30', 'YYYY-MM-DD'), 18990, 'NEQUI', 'EXITOSO', TO_DATE('2024-05-30', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (17, TO_DATE('2024-05-15', 'YYYY-MM-DD'), 12990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-06-15', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (18, TO_DATE('2024-06-22', 'YYYY-MM-DD'), 24990, 'DAVIPLATA', 'EXITOSO', TO_DATE('2024-07-22', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (19, TO_DATE('2024-07-10', 'YYYY-MM-DD'), 18990, 'PSE', 'EXITOSO', TO_DATE('2024-08-10', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (20, TO_DATE('2024-08-28', 'YYYY-MM-DD'), 12990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-09-28', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (21, TO_DATE('2024-09-15', 'YYYY-MM-DD'), 18990, 'NEQUI', 'EXITOSO', TO_DATE('2024-10-15', 'YYYY-MM-DD'));
-- Bogota
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (23, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (23, TO_DATE('2024-02-18', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-03-18', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (23, TO_DATE('2024-03-18', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-04-18', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (24, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 18990, 'PSE', 'EXITOSO', TO_DATE('2024-03-28', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (25, TO_DATE('2024-03-15', 'YYYY-MM-DD'), 18990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-04-15', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (26, TO_DATE('2024-04-20', 'YYYY-MM-DD'), 12990, 'NEQUI', 'EXITOSO', TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (27, TO_DATE('2024-05-28', 'YYYY-MM-DD'), 24990, 'DAVIPLATA', 'EXITOSO', TO_DATE('2024-06-28', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (28, TO_DATE('2024-06-12', 'YYYY-MM-DD'), 12990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-07-12', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (29, TO_DATE('2024-07-25', 'YYYY-MM-DD'), 18990, 'PSE', 'EXITOSO', TO_DATE('2024-08-25', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (30, TO_DATE('2024-08-18', 'YYYY-MM-DD'), 24990, 'TARJETA_DEBITO', 'EXITOSO', TO_DATE('2024-09-18', 'YYYY-MM-DD'));
-- Fallidos y Reembolsados
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (8, TO_DATE('2024-08-10', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'FALLIDO', TO_DATE('2024-09-10', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (10, TO_DATE('2024-10-12', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'REEMBOLSADO', TO_DATE('2024-11-12', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (10, TO_DATE('2024-11-12', 'YYYY-MM-DD'), 24990, 'TARJETA_CREDITO', 'EXITOSO', TO_DATE('2024-12-12', 'YYYY-MM-DD'));
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento) VALUES (22, TO_DATE('2024-10-22', 'YYYY-MM-DD'), 24990, 'NEQUI', 'FALLIDO', TO_DATE('2024-11-22', 'YYYY-MM-DD'));

-- Pagos adicionales para completar 80
INSERT INTO PAGOS (id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)
SELECT id_usuario, fecha_registro + 30, 
    CASE id_plan WHEN 1 THEN 12990 WHEN 2 THEN 18990 ELSE 24990 END,
    DECODE(MOD(ROWNUM, 5), 0, 'TARJETA_CREDITO', 1, 'TARJETA_DEBITO', 2, 'PSE', 3, 'NEQUI', 'DAVIPLATA'),
    'EXITOSO',
    fecha_registro + 60
FROM USUARIOS WHERE id_usuario NOT IN (8, 10, 22);

-- =============================================================================
-- INSERTAR REPORTES DE CONTENIDO (10)
-- =============================================================================
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador, fecha_resolucion) VALUES (3, 9, 'Contenido no apropiado', TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'RESUELTO', 7, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado) VALUES (5, 12, 'Calidad muy baja', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 'PENDIENTE');
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador) VALUES (7, 14, 'Audio desincronizado', TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'EN_REVISION', 8);
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado) VALUES (10, 22, 'Episodios faltantes', TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'PENDIENTE');
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador, fecha_resolucion) VALUES (12, 2, 'Descripcion inaccurate', TO_DATE('2024-04-18', 'YYYY-MM-DD'), 'RESUELTO', 7, TO_DATE('2024-04-19', 'YYYY-MM-DD'));
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado) VALUES (15, 17, 'Subtitulos incorrectos', TO_DATE('2024-05-10', 'YYYY-MM-DD'), 'PENDIENTE');
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador, fecha_resolucion) VALUES (18, 5, 'Contenido ofensivo', TO_DATE('2024-05-22', 'YYYY-MM-DD'), 'RECHAZADO', 8, TO_DATE('2024-05-23', 'YYYY-MM-DD'));
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado) VALUES (20, 30, 'Musica con errores', TO_DATE('2024-06-08', 'YYYY-MM-DD'), 'PENDIENTE');
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador, fecha_resolucion) VALUES (25, 28, 'Info incorrecta', TO_DATE('2024-06-20', 'YYYY-MM-DD'), 'RESUELTO', 9, TO_DATE('2024-06-21', 'YYYY-MM-DD'));
INSERT INTO REPORTES_CONTENIDO (id_perfil, id_contenido, descripcion, fecha_reporte, estado) VALUES (30, 9, 'No funciona play', TO_DATE('2024-07-05', 'YYYY-MM-DD'), 'PENDIENTE');

COMMIT;

-- =============================================================================
-- VERIFICACIONES FINALES
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== VERIFICACION DE DATOS ===');
    DBMS_OUTPUT.PUT_LINE('Planes: ' || (SELECT COUNT(*) FROM PLANES));
    DBMS_OUTPUT.PUT_LINE('Categorias: ' || (SELECT COUNT(*) FROM CATEGORIAS));
    DBMS_OUTPUT.PUT_LINE('Generos: ' || (SELECT COUNT(*) FROM GENEROS));
    DBMS_OUTPUT.PUT_LINE('Departamentos: ' || (SELECT COUNT(*) FROM DEPARTAMENTOS));
    DBMS_OUTPUT.PUT_LINE('Empleados: ' || (SELECT COUNT(*) FROM EMPLEADOS));
    DBMS_OUTPUT.PUT_LINE('Usuarios: ' || (SELECT COUNT(*) FROM USUARIOS));
    DBMS_OUTPUT.PUT_LINE('Perfiles: ' || (SELECT COUNT(*) FROM PERFILES));
    DBMS_OUTPUT.PUT_LINE('Contenido: ' || (SELECT COUNT(*) FROM CONTENIDO));
    DBMS_OUTPUT.PUT_LINE('Generos por Contenido: ' || (SELECT COUNT(*) FROM CONTENIDO_GENERO));
    DBMS_OUTPUT.PUT_LINE('Temporadas: ' || (SELECT COUNT(*) FROM TEMPORADAS));
    DBMS_OUTPUT.PUT_LINE('Episodios: ' || (SELECT COUNT(*) FROM EPISODIOS));
    DBMS_OUTPUT.PUT_LINE('Reproducciones: ' || (SELECT COUNT(*) FROM REPRODUCCIONES));
    DBMS_OUTPUT.PUT_LINE('Calificaciones: ' || (SELECT COUNT(*) FROM CALIFICACIONES));
    DBMS_OUTPUT.PUT_LINE('Favoritos: ' || (SELECT COUNT(*) FROM FAVORITOS));
    DBMS_OUTPUT.PUT_LINE('Pagos: ' || (SELECT COUNT(*) FROM PAGOS));
    DBMS_OUTPUT.PUT_LINE('Reportes: ' || (SELECT COUNT(*) FROM REPORTES_CONTENIDO));
END;
/

-- Distribucion por ciudad
SELECT ciudad, COUNT(*) as total FROM USUARIOS GROUP BY ciudad ORDER BY ciudad;

-- Distribucion por plan
SELECT p.nombre, COUNT(*) as total FROM USUARIOS u JOIN PLANES p ON u.id_plan = p.id_plan GROUP BY p.nombre ORDER BY p.nombre;

-- Usuarios con referidor
SELECT COUNT(*) as total FROM USUARIOS WHERE id_referidor IS NOT NULL;