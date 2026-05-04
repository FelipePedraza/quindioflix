# QuindioFlix — Plan de Sprints Backend
**Universidad del Quindío · Bases de Datos II · 2025-1**  
**Stack:** Java 21 · Spring Boot 4.0.6 · Spring Security · Spring Web MVC · Oracle DB (ojdbc11)

---

## Convenciones

| Símbolo | Significado |
|---------|-------------|
| 🗄️ | Tarea de base de datos / SQL |
| ☕ | Tarea de código Java / Spring |
| 🔐 | Tarea de seguridad |
| 🧪 | Tarea de pruebas |
| 📄 | Tarea de documentación |

> **Duración sugerida por sprint:** 1 semana cada uno, ajustable al cronograma del docente.  
> **Rama Git sugerida por sprint:** `sprint/N-nombre-sprint`

---

## Sprint 0 — Configuración y Arranque del Proyecto
**Objetivo:** Dejar el proyecto listo para el desarrollo: conexión a Oracle funcional, estructura de paquetes definida y pipeline básico corriendo.

### Tareas

**☕ Estructura de paquetes Java**
- Crear la estructura de paquetes base dentro de `com.uniquindio.quindioflix`:
  ```
  controller/
  service/
  service/impl/
  repository/
  model/entity/
  model/dto/
  model/mapper/
  config/
  exception/
  util/
  ```

**🗄️ Configuración de datasource Oracle**
- Completar `application.properties` con las propiedades de conexión Oracle:
  ```properties
  spring.datasource.url=jdbc:oracle:thin:@localhost:1521:XE
  spring.datasource.username=quindioflix_owner
  spring.datasource.password=<password>
  spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
  spring.jpa.database-platform=org.hibernate.dialect.OracleDialect
  spring.jpa.hibernate.ddl-auto=none
  spring.jpa.show-sql=true
  ```
- Crear perfil `application-dev.properties` para desarrollo local.

**☕ Configuración global**
- Configurar `GlobalExceptionHandler` con `@RestControllerAdvice` para manejar excepciones de forma centralizada.
- Configurar `CorsConfig` para permitir peticiones desde el frontend durante desarrollo.
- Crear clase `ApiResponse<T>` como wrapper estándar para todas las respuestas REST.

**🔐 Seguridad inicial (placeholder)**
- Deshabilitar temporalmente Spring Security para el desarrollo inicial (`.permitAll()` en `SecurityConfig`).
- Dejar la estructura de `SecurityConfig` lista para activarse en Sprint 8.

**🧪 Verificación**
- Endpoint `GET /api/health` que retorne `{"status": "UP", "db": "Oracle conectado"}` consultando `SELECT 1 FROM DUAL`.

### Entregables
- Proyecto compila y arranca sin errores.
- Conexión a Oracle verificada.
- Endpoint `/api/health` responde correctamente.

---

## Sprint 1 — Modelo de Base de Datos: Núcleo (DDL)
**Objetivo:** Crear todas las tablas del modelo relacional en Oracle con sus restricciones, comentarios y tablespaces. Este sprint es el más crítico del proyecto.

### Tareas

**🗄️ Script de creación de tablas — Dominio de Planes y Usuarios**
- `PLANES (id_plan, nombre, max_pantallas, calidad, precio_mes)`
- `USUARIOS (id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad, fecha_registro, estado_cuenta, id_plan, id_referidor)`
  - `UNIQUE` en `email`
  - `FK` a `PLANES` y auto-referencia a `USUARIOS` (referidor)
  - `CHECK estado_cuenta IN ('ACTIVO','INACTIVO','SUSPENDIDO')`
- `PERFILES (id_perfil, id_usuario, nombre, avatar, tipo)`
  - `CHECK tipo IN ('ADULTO','INFANTIL')`
  - `FK` a `USUARIOS`

**🗄️ Script de creación de tablas — Dominio de Contenido**
- `CATEGORIAS (id_categoria, nombre)` — Películas, Series, Documentales, Música, Podcasts
- `GENEROS (id_genero, nombre)` — Acción, Comedia, Drama, etc.
- `CONTENIDO (id_contenido, titulo, anio_lanzamiento, duracion_min, sinopsis, clasificacion_edad, fecha_catalogo, es_original, id_categoria, id_empleado_responsable, popularidad)`
  - `CHECK clasificacion_edad IN ('TP','+7','+13','+16','+18')`
- `CONTENIDO_GENERO (id_contenido, id_genero)` — tabla N:M
- `CONTENIDO_RELACIONADO (id_contenido, id_contenido_rel, tipo_relacion)` — relación reflexiva
  - `CHECK tipo_relacion IN ('SECUELA','PRECUELA','REMAKE','SPIN_OFF','VERSION_EXTENDIDA')`
- `TEMPORADAS (id_temporada, id_contenido, numero_temporada, titulo)`
- `EPISODIOS (id_episodio, id_temporada, numero_episodio, titulo, duracion_min)`

**🗄️ Script de creación de tablas — Dominio de Empleados**
- `DEPARTAMENTOS (id_departamento, nombre, id_jefe)`
  - Auto-referencia diferida para `id_jefe`
- `EMPLEADOS (id_empleado, nombre, email, id_departamento, id_supervisor, rol)`
  - `CHECK rol IN ('CONTENIDO','SOPORTE','MODERADOR','ADMIN','ANALISTA','MARKETING','FINANZAS')`
  - Auto-referencia a `EMPLEADOS` para supervisor

**🗄️ Script de creación de tablas — Dominio de Consumo y Pagos**
- `REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido, id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)`
  - `CHECK dispositivo IN ('CELULAR','TABLET','TV','COMPUTADOR')`
  - `id_episodio` nullable (solo aplica para series/podcasts)
- `FAVORITOS (id_favorito, id_perfil, id_contenido, fecha_agregado)`
  - `UNIQUE (id_perfil, id_contenido)`
- `CALIFICACIONES (id_calificacion, id_perfil, id_contenido, estrellas, reseña, fecha_calificacion)`
  - `CHECK estrellas BETWEEN 1 AND 5`
  - `UNIQUE (id_perfil, id_contenido)`
- `PAGOS (id_pago, id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento)`
  - `CHECK metodo_pago IN ('TARJETA_CREDITO','TARJETA_DEBITO','PSE','NEQUI','DAVIPLATA')`
  - `CHECK estado_pago IN ('EXITOSO','FALLIDO','PENDIENTE','REEMBOLSADO')`
- `REPORTES_CONTENIDO (id_reporte, id_perfil, id_contenido, descripcion, fecha_reporte, estado, id_moderador, fecha_resolucion)`
  - `CHECK estado IN ('PENDIENTE','EN_REVISION','RESUELTO','RECHAZADO')`

**🗄️ Fragmentación de tabla REPRODUCCIONES (NT1 - 3.1.5)**
- Crear tablespaces: `TS_REPRO_2024`, `TS_REPRO_2025`, `TS_REPRO_2026`
- Implementar `REPRODUCCIONES` como tabla particionada por rango de `fecha_hora_inicio`
- Documentar justificación: volumen de datos, consultas por rango de fechas, mantenimiento independiente por año

**🗄️ Comentarios en todas las tablas y columnas**
- `COMMENT ON TABLE ... IS '...'`
- `COMMENT ON COLUMN ... IS '...'`

### Entregables
- `01_DDL_tablas.sql` — ejecutable sin errores en Oracle.
- Todas las tablas con PKs, FKs, CHECKs, UNIQUEs y comentarios.
- Tabla `REPRODUCCIONES` particionada con sus tablespaces.

---

## Sprint 2 — Datos de Prueba (DML)
**Objetivo:** Poblar la base de datos con datos asimétricos y coherentes que permitan que todos los reportes muestren diferencias reales.

### Tareas

**🗄️ Script de inserción — Catálogos base**
- 3 planes (`PLANES`)
- 5 categorías (`CATEGORIAS`)
- 10+ géneros (`GENEROS`)
- 5 departamentos con jefes (`DEPARTAMENTOS`)
- 15 empleados distribuidos en departamentos (`EMPLEADOS`)

**🗄️ Script de inserción — Usuarios y perfiles**
- 30 usuarios distribuidos **asimétricamente**:
  - 12 en Armenia, 10 en Cali, 8 en Bogotá
  - 10 en plan Básico, 12 en Estándar, 8 en Premium
  - Al menos 5 usuarios con referidor registrado
- 50+ perfiles: varios usuarios con 2-5 perfiles, incluyendo perfiles infantiles

**🗄️ Script de inserción — Contenido**
- 40 contenidos distribuidos en las 5 categorías
- Incluir géneros múltiples por contenido (`CONTENIDO_GENERO`)
- Al menos 5 contenidos originales de QuindioFlix (`es_original = 'S'`)
- Al menos 8 relaciones entre contenidos (`CONTENIDO_RELACIONADO`)
- 15 temporadas para series y podcasts
- 50+ episodios

**🗄️ Script de inserción — Consumo y transacciones**
- 200+ reproducciones variadas:
  - Distribuidas en 2024 y 2025 (para probar particionamiento)
  - Diferentes dispositivos, porcentajes de avance variados
  - Algunas con `porcentaje_avance >= 90` (reproducciones completas)
- 60 calificaciones (estrellas 1-5, algunas con reseña)
- 40 favoritos
- 80 pagos: historial de varios meses, algunos `FALLIDO`, algunos `REEMBOLSADO`
- 10 reportes de contenido, algunos resueltos y algunos pendientes

**🗄️ Validación de coherencia**
- Verificar que ningún perfil infantil tenga reproducciones de contenido +16 o +18
- Verificar que cada contenido calificado tenga al menos una reproducción ≥ 50% del perfil que calificó
- Verificar que los pagos sean coherentes con los planes de cada usuario

### Entregables
- `02_DML_datos_prueba.sql` — ejecutable después de `01_DDL_tablas.sql`.
- Datos coherentes con todas las restricciones de integridad.

---

## Sprint 3 — Consultas Avanzadas (Núcleo 1 — NT1)
**Objetivo:** Implementar todas las consultas avanzadas requeridas por el Núcleo Temático 1.

### Tareas

**🗄️ Consultas parametrizadas (mínimo 3)**
- `Q1`: Recibe `ciudad` → top 10 contenidos más reproducidos en esa ciudad
  - Usar variable de sustitución `&ciudad`
- `Q2`: Recibe `mes` y `anio` → ingresos por plan de suscripción en ese periodo
  - Usar `&&mes` y `&&anio` para reutilización
- `Q3`: Recibe `genero` → calificación promedio por categoría para ese género
- `Q4` (adicional): Recibe `id_usuario` → historial de reproducciones con tiempo consumido total

**🗄️ PIVOT y UNPIVOT (mínimo 2)**
- `PIVOT_1`: Filas = ciudades, columnas = planes (Básico/Estándar/Premium), valor = cantidad de usuarios activos
- `PIVOT_2`: Filas = categorías, columnas = dispositivos (CELULAR/TABLET/TV/COMPUTADOR), valor = total de reproducciones
- `UNPIVOT_1` (bonus): Invertir `PIVOT_2` para análisis cruzado

**🗄️ GROUP BY avanzado (mínimo 3)**
- `ROLLUP_1`: Ingresos por ciudad y plan, con subtotales por ciudad y gran total
- `CUBE_1`: Reproducciones por categoría y dispositivo con todas las combinaciones posibles
- `GROUPING_SETS_1`: Solo totales por categoría y por ciudad, sin cruce

**🗄️ Vistas materializadas (mínimo 2)**
- `MV_CONTENIDO_POPULAR`: `id_contenido`, `titulo`, `total_reproducciones`, `promedio_calificacion`, `reproducciones_completas`
  - Refresh: `ON DEMAND` o `FAST` según soporte del esquema
- `MV_INGRESOS_MENSUALES`: `ciudad`, `nombre_plan`, `mes`, `anio`, `total_ingresos`, `total_usuarios`
  - Base para el reporte financiero mensual

### Entregables
- `03_NT1_consultas_avanzadas.sql`
- Cada consulta con comentario explicando qué hace y por qué se usa esa técnica.

---

## Sprint 4 — PL/SQL: Cursores, Procedimientos y Funciones (Núcleo 2 — NT2, parte 1)
**Objetivo:** Implementar los cursores, procedimientos almacenados y funciones requeridos.

### Tareas

**🗄️ Cursores (mínimo 2)**
- `CUR_SUSCRIPCIONES_VENCIDAS`: Recorre usuarios con más de 30 días sin pago exitoso
  - Genera reporte: nombre, email, plan, días de mora, monto adeudado
  - Usar cursor explícito con `%ROWTYPE`
- `CUR_ACTUALIZAR_POPULARIDAD`: Recorre todo el catálogo
  - Calcula reproducciones completas (porcentaje_avance >= 90) por contenido
  - Actualiza campo `popularidad` en `CONTENIDO`
  - Usar cursor con `FOR UPDATE` y `WHERE CURRENT OF`

**🗄️ Procedimientos almacenados (mínimo 3)**
- `SP_REGISTRAR_USUARIO(p_nombre, p_email, p_telefono, p_fecha_nac, p_ciudad, p_id_plan, p_id_referidor)`:
  1. Validar que el email no exista (excepción personalizada `EX_EMAIL_DUPLICADO`)
  2. Validar que el plan exista (`NO_DATA_FOUND`)
  3. Insertar en `USUARIOS`
  4. Crear perfil predeterminado tipo ADULTO en `PERFILES`
  5. Registrar primer pago con estado `PENDIENTE` en `PAGOS`
  6. `COMMIT` al final; `ROLLBACK` en cualquier error

- `SP_CAMBIAR_PLAN(p_id_usuario, p_id_plan_nuevo)`:
  1. Obtener número actual de perfiles del usuario
  2. Obtener máximo de perfiles del nuevo plan
  3. Si `perfiles_actuales > max_nuevo_plan` → lanzar `EX_PERFILES_EXCEDEN_PLAN`
  4. Actualizar `USUARIOS.id_plan`
  5. Registrar el cambio en tabla de auditoría (o en `PAGOS` con nuevo monto)

- `SP_REPORTE_CONSUMO(p_id_usuario, p_fecha_inicio, p_fecha_fin)`:
  1. Recorrer todos los perfiles del usuario
  2. Para cada perfil, listar reproducciones en el rango de fechas
  3. Agrupar por categoría con totales de tiempo consumido en minutos
  4. Usar `DBMS_OUTPUT.PUT_LINE` para el reporte

**🗄️ Funciones (mínimo 2)**
- `FN_CALCULAR_MONTO(p_id_usuario) RETURN NUMBER`:
  - Obtener precio base del plan actual
  - Calcular antigüedad en meses desde `fecha_registro`
  - Aplicar descuento: >12 meses → 10%, >24 meses → 15%
  - Verificar si tiene referido activo → descuento adicional
  - Retornar monto final

- `FN_CONTENIDO_RECOMENDADO(p_id_perfil) RETURN VARCHAR2`:
  - Identificar el género más reproducido por el perfil
  - Buscar contenido de ese género no reproducido aún por el perfil
  - Respetar restricción de edad del perfil (infantil solo TP/+7/+13)
  - Retornar el título del contenido más afín (mayor popularidad)

### Entregables
- `04_NT2_cursores_sp_funciones.sql`
- Cada subprograma compilado sin errores (`SHOW ERRORS` al final de cada bloque).

---

## Sprint 5 — PL/SQL: Excepciones y Disparadores (Núcleo 2 — NT2, parte 2)
**Objetivo:** Implementar el manejo de excepciones y todos los triggers requeridos.

### Tareas

**🗄️ Excepciones (mínimo 2 personalizadas)**
- Dentro de `SP_REGISTRAR_USUARIO`:
  - `EX_EMAIL_DUPLICADO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_EMAIL_DUPLICADO, -20001)`
  - Capturar `NO_DATA_FOUND` cuando el plan no exista
  - Bloque `EXCEPTION` con `RAISE_APPLICATION_ERROR` y mensajes descriptivos

- Dentro de `SP_CAMBIAR_PLAN`:
  - `EX_PERFILES_EXCEDEN_PLAN EXCEPTION; PRAGMA EXCEPTION_INIT(EX_PERFILES_EXCEDEN_PLAN, -20002)`
  - Mensaje: `'El usuario tiene N perfiles activos. El plan X solo permite M.'`

**🗄️ Disparadores (mínimo 4)**
- `TRG_VALIDAR_CUENTA_ACTIVA` — BEFORE INSERT ON REPRODUCCIONES, FOR EACH ROW:
  - Consultar estado de cuenta del usuario dueño del perfil
  - Si `estado_cuenta != 'ACTIVO'` → `RAISE_APPLICATION_ERROR(-20010, ...)`

- `TRG_LIMITE_PERFILES` — BEFORE INSERT ON PERFILES, FOR EACH ROW:
  - Contar perfiles existentes del usuario
  - Obtener máximo del plan actual (Básico: 2, Estándar: 3, Premium: 5)
  - Si se excede → `RAISE_APPLICATION_ERROR(-20011, ...)`

- `TRG_VALIDAR_CALIFICACION` — BEFORE INSERT ON CALIFICACIONES, FOR EACH ROW:
  - Verificar que el perfil tenga una reproducción con `porcentaje_avance >= 50` para ese contenido
  - Si no existe → `RAISE_APPLICATION_ERROR(-20012, ...)`

- `TRG_ACTIVAR_CUENTA_PAGO` — AFTER INSERT ON PAGOS, FOR EACH ROW (nivel sentencia si se prefiere):
  - Si `:NEW.estado_pago = 'EXITOSO'`:
    - `UPDATE USUARIOS SET estado_cuenta = 'ACTIVO', fecha_ultimo_pago = SYSDATE WHERE id_usuario = :NEW.id_usuario`

- `TRG_RESTRICCION_PERFIL_INFANTIL` (bonus) — BEFORE INSERT ON REPRODUCCIONES, FOR EACH ROW:
  - Si el perfil es INFANTIL, verificar que la clasificación del contenido sea TP, +7 o +13
  - Si no → rechazar la reproducción

### Entregables
- `05_NT2_excepciones_triggers.sql`
- Demostración de cada trigger: INSERT que lo activa correctamente + INSERT que lo rechaza.

---

## Sprint 6 — Transacciones y Concurrencia (Núcleo 3 — NT3)
**Objetivo:** Diseñar, documentar e implementar las 3 transacciones críticas y el escenario de concurrencia.

### Tareas

**🗄️ Transacción 1 — Registro completo de usuario**
```sql
-- T1: Crear usuario + perfil + primer pago. Todo o nada.
BEGIN
  -- Estado: ACTIVA
  INSERT INTO USUARIOS ...;
  SAVEPOINT sp_usuario_creado;
  
  INSERT INTO PERFILES ...;
  SAVEPOINT sp_perfil_creado;
  
  INSERT INTO PAGOS ... (estado = 'PENDIENTE');
  -- Estado: PARCIALMENTE CONFIRMADA
  COMMIT;
  -- Estado: CONFIRMADA
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    -- Estado: ABORTADA
    RAISE;
END;
```

**🗄️ Transacción 2 — Renovación mensual masiva**
```sql
-- T2: Para cada usuario activo, calcular monto y registrar pago.
-- SAVEPOINT por usuario para no perder los anteriores si uno falla.
BEGIN
  FOR u IN (SELECT * FROM USUARIOS WHERE estado_cuenta = 'ACTIVO') LOOP
    SAVEPOINT sp_usuario_actual;
    BEGIN
      -- Calcular monto con FN_CALCULAR_MONTO
      -- INSERT INTO PAGOS
      -- UPDATE fecha_vencimiento
      COMMIT; -- o acumular y hacer COMMIT al final
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO sp_usuario_actual;
        -- Log del error, continuar con siguiente usuario
    END;
  END LOOP;
END;
```

**🗄️ Transacción 3 — Eliminación de cuenta (todo o nada)**
```sql
-- T3: Eliminar en cascada respetando FK: calificaciones → favoritos
--     → reproducciones → reportes → perfiles → pagos → usuario
BEGIN
  DELETE FROM CALIFICACIONES WHERE id_perfil IN (...);
  SAVEPOINT sp_cal;
  DELETE FROM FAVORITOS WHERE id_perfil IN (...);
  SAVEPOINT sp_fav;
  DELETE FROM REPRODUCCIONES WHERE id_perfil IN (...);
  SAVEPOINT sp_rep;
  DELETE FROM REPORTES_CONTENIDO WHERE id_perfil IN (...);
  DELETE FROM PERFILES WHERE id_usuario = :p_id;
  DELETE FROM PAGOS WHERE id_usuario = :p_id;
  DELETE FROM USUARIOS WHERE id_usuario = :p_id;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
```

**🗄️ Escenario de concurrencia — Cambio de plan simultáneo**
- Abrir **Sesión A** y **Sesión B** en SQL Developer
- Sesión A: `SELECT * FROM USUARIOS WHERE id_usuario = 5 FOR UPDATE;` (bloquea la fila)
- Sesión B: Intenta `UPDATE USUARIOS SET id_plan = 2 WHERE id_usuario = 5;` (queda en espera)
- Documentar: qué ve cada sesión, cómo Oracle gestiona el bloqueo, qué pasa al hacer `COMMIT` en A
- Capturas de pantalla obligatorias

### Entregables
- `06_NT3_transacciones.sql`
- Sección de documentación del escenario de concurrencia con capturas (en el doc de sustentación).

---

## Sprint 7 — Índices y Análisis de Rendimiento (Núcleo 4 — NT4)
**Objetivo:** Crear los índices justificados y demostrar mejora de rendimiento con EXPLAIN PLAN.

### Tareas

**🗄️ Creación de índices (mínimo 4)**
```sql
-- IDX1: Historial de reproducciones por perfil ordenado por fecha
CREATE INDEX IDX_REPRO_PERFIL_FECHA 
  ON REPRODUCCIONES(id_perfil, fecha_hora_inicio);
-- Justificación: la consulta más frecuente del sistema es el historial
-- de un perfil. Sin índice hace full scan de 200k+ filas.

-- IDX2: Login y validación de email duplicado en registro
CREATE UNIQUE INDEX IDX_USUARIOS_EMAIL 
  ON USUARIOS(email);
-- Justificación: cada login y cada registro valida unicidad de email.
-- Con índice: búsqueda O(log n). Sin él: full scan de la tabla.

-- IDX3: Búsquedas de catálogo por categoría y año
CREATE INDEX IDX_CONTENIDO_CAT_ANIO 
  ON CONTENIDO(id_categoria, anio_lanzamiento);
-- Justificación: las búsquedas del catálogo siempre filtran por
-- categoría y opcionalmente por rango de años.

-- IDX4: Consultas de pagos por usuario y fecha (reporte financiero)
CREATE INDEX IDX_PAGOS_USUARIO_FECHA 
  ON PAGOS(id_usuario, fecha_pago, estado_pago);
-- Justificación: FN_CALCULAR_MONTO y los reportes financieros consultan
-- pagos de un usuario en un periodo; este índice cubre ambos filtros.
```

**🗄️ Análisis de rendimiento — EXPLAIN PLAN (mínimo 1 comparación)**
- Consulta elegida: top 10 contenidos más reproducidos filtrando por ciudad y rango de fechas
- Ejecutar `EXPLAIN PLAN FOR <consulta>` **antes** de crear `IDX_REPRO_PERFIL_FECHA`
  - Capturar costo, `FULL TABLE SCAN`, cardinalidad estimada
- Crear el índice
- Ejecutar `EXPLAIN PLAN FOR <consulta>` **después**
  - Capturar costo, `INDEX RANGE SCAN`, diferencia de costo
- Análisis escrito: porcentaje de mejora, explicación de por qué el índice ayuda

### Entregables
- `07_NT4_indices.sql`
- Capturas de EXPLAIN PLAN antes y después (para el doc de sustentación).

---

## Sprint 8 — Seguridad: Usuarios y Roles de Oracle (Núcleo 5 — NT5)
**Objetivo:** Implementar el esquema completo de seguridad en Oracle con roles diferenciados.

### Tareas

**🗄️ Creación de roles**
```sql
CREATE ROLE ROL_ADMIN;
CREATE ROLE ROL_ANALISTA;
CREATE ROLE ROL_SOPORTE;
CREATE ROLE ROL_CONTENIDO;
```

**🗄️ Privilegios por rol**
- `ROL_ADMIN`: CRUD en todas las tablas + ejecutar todos los SPs + CREATE/DROP USER
- `ROL_ANALISTA`: SELECT en todas las tablas + ejecutar SPs de reporte + acceso a vistas materializadas
- `ROL_SOPORTE`: SELECT en USUARIOS/PERFILES/PAGOS, INSERT/UPDATE en PAGOS, ejecutar `SP_CAMBIAR_PLAN`
- `ROL_CONTENIDO`: CRUD en CONTENIDO/TEMPORADAS/EPISODIOS/GENEROS + SELECT en REPRODUCCIONES/CALIFICACIONES

**🗄️ Creación de usuarios Oracle (mínimo 1 por rol)**
```sql
CREATE USER usr_admin      IDENTIFIED BY Admin2025#;
CREATE USER usr_analista   IDENTIFIED BY Analista2025#;
CREATE USER usr_soporte    IDENTIFIED BY Soporte2025#;
CREATE USER usr_contenido  IDENTIFIED BY Contenido2025#;

GRANT ROL_ADMIN     TO usr_admin;
GRANT ROL_ANALISTA  TO usr_analista;
GRANT ROL_SOPORTE   TO usr_soporte;
GRANT ROL_CONTENIDO TO usr_contenido;
GRANT CREATE SESSION TO usr_admin, usr_analista, usr_soporte, usr_contenido;
```

**🗄️ Perfil de recursos Oracle**
```sql
CREATE PROFILE PERFIL_QUINDIOFLIX LIMIT
  SESSIONS_PER_USER        3
  IDLE_TIME                30       -- minutos
  FAILED_LOGIN_ATTEMPTS    5
  PASSWORD_LOCK_TIME       1/24     -- 1 hora
  CONNECT_TIME             480;     -- 8 horas máximo por sesión

ALTER USER usr_soporte    PROFILE PERFIL_QUINDIOFLIX;
ALTER USER usr_contenido  PROFILE PERFIL_QUINDIOFLIX;
```

**🗄️ Demostración de restricción de acceso**
- Conectarse como `usr_soporte` e intentar `DELETE FROM CONTENIDO` → capturar error ORA-01031
- Conectarse como `usr_analista` e intentar `INSERT INTO PAGOS` → capturar error ORA-01031
- Conectarse como `usr_contenido` e intentar `SELECT * FROM PAGOS` (sin permiso) → error esperado

### Entregables
- `08_NT5_usuarios_roles.sql`
- Capturas de los errores de acceso denegado (para el doc de sustentación).

---

## Sprint 9 — API REST: Controladores y Servicios Core
**Objetivo:** Implementar los endpoints REST principales del backend Spring Boot conectados a Oracle.

### Tareas

**☕ Capa Repository**
- Crear interfaces `JdbcTemplate`-based o `@Repository` con `NamedParameterJdbcTemplate` para:
  - `UsuarioRepository` — CRUD + búsqueda por email
  - `ContenidoRepository` — búsqueda por categoría, género, año
  - `ReproduccionRepository` — inserciones y consultas de historial
  - `PagoRepository` — registro y consulta de pagos
- **Nota:** Usar `JdbcTemplate` en lugar de JPA/Hibernate para mantener control total sobre las queries Oracle y compatibilidad con los SPs.

**☕ Capa Service**
- `UsuarioService` — delegar a `SP_REGISTRAR_USUARIO` y `SP_CAMBIAR_PLAN` vía `SimpleJdbcCall`
- `ContenidoService` — CRUD de catálogo
- `ReproduccionService` — registrar y consultar reproducciones
- `ReporteService` — ejecutar consultas avanzadas y devolver DTOs estructurados

**☕ Controladores REST**

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/usuarios` | POST | Registrar usuario (llama `SP_REGISTRAR_USUARIO`) |
| `/api/usuarios/{id}` | GET | Obtener datos del usuario |
| `/api/usuarios/{id}/plan` | PUT | Cambiar plan (llama `SP_CAMBIAR_PLAN`) |
| `/api/usuarios/{id}/perfiles` | GET/POST | Listar o crear perfiles |
| `/api/contenido` | GET | Listar catálogo con filtros (categoría, género, año) |
| `/api/contenido/{id}` | GET | Detalle de un contenido |
| `/api/contenido` | POST | Agregar contenido al catálogo |
| `/api/reproducciones` | POST | Registrar reproducción |
| `/api/perfiles/{id}/historial` | GET | Historial de reproducciones de un perfil |
| `/api/perfiles/{id}/favoritos` | GET/POST/DELETE | Gestión de favoritos |
| `/api/perfiles/{id}/calificaciones` | POST | Calificar contenido |
| `/api/pagos` | POST | Registrar pago |
| `/api/pagos/{id_usuario}` | GET | Historial de pagos |
| `/api/reportes/consumo-ciudad` | GET | Reporte por ciudad (usa MV o PIVOT) |
| `/api/reportes/ingresos` | GET | Reporte financiero (usa `MV_INGRESOS_MENSUALES`) |
| `/api/reportes/contenido-popular` | GET | Usa `MV_CONTENIDO_POPULAR` |

**☕ DTOs y mappers**
- `UsuarioDTO`, `PerfilDTO`, `ContenidoDTO`, `ReproduccionDTO`, `PagoDTO`
- `ReporteConsumoDTO`, `ReporteIngresosDTO`, `ReporteContenidoPopularDTO`

**☕ Integración con Stored Procedures**
```java
// Ejemplo de llamada a SP_REGISTRAR_USUARIO desde Java
SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
    .withProcedureName("SP_REGISTRAR_USUARIO")
    .declareParameters(
        new SqlParameter("p_nombre", Types.VARCHAR),
        new SqlParameter("p_email", Types.VARCHAR),
        // ... demás parámetros
        new SqlOutParameter("p_resultado", Types.INTEGER),
        new SqlOutParameter("p_mensaje", Types.VARCHAR)
    );
```

### Entregables
- Todos los endpoints funcionando y retornando `ApiResponse<T>` correctamente.
- Errores de SPs de Oracle mapeados a respuestas HTTP apropiadas (400, 409, 500).

---

## Sprint 10 — Seguridad Spring: JWT y Control de Acceso
**Objetivo:** Activar Spring Security con autenticación JWT y mapear los roles de Oracle a los roles de Spring.

### Tareas

**🔐 Autenticación JWT**
- Agregar dependencia `spring-security-oauth2-jose` o librería JWT (jjwt).
- `POST /api/auth/login`: recibe email + contraseña, valida contra `USUARIOS`, retorna JWT.
- `POST /api/auth/logout`: invalida sesión (blacklist de tokens o stateless).
- Filtro `JwtAuthenticationFilter` que valida el token en cada request.

**🔐 Autorización por rol**
Mapear roles de Oracle a roles Spring Security:

| Rol Oracle | Rol Spring | Acceso |
|------------|-----------|--------|
| ROL_ADMIN | ROLE_ADMIN | Todos los endpoints |
| ROL_ANALISTA | ROLE_ANALISTA | Endpoints de reportes (GET) |
| ROL_SOPORTE | ROLE_SOPORTE | Endpoints de usuarios y pagos |
| ROL_CONTENIDO | ROLE_CONTENIDO | Endpoints de catálogo |
| (usuarios finales) | ROLE_USER | Sus propios datos y reproducciones |

**🔐 Configuración de SecurityConfig**
```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/auth/**").permitAll()
            .requestMatchers("/api/reportes/**").hasAnyRole("ADMIN", "ANALISTA")
            .requestMatchers(HttpMethod.POST, "/api/contenido/**").hasAnyRole("ADMIN", "CONTENIDO")
            .requestMatchers("/api/pagos/**").hasAnyRole("ADMIN", "SOPORTE")
            .anyRequest().authenticated()
        )
        .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
}
```

**🔐 Seguridad a nivel de método**
- Usar `@PreAuthorize("hasRole('ADMIN') or #id == authentication.principal.id")` en endpoints donde un usuario solo puede ver sus propios datos.

### Entregables
- Endpoint `/api/auth/login` funcional con JWT.
- Endpoints protegidos rechazan requests sin token o con rol incorrecto (403).

---

## Sprint 11 — Pruebas de Integración y Documentación Final
**Objetivo:** Verificar que toda la solución funciona end-to-end y generar la documentación de sustentación.

### Tareas

**🧪 Pruebas de la base de datos**
- Ejecutar todos los scripts en orden en una instancia Oracle limpia:
  1. `01_DDL_tablas.sql`
  2. `02_DML_datos_prueba.sql`
  3. `03_NT1_consultas_avanzadas.sql`
  4. `04_NT2_cursores_sp_funciones.sql`
  5. `05_NT2_excepciones_triggers.sql`
  6. `06_NT3_transacciones.sql`
  7. `07_NT4_indices.sql`
  8. `08_NT5_usuarios_roles.sql`
- Verificar cero errores en cada script.
- Ejecutar pruebas de los triggers: insertar datos que los activen y datos que los rechacen.

**🧪 Pruebas de los endpoints REST**
- Colección de Postman o archivo `.http` con al menos un request por endpoint.
- Probar flujo completo: registro → login → reproducir contenido → calificar → pago.
- Probar acceso denegado: token de analista intentando insertar en `/api/contenido`.

**📄 Documento de sustentación (máximo 10 páginas)**
Secciones obligatorias:
1. **Decisiones de diseño del modelo de datos** — por qué se eligieron las relaciones, tipos de datos y normalizaciones aplicadas
2. **Justificación de fragmentación** — por qué particionar `REPRODUCCIONES` por año
3. **Análisis de índices** — tablas EXPLAIN PLAN con interpretación
4. **Escenario de concurrencia** — capturas y análisis de `SELECT FOR UPDATE`
5. **Justificación de la jerarquía de empleados** — relación reflexiva en `EMPLEADOS`
6. **Decisiones de seguridad** — por qué los privilegios de cada rol son suficientes y no excesivos

**📄 README.md del proyecto**
- Instrucciones para ejecutar los scripts en orden
- Instrucciones para arrancar el backend Spring Boot
- Variables de entorno requeridas
- Descripción de cada archivo `.sql`

### Entregables
- Todos los scripts ejecutan sin errores en Oracle limpio.
- Colección de Postman exportada.
- Documento de sustentación en Word o PDF.
- `README.md` actualizado.

---

## Resumen de Entregables por Sprint

| Sprint | Entregable Principal | Núcleo |
|--------|---------------------|--------|
| 0 | Proyecto configurado + `/api/health` | — |
| 1 | `01_DDL_tablas.sql` | Modelo Físico |
| 2 | `02_DML_datos_prueba.sql` | Datos |
| 3 | `03_NT1_consultas_avanzadas.sql` | NT1 (25%) |
| 4 | `04_NT2_cursores_sp_funciones.sql` | NT2 (30%) |
| 5 | `05_NT2_excepciones_triggers.sql` | NT2 (30%) |
| 6 | `06_NT3_transacciones.sql` | NT3 (15%) |
| 7 | `07_NT4_indices.sql` | NT4 (10%) |
| 8 | `08_NT5_usuarios_roles.sql` | NT5 (10%) |
| 9 | Controladores + Servicios REST | Backend |
| 10 | JWT + Spring Security | Seguridad App |
| 11 | Tests + Doc sustentación | Calidad (10%) |

---

## Dependencias Entre Sprints

```
Sprint 0 (setup)
    └── Sprint 1 (DDL)
            └── Sprint 2 (DML)
                    ├── Sprint 3 (NT1 - Consultas)
                    ├── Sprint 4 (NT2 - SPs/Cursores)
                    │       └── Sprint 5 (NT2 - Triggers)
                    │               └── Sprint 6 (NT3 - Transacciones)
                    ├── Sprint 7 (NT4 - Índices)
                    └── Sprint 8 (NT5 - Roles Oracle)
                            └── Sprint 9 (API REST)
                                    └── Sprint 10 (Spring Security)
                                            └── Sprint 11 (Tests + Docs)
```

> **Regla de oro:** No avanzar al siguiente sprint si el actual tiene scripts que fallan en Oracle. Un modelo de datos sólido (Sprints 1 y 2) es la base de todo lo demás.

---

*QuindioFlix — Proyecto Final Bases de Datos II — Universidad del Quindío 2025-1*
