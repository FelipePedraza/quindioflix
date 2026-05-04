# QuindioFlix — Plan Maestro Fusionado v2.0

> **Proyecto Final — Bases de Datos II**
> Universidad del Quindío · Facultad de Ingeniería · Ingeniería de Sistemas y Computación
> Semestre 2026-1

---

## Tabla de Contenidos

1. [Resumen Ejecutivo y Contexto IA](#1-resumen-ejecutivo-y-contexto-ia)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Stack Tecnológico](#3-stack-tecnológico)
4. [Estructura de Directorios](#4-estructura-de-directorios)
5. [Modelo de Datos — Especificación Completa](#5-modelo-de-datos--especificación-completa)
6. [Mapeo Oracle → Java → TypeScript](#6-mapeo-oracle--java--typescript)
7. [Plan de Implementación por Núcleos Temáticos](#7-plan-de-implementación-por-núcleos-temáticos)
8. [Especificación Técnica del Backend](#8-especificación-técnica-del-backend)
9. [Especificación Técnica del Frontend](#9-especificación-técnica-del-frontend)
10. [Estrategia de Datos de Prueba](#10-estrategia-de-datos-de-prueba)
11. [Cronograma y Plan de Entregas](#11-cronograma-y-plan-de-entregas)
12. [Convenciones y Nomenclatura](#12-convenciones-y-nomenclatura)
13. [Checklist de Calidad por Entrega](#13-checklist-de-calidad-por-entrega)
14. [Riesgos y Mitigación](#14-riesgos-y-mitigación)
15. [Anexos Técnicos](#15-anexos-técnicos)

---

## 1. Resumen Ejecutivo y Contexto IA

### 1.1 Naturaleza del Proyecto

QuindioFlix es una plataforma de streaming de contenido multimedia que opera en Colombia. El proyecto final del curso de Bases de Datos II requiere diseñar, implementar y administrar una base de datos Oracle completa que soporte toda la operación del negocio: gestión de catálogo, usuarios, suscripciones, reproducciones, pagos, moderación y reportes analíticos.

El proyecto cubre **5 núcleos temáticos** del curso, distribuidos en **3 entregas parciales** con retroalimentación progresiva.

| Núcleo | Tema | Peso |
|--------|------|------|
| NT1 | Consultas avanzadas y almacenamiento | 25% |
| NT2 | PL/SQL — Procedimientos y disparadores | 30% |
| NT3 | Transacciones | 15% |
| NT4 | Índices | 10% |
| NT5 | Administración de acceso a BD | 10% |
| — | Calidad general | 10% |

### 1.2 Contexto de Desarrollo por IA

Este documento está diseñado para ser leído y ejecutado por una IA con capacidad de razonamiento y generación de código. Esto implica las siguientes decisiones de diseño del documento:

- **Especificidad sobre abstracción**: Cada requerimiento incluye el archivo exacto donde se implementa, los tipos de datos concretos, las firmas de métodos y los patrones de código esperados.
- **Trazabilidad completa**: Cada regla de negocio se traza hasta el artefacto de código que la implementa (trigger, SP, constraint, validación Java, componente React).
- **Decisiones técnicas justificadas**: No se deja la IA adivinar entre JPA y JdbcTemplate, entre `ddl-auto: none` y `validate`, o entre Groovy DSL y Kotlin DSL. Cada decisión está documentada con su razón.
- **Sin ambigüedades**: Cuando el enunciado dice "máximo 5 perfiles", este documento dice exactamente dónde se valida (TRG_PERFILES_BI trigger + CHECK constraint + validación en PerfilService.java + feedback en CambioPlanForm.tsx).
- **Orden de implementación explícito**: Las dependencias entre archivos están claras. No se puede implementar `SP_REGISTRAR_USUARIO` sin haber creado las tablas USUARIOS, PERFILES y PAGOS.

### 1.3 Principios Arquitectónicos

| Principio | Descripción | Implicación IA |
|-----------|-------------|----------------|
| **Database-first** | El modelo de datos es el núcleo. Todo arranca desde el MER y se propaga hacia arriba. | Generar scripts SQL antes que entidades JPA. Las entidades JPA son un reflejo de las tablas, no al revés. |
| **Lógica pesada en Oracle** | Validaciones complejas, cálculos y disparadores residen en PL/SQL. Spring Boot orquesta. | Cuando existe un SP/trigger para una operación, el service de Spring Boot DEBE delegar a ese SP/trigger, NO reimplementar la validación en Java. |
| **JPA para lectura, JDBC para PL/SQL** | JPA para CRUD simple de tablas maestras. JdbcTemplate/SimpleJdbcCall para todo lo que involucre PL/SQL, cursores, PIVOT, MVs. | Nunca intentar mapear un cursor PL/SQL a JPQL. Nunca intentar leer una vista materializada con un repositorio JPA estándar. |
| **Scripts idempotentes** | Todo script SQL debe poder ejecutarse múltiples veces sin errores. | Usar `CREATE OR REPLACE`, `DROP TABLE ... PURGE` con manejo de excepciones, y verificar existencia antes de crear. |
| **Separación database/ del código** | Los scripts SQL son el entregable principal del curso. Deben ejecutarse independientemente de Spring Boot. | La carpeta `database/` es autocontenida. El backend la consume pero no la modifica ni la genera. |

---

## 2. Arquitectura del Sistema

### 2.1 Vista General de Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                       │
│                 React 18 + Vite 5 + TypeScript 5              │
│          Tailwind CSS · Axios · React Router · Zustand        │
│       Componentes · Páginas · Hooks · API modules · Types     │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTP REST API (JSON)
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                    CAPA DE LÓGICA                             │
│             Spring Boot 3.3.x + Java 21 LTS                  │
│       Gradle 8.x (Kotlin DSL) · Spring Data JPA + JDBC       │
│   Controllers · Services · Repositories · DTOs · Exceptions   │
│            (Delegación a PL/SQL vía SimpleJdbcCall)           │
│            (Lectura de MVs y reportes vía JdbcTemplate)        │
└───────────────────────────┬──────────────────────────────────┘
                            │ JDBC / Oracle Driver (ojdbc11)
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                    CAPA DE DATOS                              │
│                   Oracle Database 21c XE                       │
│  Tablas · Vistas Materializadas · PL/SQL · Índices            │
│  Tablespaces · Roles · Perfiles · Triggers · Transacciones    │
│  Particiones · Secuencias · Constraints · Comentarios         │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Flujo de Datos Principal — Trazabilidad Completa

Cada operación del sistema sigue un flujo específico. La IA debe respetar estos flujos sin saltarse capas:

```
OPERACIÓN: Registrar Usuario
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. React: RegistroForm.tsx → POST /api/usuarios con {nombre, email, telefono, ...}
2. Spring: UsuarioController.crearUsuario(RegistroUsuarioRequest)
3. Spring: UsuarioService.registrarUsuario(RegistroUsuarioRequest)
4. Spring: SimpleJdbcCall("SP_REGISTRAR_USUARIO") → Oracle
5. Oracle: SP_REGISTRAR_USUARIO ejecuta:
   a. Valida email no duplicado (excepción E_EMAIL_DUPLICADO si falla)
   b. INSERT INTO USUARIOS (activa TRG_PERFILES_BI si se crea perfil)
   c. INSERT INTO PERFILES (perfil adulto por defecto)
   d. INSERT INTO PAGOS (activa TRG_PAGOS_AIU → actualiza estado_cuenta)
   e. COMMIT o ROLLBACK según resultado
6. Spring: Captura excepción Oracle → GlobalExceptionHandler → HTTP 422/400
7. React: Maneja respuesta → éxito (redirect a login) o error (toast con mensaje)

OPERACIÓN: Registrar Reproducción
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. React: PlayerSimulator.tsx → POST /api/reproducciones
2. Spring: ReproduccionController.crear(ReproduccionRequest)
3. Spring: ReproduccionService.crear(ReproduccionRequest)
4. Spring: JdbcTemplate.update("INSERT INTO REPRODUCCIONES ...") → Oracle
5. Oracle: TRG_REPRODUCCIONES_BI ejecuta BEFORE INSERT:
   a. Verifica USUARIOS.estado_cuenta = 'ACTIVO'
   b. Si INACTIVO → RAISE_APPLICATION_ERROR(-20001, 'Cuenta inactiva')
6. Spring: DataIntegrityViolationException → GlobalExceptionHandler → HTTP 422
7. React: Muestra "Tu cuenta está inactiva. Realiza tu pago para continuar."

OPERACIÓN: Calificar Contenido
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. React: ResenaForm.tsx → POST /api/calificaciones
2. Spring: CalificacionController.crear(CalificacionRequest)
3. Spring: CalificacionService.crear(CalificacionRequest)
4. Spring: JdbcTemplate.update("INSERT INTO CALIFICACIONES ...") → Oracle
5. Oracle: TRG_CALIFICACIONES_BI ejecuta BEFORE INSERT:
   a. Verifica porcentaje_avance >= 50 en REPRODUCCIONES para ese perfil+contenido
   b. Si < 50% → RAISE_APPLICATION_ERROR(-20002, 'Debes ver al menos el 50%')
6. Spring: DataIntegrityViolationException → GlobalExceptionHandler → HTTP 422
7. React: Muestra "Debes reproducir al menos el 50% del contenido para calificar."

OPERACIÓN: Cambiar Plan
━━━━━━━━━━━━━━━━━━━━━━
1. React: CambioPlanForm.tsx → PUT /api/usuarios/{id}/plan
2. Spring: UsuarioController.cambiarPlan(id, CambioPlanRequest)
3. Spring: UsuarioService.cambiarPlan(id, CambioPlanRequest)
4. Spring: SimpleJdbcCall("SP_CAMBIAR_PLAN") → Oracle
5. Oracle: SP_CAMBIAR_PLAN ejecuta:
   a. Cuenta perfiles actuales del usuario
   b. Si perfiles > límite del nuevo plan → RAISE_APPLICATION_ERROR(-20003, 'Exceso de perfiles')
   c. UPDATE SUSCRIPCIONES SET id_plan = nuevo, fecha_vencimiento = ADD_MONTHS(fecha_inicio, 1)
   d. COMMIT
6. Spring: Captura excepción → GlobalExceptionHandler → HTTP 422
7. React: Muestra "No puedes bajar de plan: tienes más perfiles de los permitidos."

OPERACIÓN: Consultar Reporte
━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. React: ReportePopularidad.tsx → GET /api/reportes/contenido-popular
2. Spring: ReporteController.getContenidoPopular(limit)
3. Spring: ReporteService.getContenidoPopular(limit)
4. Spring: JdbcTemplate.queryForList("SELECT * FROM MV_CONTENIDO_POPULAR ...") → Oracle
5. Oracle: Lee MV_CONTENIDO_POPULAR (refrescada manualmente vía POST /api/reportes/refrescar-mvs)
6. Spring: Devuelve List<Map<String, Object>> como JSON
7. React: Renderiza tabla/gráfica con datos
```

### 2.3 Principio Clave: Dónde Implementar Cada Regla

La IA NUNCA debe duplicar lógica. Cada regla de negocio se implementa en **un solo lugar** (el más apropiado), y las capas superiores solo delegan o manejan errores:

| Tipo de Regla | Se implementa en | Las capas superiores |
|---------------|-----------------|---------------------|
| Integridad referencial (FK) | Oracle (constraint) | No validan, dejan que Oracle rechace |
| Restricciones de dominio (CHECK) | Oracle (constraint) | No validan, dejan que Oracle rechace |
| Reglas跨-tabla complejas | Oracle (trigger BEFORE) | Service captura la excepción Oracle |
| Operaciones multi-tabla atómicas | Oracle (SP con transacción) | Service llama al SP vía SimpleJdbcCall |
| Cálculos con descuentos | Oracle (función PL/SQL) | Service llama a la función vía JdbcTemplate |
| Reportes analíticos | Oracle (MV + PIVOT + ROLLUP) | Service lee vía JdbcTemplate nativo |
| Validación de formato (email, teléfono) | Spring Boot (Bean Validation) | Controller valida antes de enviar a Oracle |
| Transformación de datos para UI | React (formatters, validators) | No implementa reglas de negocio, solo presentación |
| Errores Oracle → mensajes usuario | Spring Boot (GlobalExceptionHandler) | Mapea ORA-xxxx → mensaje legible → HTTP 422/400 |

---

## 3. Stack Tecnológico

### 3.1 Stack Detallado con Justificación

| Capa | Tecnología | Versión | Justificación |
|------|-----------|---------|---------------|
| **Frontend** | React + Vite | React 18, Vite 5 | Build rápido, HMR, ecosistema maduro |
| **Lenguaje Frontend** | TypeScript | 5.x | Tipado estático, interfaces para cada DTO |
| **Estilos** | Tailwind CSS | 3.x | Utilidad-first, prototipado rápido |
| **HTTP Client** | Axios | 1.x | Interceptors para manejo centralizado de errores Oracle |
| **Estado** | Zustand | 4.x | Minimalista, sin boilerplate, ideal para IA |
| **Routing** | React Router | 6.x | Ecosistema estándar de React |
| **Backend** | Spring Boot | 3.3.x | Convención sobre configuración |
| **Build Backend** | Gradle (Kotlin DSL) | 8.x | Tipado en build scripts, mejor para generación por IA |
| **Lenguaje Backend** | Java | 21 LTS | Record classes, pattern matching, virtual threads |
| **ORM** | Spring Data JPA | (incluido en Boot) | CRUD simple de tablas maestras de lectura |
| **SQL Nativo** | JdbcTemplate + SimpleJdbcCall | (incluido en Boot) | SP, funciones, MVs, PIVOT, cursores |
| **Validación** | Bean Validation (Hibernate Validator) | (incluido en Boot) | @NotNull, @Email, @Size en DTOs |
| **Documentación API** | SpringDoc OpenAPI | 2.6+ | Swagger UI autogenerado |
| **Base de Datos** | Oracle Database | 21c XE (XEPDB1) | Requisito del curso |
| **Driver JDBC** | ojdbc11 + UCP | 23.5+ | Driver oficial, connection pooling UCP |
| **Diagramas MER** | draw.io / Oracle Data Modeler | — | Exportación PNG profesional |
| **Control de Versiones** | Git + GitHub | — | Ramas por entrega, PRs para revisión |

### 3.2 Dependencias Gradle (`build.gradle.kts`)

```kotlin
plugins {
    java
    id("org.springframework.boot") version "3.3.5"
    id("io.spring.dependency-management") version "1.1.6"
}

group = "co.edu.uniquindio"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot Starters
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-jdbc")
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // Oracle JDBC + Connection Pooling
    runtimeOnly("com.oracle.database.jdbc:ojdbc11:23.5.0.24.07")
    runtimeOnly("com.oracle.database.jdbc:ucp:23.5.0.24.07")

    // Swagger / OpenAPI
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.0")

    // Lombok (reduce boilerplate en entidades y DTOs)
    compileOnly("org.projectlombok:lombok")
    annotationProcessor("org.projectlombok:lombok")

    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
}
```

### 3.3 Configuración `application.yml`

```yaml
spring:
  datasource:
    url: jdbc:oracle:thin:@//localhost:1521/XEPDB1
    username: qflix_admin
    password: qflix_pass          # Cambiar por variable de entorno en producción
    driver-class-name: oracle.jdbc.OracleDriver
    type: oracle.ucp.jdbc.PoolDataSourceImpl   # UCP connection pooling
    oracleucp:
      connection-pool-name: QFLIX_POOL
      initial-pool-size: 5
      min-pool-size: 2
      max-pool-size: 15

  jpa:
    hibernate:
      ddl-auto: validate          # VALIDATE: confirma que entidades JPA coinciden con tablas Oracle
    show-sql: false               # En true solo para depuración
    properties:
      hibernate:
        dialect: org.hibernate.dialect.OracleDialect
        format_sql: true
        jdbc:
          time_zone: UTC          # Evita desfases con fechas Oracle

server:
  port: 8080

springdoc:
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
```

> **Decisión crítica: `ddl-auto: validate`**. Spring Boot NO debe crear ni modificar tablas. Las tablas ya existen con particiones, secuencias y constraints creadas por los scripts SQL. `validate` asegura que las entidades JPA coinciden con las tablas; si hay desajuste, la app no arranca y el error es evidente de inmediato.

---

## 4. Estructura de Directorios

### 4.1 Estructura Raíz del Proyecto

```
quindioflix/
│
├── README.md
├── .gitignore
├── .editorconfig
│
├── database/                              # NÚCLEO — Scripts Oracle SQL/PLSQL
│   ├── README.md                          # Instrucciones de ejecución
│   │
│   ├── 01_schema/                         # Esquema y tablespaces
│   │   ├── 001_create_tablespaces.sql
│   │   ├── 002_create_user_schema.sql
│   │   └── 003_grant_base_privileges.sql
│   │
│   ├── 02_ddl/                            # CREATE TABLE (tablas)
│   │   ├── 001_planes.sql
│   │   ├── 002_categorias.sql
│   │   ├── 003_generos.sql
│   │   ├── 004_contenido.sql
│   │   ├── 005_temporadas.sql
│   │   ├── 006_episodios.sql
│   │   ├── 007_contenido_genero.sql
│   │   ├── 008_contenido_relacionado.sql
│   │   ├── 009_usuarios.sql
│   │   ├── 010_suscripciones.sql
│   │   ├── 011_perfiles.sql
│   │   ├── 012_referidos.sql
│   │   ├── 013_reproducciones.sql          # Incluye particionamiento por rango
│   │   ├── 014_calificaciones.sql
│   │   ├── 015_favoritos.sql
│   │   ├── 016_reportes_contenido.sql
│   │   ├── 017_departamentos.sql
│   │   ├── 018_empleados.sql
│   │   ├── 019_pagos.sql
│   │   └── 020_seq_and_defaults.sql
│   │
│   ├── 03_dml/                            # Datos de prueba
│   │   ├── 001_planes.sql
│   │   ├── 002_categorias_generos.sql
│   │   ├── 003_contenido.sql
│   │   ├── 004_temporadas_episodios.sql
│   │   ├── 005_usuarios_suscripciones.sql
│   │   ├── 006_perfiles.sql
│   │   ├── 007_referidos.sql
│   │   ├── 008_reproducciones.sql
│   │   ├── 009_calificaciones.sql
│   │   ├── 010_favoritos.sql
│   │   ├── 011_reportes_contenido.sql
│   │   ├── 012_departamentos_empleados.sql
│   │   └── 013_pagos.sql
│   │
│   ├── 04_nt1_consultas/                  # Núcleo 1: Consultas avanzadas
│   │   ├── 01_parametrizadas.sql
│   │   ├── 02_pivot_unpivot.sql
│   │   ├── 03_group_by_avanzado.sql
│   │   ├── 04_vistas_materializadas.sql
│   │   └── 05_fragmentacion.sql
│   │
│   ├── 05_nt2_plsql/                      # Núcleo 2: PL/SQL
│   │   ├── 01_cursors.sql
│   │   ├── 02_procedimientos.sql
│   │   ├── 03_funciones.sql
│   │   ├── 04_excepciones.sql
│   │   └── 05_triggers.sql
│   │
│   ├── 06_nt3_transacciones/              # Núcleo 3: Transacciones
│   │   ├── 01_transaccion_registro.sql
│   │   ├── 02_transaccion_renovacion.sql
│   │   ├── 03_transaccion_eliminacion.sql
│   │   └── 04_concurrencia_demo.sql
│   │
│   ├── 07_nt4_indices/                    # Núcleo 4: Índices
│   │   ├── 01_creacion_indices.sql
│   │   ├── 02_explain_plan_before.sql
│   │   ├── 03_explain_plan_after.sql
│   │   └── capturas/
│   │       ├── explain_before_01.png
│   │       └── explain_after_01.png
│   │
│   ├── 08_nt5_roles/                      # Núcleo 5: Usuarios y roles
│   │   ├── 01_creacion_roles.sql
│   │   ├── 02_creacion_usuarios.sql
│   │   ├── 03_grant_privilegios.sql
│   │   ├── 04_profiles.sql
│   │   └── 05_demo_restricciones.sql
│   │
│   └── 99_drop_all.sql                    # Limpieza total
│
├── backend/                               # Spring Boot (Gradle Kotlin DSL)
│   ├── build.gradle.kts
│   ├── settings.gradle.kts
│   ├── gradle/
│   │   └── wrapper/
│   │
│   └── src/
│       ├── main/
│       │   ├── java/co/edu/uniquindio/quindioflix/
│       │   │   ├── QuindioFlixApplication.java
│       │   │   │
│       │   │   ├── config/
│       │   │   │   ├── OracleConfig.java          # UCP DataSource + JdbcTemplate bean
│       │   │   │   ├── OpenApiConfig.java         # Swagger UI
│       │   │   │   ├── CorsConfig.java            # CORS para React
│       │   │   │   └── WebConfig.java             # Interceptores
│       │   │   │
│       │   │   ├── entity/                        # Entidades JPA (reflejo de tablas Oracle)
│       │   │   │   ├── Plan.java
│       │   │   │   ├── Categoria.java
│       │   │   │   ├── Genero.java
│       │   │   │   ├── Contenido.java
│       │   │   │   ├── Temporada.java
│       │   │   │   ├── Episodio.java
│       │   │   │   ├── Usuario.java
│       │   │   │   ├── Suscripcion.java
│       │   │   │   ├── Perfil.java
│       │   │   │   ├── Reproduccion.java
│       │   │   │   ├── ReproduccionId.java        # @Embeddable para clave compuesta
│       │   │   │   ├── Calificacion.java
│       │   │   │   ├── Favorito.java
│       │   │   │   ├── FavoritoId.java            # @Embeddable para clave compuesta
│       │   │   │   ├── ReporteContenido.java
│       │   │   │   ├── Departamento.java
│       │   │   │   ├── Empleado.java
│       │   │   │   └── Pago.java
│       │   │   │
│       │   │   ├── repository/                    # Spring Data JPA repos
│       │   │   │   ├── PlanRepository.java
│       │   │   │   ├── CategoriaRepository.java
│       │   │   │   ├── GeneroRepository.java
│       │   │   │   ├── ContenidoRepository.java
│       │   │   │   ├── TemporadaRepository.java
│       │   │   │   ├── EpisodioRepository.java
│       │   │   │   ├── UsuarioRepository.java
│       │   │   │   ├── SuscripcionRepository.java
│       │   │   │   ├── PerfilRepository.java
│       │   │   │   ├── CalificacionRepository.java
│       │   │   │   ├── PagoRepository.java
│       │   │   │   ├── EmpleadoRepository.java
│       │   │   │   └── DepartamentoRepository.java
│       │   │   │
│       │   │   ├── dto/
│       │   │   │   ├── request/
│       │   │   │   │   ├── RegistroUsuarioRequest.java
│       │   │   │   │   ├── CambioPlanRequest.java
│       │   │   │   │   ├── ReproduccionRequest.java
│       │   │   │   │   ├── CalificacionRequest.java
│       │   │   │   │   ├── PagoRequest.java
│       │   │   │   │   └── ReporteContenidoRequest.java
│       │   │   │   │
│       │   │   │   └── response/
│       │   │   │       ├── UsuarioResponse.java
│       │   │   │       ├── ContenidoResponse.java
│       │   │   │       ├── PerfilResponse.java
│       │   │   │       ├── SuscripcionResponse.java
│       │   │   │       ├── ReporteConsumoResponse.java
│       │   │   │       ├── ContenidoPopularResponse.java
│       │   │   │       ├── IngresosMensualesResponse.java
│       │   │   │       └── ErrorResponse.java
│       │   │   │
│       │   │   ├── service/                       # Lógica de negocio (delega a PL/SQL)
│       │   │   │   ├── UsuarioService.java
│       │   │   │   ├── ContenidoService.java
│       │   │   │   ├── PerfilService.java
│       │   │   │   ├── SuscripcionService.java
│       │   │   │   ├── ReproduccionService.java
│       │   │   │   ├── CalificacionService.java
│       │   │   │   ├── PagoService.java
│       │   │   │   ├── EmpleadoService.java
│       │   │   │   └── ReporteService.java        # Lee MVs + ejecuta PIVOT/ROLLUP
│       │   │   │
│       │   │   ├── controller/                    # REST Controllers
│       │   │   │   ├── UsuarioController.java
│       │   │   │   ├── ContenidoController.java
│       │   │   │   ├── PerfilController.java
│       │   │   │   ├── SuscripcionController.java
│       │   │   │   ├── ReproduccionController.java
│       │   │   │   ├── CalificacionController.java
│       │   │   │   ├── PagoController.java
│       │   │   │   ├── EmpleadoController.java
│       │   │   │   └── ReporteController.java
│       │   │   │
│       │   │   ├── exception/
│       │   │   │   ├── GlobalExceptionHandler.java  # ORA-xxxx → HTTP status
│       │   │   │   ├── QuindioFlixException.java
│       │   │   │   ├── ResourceNotFoundException.java
│       │   │   │   ├── BusinessException.java
│       │   │   │   └── DuplicateResourceException.java
│       │   │   │
│       │   │   └── util/
│       │   │       ├── FechaUtil.java
│       │   │       └── ValidadorUtil.java
│       │   │
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       └── application-prod.yml
│       │
│       └── test/
│           └── java/co/edu/uniquindio/quindioflix/
│               ├── service/
│               │   ├── UsuarioServiceTest.java
│               │   └── PagoServiceTest.java
│               └── controller/
│                   └── UsuarioControllerTest.java
│
├── frontend/                              # React + Vite + TypeScript
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── index.html
│   │
│   └── src/
│       ├── main.tsx
│       ├── App.tsx
│       │
│       ├── api/
│       │   ├── axios.ts                    # Instancia Axios con interceptors
│       │   ├── usuario.api.ts
│       │   ├── contenido.api.ts
│       │   ├── perfil.api.ts
│       │   ├── suscripcion.api.ts
│       │   ├── reproduccion.api.ts
│       │   ├── calificacion.api.ts
│       │   ├── pago.api.ts
│       │   └── reporte.api.ts
│       │
│       ├── components/
│       │   ├── common/
│       │   │   ├── Navbar.tsx
│       │   │   ├── Sidebar.tsx
│       │   │   ├── Card.tsx
│       │   │   ├── Modal.tsx
│       │   │   ├── Table.tsx
│       │   │   ├── Button.tsx
│       │   │   ├── Input.tsx
│       │   │   ├── Select.tsx
│       │   │   ├── LoadingSpinner.tsx
│       │   │   ├── ErrorMessage.tsx       # Componente para errores Oracle
│       │   │   └── Toast.tsx              # Notificaciones
│       │   │
│       │   ├── layout/
│       │   │   ├── MainLayout.tsx
│       │   │   ├── AuthLayout.tsx
│       │   │   └── Footer.tsx
│       │   │
│       │   ├── contenido/
│       │   │   ├── ContenidoCard.tsx
│       │   │   ├── ContenidoList.tsx
│       │   │   ├── ContenidoDetail.tsx
│       │   │   └── ContenidoForm.tsx
│       │   │
│       │   ├── usuario/
│       │   │   ├── RegistroForm.tsx
│       │   │   ├── PerfilSelector.tsx
│       │   │   └── CambioPlanForm.tsx
│       │   │
│       │   ├── reproduccion/
│       │   │   ├── PlayerSimulator.tsx
│       │   │   └── HistorialReproducciones.tsx
│       │   │
│       │   ├── calificacion/
│       │   │   ├── StarRating.tsx
│       │   │   └── ResenaForm.tsx
│       │   │
│       │   ├── reportes/
│       │   │   ├── ReporteConsumo.tsx
│       │   │   ├── ReporteFinanciero.tsx
│       │   │   └── ReportePopularidad.tsx
│       │   │
│       │   └── admin/
│       │       ├── EmpleadoList.tsx
│       │       ├── ModeracionPanel.tsx
│       │       └── DashboardAdmin.tsx
│       │
│       ├── pages/
│       │   ├── Home.tsx
│       │   ├── Login.tsx
│       │   ├── Registro.tsx
│       │   ├── Catalogo.tsx
│       │   ├── ContenidoDetalle.tsx
│       │   ├── Perfil.tsx
│       │   ├── Favoritos.tsx
│       │   ├── Suscripcion.tsx
│       │   ├── Pagos.tsx
│       │   ├── Reportes.tsx
│       │   ├── AdminDashboard.tsx
│       │   └── NotFound.tsx
│       │
│       ├── hooks/
│       │   ├── useAuth.ts
│       │   ├── useContenido.ts
│       │   ├── usePerfil.ts
│       │   └── useReportes.ts
│       │
│       ├── store/
│       │   ├── authStore.ts               # Zustand store
│       │   └── uiStore.ts                 # Toasts, modales, sidebar
│       │
│       ├── types/
│       │   ├── usuario.types.ts
│       │   ├── contenido.types.ts
│       │   ├── perfil.types.ts
│       │   ├── suscripcion.types.ts
│       │   ├── reproduccion.types.ts
│       │   ├── calificacion.types.ts
│       │   ├── pago.types.ts
│       │   ├── reporte.types.ts
│       │   └── api.types.ts              # ErrorResponse, PaginatedResponse, etc.
│       │
│       ├── utils/
│       │   ├── formatters.ts
│       │   ├── validators.ts
│       │   └── constants.ts
│       │
│       └── styles/
│           └── globals.css
│
├── docs/                                  # Documentación del proyecto
│   ├── modelo-negocio/
│   │   ├── ActoresProcesos.md
│   │   ├── ReglasNegocio.md
│   │   └── RestriccionesDominio.md
│   │
│   ├── modelo-datos/
│   │   ├── MER.png
│   │   ├── ModeloRelacional.png
│   │   └── Normalizacion.md
│   │
│   ├── entregas/
│   │   ├── entrega1/
│   │   ├── entrega2/
│   │   └── entrega3/
│   │
│   └── sustentacion/
│       └── DocumentoSustentacion.md
│
└── scripts/                               # Scripts utilitarios
    ├── setup-oracle.sh
    ├── run-all-scripts.sh
    ├── run-entrega1.sh
    ├── run-entrega2.sh
    ├── run-entrega3.sh
    ├── reset-database.sh
    └── generate-test-data.py
```

---

## 5. Modelo de Datos — Especificación Completa

### 5.1 Identificación de Entidades

A partir del análisis del enunciado, se identifican las siguientes entidades principales:

| # | Entidad | Tabla Oracle | Descripción | Atributos Clave |
|---|---------|-------------|-------------|-----------------|
| 1 | **PLAN_SUSCRIPCION** | PLANES | Planes de suscripción disponibles | id_plan, nombre, pantallas_simultaneas, calidad, precio_mensual |
| 2 | **CATEGORIA** | CATEGORIAS | Tipo de contenido (Película, Serie, etc.) | id_categoria, nombre |
| 3 | **GENERO** | GENEROS | Géneros del contenido | id_genero, nombre |
| 4 | **CONTENIDO** | CONTENIDO | Título del catálogo | id_contenido, titulo, anio_lanzamiento, duracion, sinopsis, clasificacion_edad, fecha_agregado, es_produccion_original, id_categoria, id_empleado_publicador |
| 5 | **CONTENIDO_GENERO** | CONTENIDO_GENERO | Relación N:M contenido↔géneros | id_contenido, id_genero |
| 6 | **CONTENIDO_RELACIONADO** | CONTENIDO_RELACIONADO | Relación reflexiva entre contenidos | id_contenido_origen, id_contenido_relacionado, tipo_relacion |
| 7 | **TEMPORADA** | TEMPORADAS | Temporadas de series y podcasts | id_temporada, numero_temporada, id_contenido |
| 8 | **EPISODIO** | EPISODIOS | Episodios de cada temporada | id_episodio, titulo, duracion, numero_episodio, id_temporada |
| 9 | **USUARIO** | USUARIOS | Usuarios de la plataforma | id_usuario, nombre, email, telefono, fecha_nacimiento, ciudad_residencia, fecha_registro, estado_cuenta, fecha_ultimo_pago |
| 10 | **SUSCRIPCION** | SUSCRIPCIONES | Suscripción activa del usuario | id_suscripcion, id_usuario, id_plan, fecha_inicio, fecha_vencimiento, estado |
| 11 | **PERFIL** | PERFILES | Perfiles dentro de una cuenta | id_perfil, id_usuario, nombre, avatar, tipo_perfil |
| 12 | **REFERIDO** | REFERIDOS | Relación de referidos entre usuarios | id_usuario_refiere, id_usuario_referido, fecha, beneficio_otorgado |
| 13 | **REPRODUCCION** | REPRODUCCIONES | Registro de reproducciones (PARTICIONADA) | id_reproduccion, id_perfil, id_contenido, id_episodio (nullable), fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance |
| 14 | **CALIFICACION** | CALIFICACIONES | Calificaciones de contenido | id_calificacion, id_perfil, id_contenido, estrellas, resena, fecha |
| 15 | **FAVORITO** | FAVORITOS | Lista de favoritos por perfil | id_perfil, id_contenido, fecha_agregado |
| 16 | **REPORTE_CONTENIDO** | REPORTES_CONTENIDO | Reportes de contenido inapropiado | id_reporte, id_perfil_reportante, id_contenido, descripcion, fecha_reporte, id_empleado_moderador, estado, fecha_resolucion, resolucion |
| 17 | **DEPARTAMENTO** | DEPARTAMENTOS | Departamentos de QuindioFlix | id_departamento, nombre, id_jefe |
| 18 | **EMPLEADO** | EMPLEADOS | Empleados de la empresa | id_empleado, nombre, email, id_departamento, id_supervisor, fecha_contratacion |
| 19 | **PAGO** | PAGOS | Registros de pagos | id_pago, id_usuario, fecha_pago, monto, metodo_pago, estado_pago, fecha_vencimiento |

### 5.2 Relaciones Clave

| Relación | Tipo | Cardinalidad | Tabla Intermedia | Notas |
|----------|------|-------------|-----------------|-------|
| Contenido → Categoría | Binaria | N:1 | — | FK en CONTENIDO |
| Contenido ↔ Genero | Binaria N:M | N:M | CONTENIDO_GENERO | PK compuesta |
| Contenido ↔ Contenido | Unaria reflexiva | N:M | CONTENIDO_RELACIONADO | tipo_relacion distingue |
| Serie/Podcast → Temporada → Episodio | Binaria 1:N:N | — | — | Solo series y podcasts |
| Usuario → Suscripcion → Plan | Binaria 1:1:1 | — | — | Una suscripción activa por usuario |
| Usuario → Perfil | Binaria 1:N | — | — | Máximo según plan (2, 3, 5) |
| Usuario ↔ Usuario (Referido) | Unaria reflexiva | 1:N | REFERIDOS | Un usuario refiere a muchos |
| Perfil → Reproduccion → Contenido/Episodio | Binaria 1:N | — | — | Un perfil tiene muchas reproducciones |
| Perfil → Calificacion → Contenido | Binaria 1:N | — | — | Solo si reprodujo >= 50% |
| Perfil → Favorito → Contenido | Binaria N:M | N:M | FAVORITOS | PK compuesta (id_perfil, id_contenido) |
| Perfil → Reporte → Contenido | Binaria 1:N | — | — | Un perfil reporta contenido |
| Empleado → Departamento | Binaria N:1 | — | — | Con jefe del departamento |
| Empleado ↔ Empleado (Supervisor) | Unaria reflexiva | 1:N | — | Mismo departamento |
| Empleado → Contenido (publicación) | Binaria 1:N | — | — | Empleado responsable |
| Empleado → Reporte (moderación) | Binaria 1:N | — | — | Moderador resuelve reportes |
| Usuario → Pago | Binaria 1:N | — | — | Múltiples pagos |

### 5.3 Reglas de Negocio — Trazabilidad Completa

Cada regla se traza hasta el artefacto de código que la implementa. La IA debe respetar esta trazabilidad sin duplicar lógica.

| # | Regla | Fuente | Se implementa en | Artefacto |
|---|-------|--------|-----------------|-----------|
| 1 | Un usuario solo puede tener una suscripción activa a la vez | Explícita 1.2 | Oracle constraint + SP | UNIQUE constraint en SUSCRIPCIONES(id_usuario) WHERE estado='ACTIVA' + SP_REGISTRAR_USUARIO valida |
| 2 | Máximo perfiles por plan: Básico=2, Estándar=3, Premium=5 | Explícita 1.2 | Oracle trigger | TRG_PERFILES_BI (BEFORE INSERT ON PERFILES) |
| 3 | Perfiles infantiles solo acceden a contenido TP, +7, +13 | Explícita 1.2 | Oracle trigger | TRG_REPRODUCCIONES_BI (verifica tipo_perfil + clasificacion_edad) |
| 4 | Si no paga en 30 días tras vencimiento → cuenta desactiva | Explícita 1.5 | Oracle trigger | TRG_PAGOS_AIU (AFTER INSERT/UPDATE) actualiza estado_cuenta + JOB Oracle |
| 5 | Referido activo → descuento en próximo pago | Explícita 1.5 | Oracle función | FN_CALCULAR_MONTO incluye descuento por referido |
| 6 | Una película no tiene temporadas ni episodios | Explícita 1.1 | Oracle trigger + UI | TRG_TEMPORADAS_BI verifica id_categoria + React oculta sección |
| 7 | Solo series y podcasts tienen temporadas y episodios | Implícita 1.1 | Oracle trigger | TRG_TEMPORADAS_BI (BEFORE INSERT) |
| 8 | Cada empleado tiene un solo supervisor directo | Explícita 1.4 | Oracle FK | FK id_supervisor → EMPLEADOS.id_empleado |
| 9 | Supervisor y supervisado en mismo departamento | Implícita 1.4 | Oracle trigger | TRG_EMPLEADOS_BI verifica depto |
| 10 | Jefe de departamento es empleado del mismo depto | Explícita 1.4 | Oracle trigger | TRG_DEPARTAMENTOS_BI verifica |
| 11 | Un contenido puede relacionarse con otro de igual o distinto tipo | Explícita 1.1 | Oracle CHECK | CHECK (id_contenido_origen <> id_contenido_relacionado) |
| 12 | Perfil debe haber reproducido >=50% para poder calificar | Explícita 3.2.5 | Oracle trigger | TRG_CALIFICACIONES_BI (BEFORE INSERT) |
| 13 | Métodos de pago: tarjeta crédito, débito, PSE, Nequi, Daviplata | Explícita 1.5 | Oracle CHECK | CHECK (metodo_pago IN ('TARJETA_CREDITO','TARJETA_DEBITO','PSE','NEQUI','DAVIPLATA')) |
| 14 | Clasificaciones de edad: TP, +7, +13, +16, +18 | Explícita 1.1 | Oracle CHECK | CHECK (clasificacion_edad IN ('TP','+7','+13','+16','+18')) |
| 15 | Estados de pago: exitoso, fallido, pendiente, reembolsado | Explícita 1.5 | Oracle CHECK | CHECK (estado_pago IN ('EXITOSO','FALLIDO','PENDIENTE','REEMBOLSADO')) |
| 16 | Antigüedad >12m → 10% descuento; >24m → 15% | Implícita 3.2.3 | Oracle función | FN_CALCULAR_MONTO calcula descuento por antigüedad |
| 17 | No bajar de plan si perfiles exceden límite del nuevo plan | Explícita 3.2.2 | Oracle SP | SP_CAMBIAR_PLAN valida y rechaza con -20003 |
| 18 | Empleado de Contenido es responsable de la publicación | Explícita 1.4 | Oracle FK | CONTENIDO.id_empleado_publicador → EMPLEADOS.id_empleado |
| 19 | Moderadores (Soporte) resuelven reportes de contenido | Explícita 1.4 | Oracle FK | REPORTES_CONTENIDO.id_empleado_moderador → EMPLEADOS.id_empleado |
| 20 | Descuento por referido aplica solo una vez por referido | Implícita 1.2+1.5 | Oracle SP | SP procesa pago y marca REFERIDOS.beneficio_otorgado='SI' |

### 5.4 Restricciones de Dominio

| Tabla | Columna | Tipo Oracle | Restricción |
|-------|---------|-------------|-------------|
| PLANES | id_plan | NUMBER | PK, GENERATED ALWAYS AS IDENTITY |
| PLANES | nombre | VARCHAR2(50) | NOT NULL, UNIQUE |
| PLANES | pantallas_simultaneas | NUMBER | NOT NULL, CHECK IN (1, 2, 4) |
| PLANES | calidad | VARCHAR2(10) | NOT NULL, CHECK IN ('SD', 'HD', '4K') |
| PLANES | precio_mensual | NUMBER(10,2) | NOT NULL, CHECK > 0 |
| CATEGORIAS | nombre | VARCHAR2(50) | NOT NULL, UNIQUE |
| GENEROS | nombre | VARCHAR2(50) | NOT NULL, UNIQUE |
| CONTENIDO | clasificacion_edad | VARCHAR2(5) | NOT NULL, CHECK IN ('TP','+7','+13','+16','+18') |
| CONTENIDO | duracion | NUMBER | NOT NULL, CHECK > 0 |
| CONTENIDO | anio_lanzamiento | NUMBER(4) | CHECK BETWEEN 1900 AND EXTRACT(YEAR FROM SYSDATE) |
| CONTENIDO | es_produccion_original | NUMBER(1) | CHECK IN (0, 1) |
| USUARIOS | email | VARCHAR2(100) | NOT NULL, UNIQUE, formato email |
| USUARIOS | estado_cuenta | VARCHAR2(15) | NOT NULL, DEFAULT 'ACTIVO', CHECK IN ('ACTIVO','INACTIVO','SUSPENDIDO') |
| USUARIOS | fecha_registro | TIMESTAMP | DEFAULT SYSTIMESTAMP |
| PERFILES | tipo_perfil | VARCHAR2(10) | NOT NULL, DEFAULT 'ADULTO', CHECK IN ('ADULTO','INFANTIL') |
| SUSCRIPCIONES | estado | VARCHAR2(15) | NOT NULL, CHECK IN ('ACTIVA','VENCIDA','CANCELADA') |
| REPRODUCCIONES | porcentaje_avance | NUMBER(5,2) | NOT NULL, CHECK BETWEEN 0 AND 100 |
| REPRODUCCIONES | dispositivo | VARCHAR2(15) | NOT NULL, CHECK IN ('CELULAR','TABLET','TV','COMPUTADOR') |
| REPRODUCCIONES | fecha_hora_inicio | TIMESTAMP | NOT NULL, clave de partición |
| CALIFICACIONES | estrellas | NUMBER(1) | NOT NULL, CHECK BETWEEN 1 AND 5 |
| PAGOS | metodo_pago | VARCHAR2(20) | NOT NULL, CHECK IN ('TARJETA_CREDITO','TARJETA_DEBITO','PSE','NEQUI','DAVIPLATA') |
| PAGOS | estado_pago | VARCHAR2(15) | NOT NULL, CHECK IN ('EXITOSO','FALLIDO','PENDIENTE','REEMBOLSADO') |
| PAGOS | monto | NUMBER(10,2) | NOT NULL, CHECK > 0 |
| REPORTES_CONTENIDO | estado | VARCHAR2(15) | DEFAULT 'PENDIENTE', CHECK IN ('PENDIENTE','EN_REVISION','RESUELTO','DESESTIMADO') |
| REFERIDOS | beneficio_otorgado | VARCHAR2(5) | DEFAULT 'NO', CHECK IN ('SI','NO') |

### 5.5 Particionamiento de REPRODUCCIONES

La tabla REPRODUCCIONES se particiona por rango en `fecha_hora_inicio` para demostrar fragmentación (NT1):

```sql
CREATE TABLE REPRODUCCIONES (
    id_reproduccion    NUMBER        NOT NULL,
    id_perfil          NUMBER        NOT NULL,
    id_contenido       NUMBER        NOT NULL,
    id_episodio        NUMBER,
    fecha_hora_inicio  TIMESTAMP     NOT NULL,
    fecha_hora_fin     TIMESTAMP,
    dispositivo        VARCHAR2(15)  NOT NULL,
    porcentaje_avance  NUMBER(5,2)   NOT NULL,
    CONSTRAINT pk_reproducciones PRIMARY KEY (id_reproduccion, fecha_hora_inicio),
    CONSTRAINT fk_rep_perfil FOREIGN KEY (id_perfil) REFERENCES PERFILES(id_perfil),
    CONSTRAINT fk_rep_contenido FOREIGN KEY (id_contenido) REFERENCES CONTENIDO(id_contenido),
    CONSTRAINT fk_rep_episodio FOREIGN KEY (id_episodio) REFERENCES EPISODIOS(id_episodio),
    CONSTRAINT chk_avance CHECK (porcentaje_avance BETWEEN 0 AND 100),
    CONSTRAINT chk_dispositivo CHECK (dispositivo IN ('CELULAR','TABLET','TV','COMPUTADOR'))
)
PARTITION BY RANGE (fecha_hora_inicio) (
    PARTITION P_REP_2024 VALUES LESS THAN (TO_DATE('2025-01-01','YYYY-MM-DD'))
        TABLESPACE TS_REP_2024,
    PARTITION P_REP_2025 VALUES LESS THAN (TO_DATE('2026-01-01','YYYY-MM-DD'))
        TABLESPACE TS_REP_2025,
    PARTITION P_REP_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
        TABLESPACE TS_REP_2026,
    PARTITION P_REP_FUTURO VALUES LESS THAN (MAXVALUE)
        TABLESPACE TS_REP_FUTURO
);
```

> **Implicación JPA**: La clave primaria de REPRODUCCIONES es compuesta (`id_reproduccion` + `fecha_hora_inicio`). Esto requiere `@EmbeddedId` en la entidad Java. Ver sección 6.

### 5.6 Verificación de Normalización (3FN)

**1FN**: Todos los atributos son atómicos. No hay grupos repetitivos. Las relaciones N:M se resuelven con tablas intermedias (CONTENIDO_GENERO, CONTENIDO_RELACIONADO, FAVORITOS).

**2FN**: En tablas intermedias con PK compuesta (CONTENIDO_GENERO, CONTENIDO_RELACIONADO, FAVORITOS), todos los atributos no-clave dependen de la PK completa. No hay dependencias parciales.

**3FN**: No hay dependencias transitivas. Cada columna no-clave depende directamente de la PK, no de otra columna no-clave. Ejemplo: USUARIOS tiene `id_usuario` como PK y no incluye `nombre_plan` (que dependería transitivamente a través de SUSCRIPCIONES → PLANES).

---

## 6. Mapeo Oracle → Java → TypeScript

Esta sección es crítica para la IA: define exactamente cómo se traduce cada tipo y estructura de datos entre las tres capas.

### 6.1 Mapeo de Tipos de Datos

| Oracle | Java (JPA Entity) | TypeScript (types) | Notas |
|--------|-------------------|-------------------|-------|
| NUMBER | Long / Integer / BigDecimal | number | Long para PKs, BigDecimal para montos |
| NUMBER(1) | Boolean / Integer | boolean | 0/1 en Oracle, true/false en TS |
| NUMBER(10,2) | BigDecimal | number | Montos, porcentajes |
| VARCHAR2(n) | String | string | — |
| TIMESTAMP | LocalDateTime | string (ISO 8601) | Serializar como "2025-03-15T14:30:00" |
| DATE | LocalDate | string (ISO 8601) | Serializar como "2025-03-15" |
| CLOB | String | string | Sinopsis largas |

### 6.2 Mapeo de Claves Compuestas

#### REPRODUCCIONES — Clave compuesta (id_reproduccion + fecha_hora_inicio)

```java
// ReproduccionId.java
@Embeddable
public class ReproduccionId implements Serializable {
    @Column(name = "ID_REPRODUCCION")
    private Long idReproduccion;

    @Column(name = "FECHA_HORA_INICIO")
    private LocalDateTime fechaHoraInicio;

    // equals() y hashCode() obligatorios
}

// Reproduccion.java
@Entity
@Table(name = "REPRODUCCIONES")
public class Reproduccion {
    @EmbeddedId
    private ReproduccionId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_PERFIL")
    private Perfil perfil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_CONTENIDO")
    private Contenido contenido;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_EPISODIO")
    private Episodio episodio;

    @Column(name = "FECHA_HORA_FIN")
    private LocalDateTime fechaHoraFin;

    @Column(name = "DISPOSITIVO")
    private String dispositivo;

    @Column(name = "PORCENTAJE_AVANCE")
    private BigDecimal porcentajeAvance;
}
```

> **Patrón IA**: Para REPRODUCCIONES, dado que la tabla está particionada y tiene clave compuesta, las inserciones se hacen vía `JdbcTemplate`, NO vía JPA `save()`. JPA se usa solo para lecturas simples.

#### FAVORITOS — Clave compuesta (id_perfil + id_contenido)

```java
@Embeddable
public class FavoritoId implements Serializable {
    @Column(name = "ID_PERFIL")
    private Long idPerfil;

    @Column(name = "ID_CONTENIDO")
    private Long idContenido;
}

@Entity
@Table(name = "FAVORITOS")
public class Favorito {
    @EmbeddedId
    private FavoritoId id;

    @Column(name = "FECHA_AGREGADO")
    private LocalDateTime fechaAgregado;
}
```

### 6.3 Mapeo de Relaciones JPA

```java
// Relación N:M — Contenido ↔ Genero
@Entity
@Table(name = "CONTENIDO")
public class Contenido {
    @ManyToMany
    @JoinTable(
        name = "CONTENIDO_GENERO",
        joinColumns = @JoinColumn(name = "ID_CONTENIDO"),
        inverseJoinColumns = @JoinColumn(name = "ID_GENERO")
    )
    private Set<Genero> generos = new HashSet<>();
}

// Relación reflexiva — Usuario referidor
@Entity
@Table(name = "USUARIOS")
public class Usuario {
    @ManyToOne
    @JoinColumn(name = "ID_REFERIDOR")
    private Usuario referidor;

    @OneToMany(mappedBy = "referidor")
    private List<Usuario> referidos = new ArrayList<>();
}

// Relación 1:1 — Usuario → Suscripcion activa
@Entity
@Table(name = "SUSCRIPCIONES")
public class Suscripcion {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_USUARIO")
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_PLAN")
    private Plan plan;
}

// Relación reflexiva — Empleado supervisor
@Entity
@Table(name = "EMPLEADOS")
public class Empleado {
    @ManyToOne
    @JoinColumn(name = "ID_SUPERVISOR")
    private Empleado supervisor;

    @OneToMany(mappedBy = "supervisor")
    private List<Empleado> supervisados = new ArrayList<>();
}
```

### 6.4 Estrategia JPA vs JdbcTemplate — Matriz de Decisión

| Operación | Usar | Razón | Ejemplo |
|-----------|------|-------|---------|
| Leer tabla maestra (planes, categorías) | JPA Repository | CRUD simple, sin PL/SQL | `planRepository.findAll()` |
| Buscar usuario por email | JPA Repository | Query derivada | `usuarioRepository.findByEmail(email)` |
| Llamar SP_REGISTRAR_USUARIO | SimpleJdbcCall | SP con parámetros OUT | `call.execute(params)` |
| Llamar FN_CALCULAR_MONTO | JdbcTemplate | `SELECT fn() FROM DUAL` | `jt.queryForObject(sql, BigDecimal.class)` |
| Insertar en REPRODUCCIONES | JdbcTemplate | Tabla particionada, clave compuesta, trigger | `jt.update(sql, params...)` |
| Insertar en CALIFICACIONES | JdbcTemplate | Trigger BEFORE INSERT | `jt.update(sql, params...)` |
| Leer MV_CONTENIDO_POPULAR | JdbcTemplate | Vista materializada, columnas dinámicas | `jt.queryForList(sql)` |
| Ejecutar PIVOT / ROLLUP | JdbcTemplate | SQL analítico, columnas dinámicas | `jt.queryForList(sql)` |
| Refrescar vista materializada | JdbcTemplate | `DBMS_MVIEW.REFRESH` | `jt.execute("CALL DBMS_MVIEW.REFRESH(...)")` |
| Transacción completa (TX1, TX2, TX3) | `@Transactional` + JDBC | Spring maneja la transacción | Service con `@Transactional` |
| CRUD simple de Contenido | JPA Repository | Sin PL/SQL involucrado | `contenidoRepository.save(contenido)` |

---

## 7. Plan de Implementación por Núcleos Temáticos

### 7.1 NT1 — Consultas Avanzadas y Almacenamiento

| Requerimiento | Cantidad | Archivo SQL | Endpoint Backend | Componente React |
|---------------|----------|-------------|-----------------|------------------|
| Consultas parametrizadas | Mín. 3 | `01_parametrizadas.sql` | `GET /api/reportes/top-contenido-ciudad?ciudad=...`, `GET /api/reportes/ingresos-periodo?mes=&anio=`, `GET /api/reportes/calificacion-promedio?genero=` | ReporteConsumo.tsx |
| PIVOT | Mín. 2 | `02_pivot_unpivot.sql` | `GET /api/reportes/usuarios-por-ciudad-plan`, `GET /api/reportes/reproducciones-por-dispositivo` | ReporteFinanciero.tsx |
| UNPIVOT | Mín. 2 | `02_pivot_unpivot.sql` | (Se demuestra en SQL*Plus, resultado expuesto vía endpoint) | — |
| ROLLUP / CUBE / GROUPING SETS | Mín. 4 | `03_group_by_avanzado.sql` | `GET /api/reportes/ingresos-rollup`, `GET /api/reportes/reproducciones-cube`, `GET /api/reportes/reproducciones-grouping-sets` | ReporteFinanciero.tsx |
| Vistas materializadas | Mín. 2 | `04_vistas_materializadas.sql` | `GET /api/reportes/contenido-popular`, `GET /api/reportes/ingresos-mensuales`, `POST /api/reportes/refrescar-mvs` | ReportePopularidad.tsx, ReporteFinanciero.tsx |
| Fragmentación (particionamiento) | Mín. 1 | `05_fragmentacion.sql` | Verificado vía `POST /api/reproducciones` con fechas de distintas particiones | PlayerSimulator.tsx |

**Notas de implementación para la IA:**
- Las vistas materializadas usan `REFRESH COMPLETE ON DEMAND`. El endpoint `POST /api/reportes/refrescar-mvs` ejecuta `DBMS_MVIEW.REFRESH` para ambas MVs.
- La fragmentación se implementa con `PARTITION BY RANGE(fecha_hora_inicio)` en tablespaces separados. El script DDL de REPRODUCCIONES (013_reproducciones.sql) ya incluye las particiones.
- Para UNPIVOT, transformar los resultados de los PIVOT previos para demostrar la operación inversa.
- Los endpoints de reportes devuelven `List<Map<String, Object>>` porque las columnas son dinámicas (especialmente PIVOT).

### 7.2 NT2 — PL/SQL

| Requerimiento | Cantidad | Archivo SQL | Firma / Detalle | Endpoint Backend |
|---------------|----------|-------------|----------------|-----------------|
| Cursores explícitos | Mín. 2 | `01_cursors.sql` | 1) Cursor: usuarios morosos (>30 días sin pago) con DBMS_OUTPUT 2) Cursor FOR UPDATE: popularidad contenido (reproducciones >=90%) | `GET /api/reportes/morosos`, `GET /api/reportes/popularidad` |
| Procedimientos almacenados | Mín. 3 | `02_procedimientos.sql` | `SP_REGISTRAR_USUARIO(p_nombre, p_email, p_telefono, p_fecha_nac, p_ciudad, p_id_plan, p_resultado OUT)` · `SP_CAMBIAR_PLAN(p_id_usuario, p_id_nuevo_plan, p_resultado OUT)` · `SP_REPORTE_CONSUMO(p_id_usuario, p_cursor OUT SYS_REFCURSOR)` | `POST /api/usuarios/registrar`, `PUT /api/usuarios/{id}/plan`, `GET /api/usuarios/{id}/reporte-consumo` |
| Funciones | Mín. 2 | `03_funciones.sql` | `FN_CALCULAR_MONTO(p_id_usuario) RETURN NUMBER` · `FN_CONTENIDO_RECOMENDADO(p_id_perfil) RETURN VARCHAR2` | `GET /api/usuarios/{id}/monto-proximo-mes`, `GET /api/perfiles/{id}/recomendacion` |
| Excepciones personalizadas | Mín. 2 | `04_excepciones.sql` | `E_EMAIL_DUPLICADO` (-20001), `E_PERFILES_EXCEDIDOS` (-20003) | GlobalExceptionHandler captura ORA-20001 y ORA-20003 → HTTP 422 |
| Disparadores | Mín. 4 | `05_triggers.sql` | Ver tabla 7.3 | — |

**Patrones de código para llamar SP/funciones desde Spring Boot:**

```java
// Patrón: Llamar SP con SimpleJdbcCall
public String registrarUsuario(RegistroUsuarioRequest dto) {
    SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
        .withProcedureName("SP_REGISTRAR_USUARIO");

    MapSqlParameterSource params = new MapSqlParameterSource()
        .addValue("P_NOMBRE", dto.getNombre())
        .addValue("P_EMAIL", dto.getEmail())
        .addValue("P_TELEFONO", dto.getTelefono())
        .addValue("P_FECHA_NAC", dto.getFechaNacimiento())
        .addValue("P_CIUDAD", dto.getCiudadResidencia())
        .addValue("P_ID_PLAN", dto.getIdPlan());

    Map<String, Object> result = call.execute(params);
    return (String) result.get("P_RESULTADO");
}

// Patrón: Llamar función con JdbcTemplate
public BigDecimal calcularMontoProximoMes(Long idUsuario) {
    String sql = "SELECT FN_CALCULAR_MONTO(?) FROM DUAL";
    return jdbcTemplate.queryForObject(sql, BigDecimal.class, idUsuario);
}

// Patrón: Leer cursor de salida de SP
public List<Map<String, Object>> getReporteConsumo(Long idUsuario) {
    SimpleJdbcCall call = new SimpleJdbcCall(jdbcTemplate)
        .withProcedureName("SP_REPORTE_CONSUMO")
        .returningResultSet("P_CURSOR", new ColumnMapRowMapper());

    MapSqlParameterSource params = new MapSqlParameterSource()
        .addValue("P_ID_USUARIO", idUsuario);

    Map<String, Object> result = call.execute(params);
    return (List<Map<String, Object>>) result.get("P_CURSOR");
}
```

### 7.3 Disparadores — Detalle Completo

| Trigger | Tabla | Evento | Lógica | Error si falla |
|---------|-------|--------|--------|----------------|
| TRG_REPRODUCCIONES_BI | REPRODUCCIONES | BEFORE INSERT FOR EACH ROW | 1. Verifica USUARIOS.estado_cuenta = 'ACTIVO' (vía PERFIL→USUARIO) 2. Si perfil INFANTIL, verifica CONTENIDO.clasificacion_edad IN ('TP','+7','+13') | ORA-20001: "Cuenta inactiva, no se pueden registrar reproducciones" / ORA-20004: "Contenido no permitido para perfil infantil" |
| TRG_PERFILES_BI | PERFILES | BEFORE INSERT FOR EACH ROW | 1. Cuenta perfiles actuales del usuario 2. Consulta PLANES.pantallas_simultaneas (como proxy de límite de perfiles) 3. Si count >= límite → rechaza | ORA-20003: "Excede el límite de perfiles para su plan" |
| TRG_CALIFICACIONES_BI | CALIFICACIONES | BEFORE INSERT FOR EACH ROW | 1. Busca en REPRODUCCIONES si existe registro del perfil+contenido con porcentaje_avance >= 50 2. Si no existe → rechaza | ORA-20002: "Debes reproducir al menos el 50% del contenido para calificar" |
| TRG_PAGOS_AIU | PAGOS | AFTER INSERT OR UPDATE FOR EACH ROW | 1. Si estado_pago = 'EXITOSO' → UPDATE USUARIOS SET estado_cuenta='ACTIVO', fecha_ultimo_pago=fecha_pago WHERE id_usuario=id_usuario_pago | — (no rechaza, solo actualiza) |

### 7.4 NT3 — Transacciones

| Transacción | Archivo SQL | Lógica PL/SQL | Endpoint Backend | Verificación |
|-------------|-------------|---------------|-----------------|-------------|
| TX1: Registro completo | `01_transaccion_registro.sql` | INSERT USUARIO + INSERT PERFIL (adulto) + INSERT PAGO primer mes. Todo o nada. Si falla cualquier paso → ROLLBACK completo | `POST /api/usuarios/registro-completo` | Crear usuario y verificar que aparece en USUARIOS, PERFILES y PAGOS. Forzar error (email duplicado) y verificar ROLLBACK total. |
| TX2: Renovación masiva | `02_transaccion_renovacion.sql` | Cursor recorre usuarios activos. Por cada uno: SAVEPOINT → INSERT PAGO + UPDATE SUSCRIPCION. Si falla uno → ROLLBACK TO SAVEPOINT, continuar con siguiente. Al final COMMIT. | `POST /api/pagos/renovacion-masiva` | Ejecutar con un usuario que tenga email duplicado forzado. Verificar que los demás usuarios se procesaron correctamente. |
| TX3: Eliminación de cuenta | `03_transaccion_eliminacion.sql` | DELETE CALIFICACIONES → FAVORITOS → REPRODUCCIONES → REPORTES → PERFILES → PAGOS → SUSCRIPCIONES → USUARIO. Orden inverso de dependencias. Todo o nada. | `DELETE /api/usuarios/{id}/cuenta-completa` | Eliminar usuario y verificar que no queda rastro en ninguna tabla. Forzar error a mitad y verificar ROLLBACK. |
| Concurrencia | `04_concurrencia_demo.sql` | Dos sesiones SQL*Plus que intentan cambiar plan del mismo usuario simultáneamente. SELECT FOR UPDATE en SUSCRIPCIONES. | — (demo manual) | Documentar paso a paso con timestamps. |

**Patrón de implementación en Spring Boot para TX2:**

```java
@Transactional
public void renovacionMasiva() {
    // Obtener usuarios activos
    List<Usuario> activos = usuarioRepository.findByEstadoCuenta("ACTIVO");

    for (Usuario usuario : activos) {
        try {
            // Crear pago y renovar suscripción para este usuario
            registrarPagoYRenovacion(usuario);
        } catch (Exception e) {
            // Log del error pero continuar con los demás
            log.error("Error renovando usuario {}: {}", usuario.getId(), e.getMessage());
            // La transacción completa fallará si no manejamos esto
            // Opción: usar propagación REQUIRES_NEW para cada usuario
        }
    }
}
```

> **Nota IA**: Para que SAVEPOINT funcione correctamente desde Spring Boot, considerar usar `TransactionTemplate` con `SavepointManager`, o mantener la lógica de SAVEPOINT dentro del SP de Oracle y llamarlo desde Spring Boot.

### 7.5 NT4 — Índices

| Índice | Tabla | Columnas | Tipo | Justificación |
|--------|-------|----------|------|---------------|
| IDX_REP_PERFIL_FECHA | REPRODUCCIONES | (id_perfil, fecha_hora_inicio) | B-Tree compuesto | Historial de reproducciones por perfil, ordenado por fecha. Consulta más frecuente del sistema. |
| IDX_USU_EMAIL | USUARIOS | (email) | UNIQUE | Login por email, validación de duplicados |
| IDX_CONT_CAT_ANIO | CONTENIDO | (id_categoria, anio_lanzamiento) | B-Tree compuesto | Búsqueda por categoría y año (catálogo filtrado) |
| IDX_PAG_USU_FECHA | PAGOS | (id_usuario, fecha_pago) | B-Tree compuesto | Historial de pagos, verificación de vencimiento |

**EXPLAIN PLAN**: Ejecutar antes y después de crear IDX_REP_PERFIL_FECHA. Consulta de prueba:

```sql
SELECT c.titulo, COUNT(*) as total
FROM REPRODUCCIONES r
JOIN CONTENIDO c ON r.id_contenido = c.id_contenido
JOIN PERFILES p ON r.id_perfil = p.id_perfil
JOIN USUARIOS u ON p.id_usuario = u.id_usuario
WHERE r.fecha_hora_inicio BETWEEN :fecha_ini AND :fecha_fin
  AND u.ciudad_residencia = :ciudad
GROUP BY c.titulo
ORDER BY total DESC;
```

### 7.6 NT5 — Usuarios y Roles

| Rol | Usuario Oracle | Privilegios clave | Restricciones |
|-----|---------------|------------------|---------------|
| ROL_ADMIN | admin_qflix | CRUD todas las tablas, EXECUTE todos los SP, CREATE/DROP USER, REFRESH MVs | Sin restricciones |
| ROL_ANALISTA | analista_qflix | SELECT todas las tablas, EXECUTE SP de reportes | No INSERT/UPDATE/DELETE en tablas transaccionales |
| ROL_SOPORTE | soporte_qflix | SELECT USUARIOS/PERFILES/SUSCRIPCIONES, INSERT/UPDATE PAGOS, EXECUTE SP_CAMBIAR_PLAN | No accede a CONTENIDO ni EMPLEADOS |
| ROL_CONTENIDO | contenido_qflix | CRUD CONTENIDO/TEMPORADAS/EPISODIOS/GENEROS, SELECT REPRODUCCIONES/CALIFICACIONES | No accede a USUARIOS, PAGOS, SUSCRIPCIONES |

**Profile de recursos**: `PROF_QFLIX_LIMITS` con sesiones concurrentes máximas, tiempo de inactividad, intentos de login fallidos.

---

## 8. Especificación Técnica del Backend

### 8.1 API REST Completa — Endpoints

#### Usuarios y Perfiles

| Método | Endpoint | Descripción | Implementación | Bean Validation |
|--------|----------|-------------|---------------|-----------------|
| GET | `/api/usuarios` | Listar usuarios | JPA Repository | — |
| GET | `/api/usuarios/{id}` | Detalle usuario | JPA Repository | @PathVariable @Min(1) |
| POST | `/api/usuarios/registrar` | Registrar usuario | SimpleJdbcCall → SP_REGISTRAR_USUARIO | @Valid @NotBlank nombre, @Email email |
| PUT | `/api/usuarios/{id}/plan` | Cambiar plan | SimpleJdbcCall → SP_CAMBIAR_PLAN | @NotNull idPlan |
| GET | `/api/usuarios/{id}/monto-proximo-mes` | Monto a cobrar | JdbcTemplate → FN_CALCULAR_MONTO | @PathVariable @Min(1) |
| GET | `/api/usuarios/{id}/reporte-consumo` | Reporte consumo | SimpleJdbcCall → SP_REPORTE_CONSUMO (cursor OUT) | @PathVariable @Min(1) |
| DELETE | `/api/usuarios/{id}/cuenta-completa` | Eliminar cuenta completa | @Transactional + JDBC | @PathVariable @Min(1) |
| GET | `/api/perfiles` | Listar perfiles | JPA Repository | — |
| GET | `/api/perfiles/{id}` | Detalle perfil | JPA Repository | @PathVariable @Min(1) |
| GET | `/api/perfiles/{id}/recomendacion` | Contenido recomendado | JdbcTemplate → FN_CONTENIDO_RECOMENDADO | @PathVariable @Min(1) |
| GET | `/api/perfiles/{id}/historial` | Historial reproducciones | JdbcTemplate query | @PathVariable @Min(1) |

#### Contenido

| Método | Endpoint | Descripción | Implementación |
|--------|----------|-------------|---------------|
| GET | `/api/contenido` | Listar catálogo | JPA Repository (paginado) |
| GET | `/api/contenido/{id}` | Detalle contenido | JPA Repository |
| POST | `/api/contenido` | Crear contenido | JPA Repository (solo admin/contenido) |
| GET | `/api/contenido/{id}/temporadas` | Temporadas de una serie | JPA Repository |
| GET | `/api/categorias` | Listar categorías | JPA Repository (solo lectura) |
| GET | `/api/generos` | Listar géneros | JPA Repository (solo lectura) |

#### Reproducciones y Calificaciones

| Método | Endpoint | Descripción | Implementación | Trigger activado |
|--------|----------|-------------|---------------|-----------------|
| POST | `/api/reproducciones` | Registrar reproducción | JdbcTemplate INSERT | TRG_REPRODUCCIONES_BI → verifica cuenta activa |
| POST | `/api/calificaciones` | Calificar contenido | JdbcTemplate INSERT | TRG_CALIFICACIONES_BI → verifica >=50% avance |
| POST | `/api/favoritos` | Agregar favorito | JdbcTemplate INSERT | — |
| DELETE | `/api/favoritos/{idPerfil}/{idContenido}` | Quitar favorito | JdbcTemplate DELETE | — |

#### Pagos y Suscripciones

| Método | Endpoint | Descripción | Implementación | Trigger activado |
|--------|----------|-------------|---------------|-----------------|
| POST | `/api/pagos` | Registrar pago | JdbcTemplate INSERT | TRG_PAGOS_AIU → actualiza estado_cuenta |
| POST | `/api/pagos/renovacion-masiva` | Renovación batch | @Transactional + JDBC (SAVEPOINT) | TRG_PAGOS_AIU por cada pago |
| GET | `/api/suscripciones/usuario/{id}` | Suscripción activa | JPA Repository | — |

#### Reportes (NT1)

| Método | Endpoint | Descripción | Implementación |
|--------|----------|-------------|---------------|
| GET | `/api/reportes/contenido-popular` | Top contenido | JdbcTemplate → MV_CONTENIDO_POPULAR |
| GET | `/api/reportes/ingresos-mensuales` | Ingresos por mes | JdbcTemplate → MV_INGRESOS_MENSUALES |
| GET | `/api/reportes/usuarios-por-ciudad-plan` | PIVOT usuarios×plan | JdbcTemplate → PIVOT-01 |
| GET | `/api/reportes/reproducciones-por-dispositivo` | PIVOT rep×dispositivo | JdbcTemplate → PIVOT-02 |
| GET | `/api/reportes/ingresos-rollup` | ROLLUP ingresos | JdbcTemplate → GB-01 |
| GET | `/api/reportes/reproducciones-cube` | CUBE reproducciones | JdbcTemplate → GB-02 |
| GET | `/api/reportes/reproducciones-grouping-sets` | GROUPING SETS | JdbcTemplate → GB-03 |
| GET | `/api/reportes/top-contenido-ciudad` | Parametrizada CP-01 | JdbcTemplate → consulta con bind variable |
| GET | `/api/reportes/ingresos-periodo` | Parametrizada CP-02 | JdbcTemplate → consulta con bind variables |
| GET | `/api/reportes/calificacion-promedio` | Parametrizada CP-03 | JdbcTemplate → consulta con bind variable |
| GET | `/api/reportes/morosos` | Cursor morosos | SimpleJdbcCall → cursor OUT |
| GET | `/api/reportes/popularidad` | Cursor popularidad | SimpleJdbcCall → cursor OUT |
| POST | `/api/reportes/refrescar-mvs` | Refrescar MVs | JdbcTemplate → DBMS_MVIEW.REFRESH |

#### Transacciones (NT3)

| Método | Endpoint | Descripción | Implementación |
|--------|----------|-------------|---------------|
| POST | `/api/usuarios/registro-completo` | TX1: Registro atómico | SimpleJdbcCall → SP con COMMIT/ROLLBACK |
| POST | `/api/pagos/renovacion-masiva` | TX2: Renovación con SAVEPOINT | @Transactional + iteración con SAVEPOINT |
| DELETE | `/api/usuarios/{id}/cuenta-completa` | TX3: Eliminación en cascada | @Transactional + JDBC DELETE en orden |

### 8.2 GlobalExceptionHandler — Mapeo ORA- → HTTP

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    // Excepciones de trigger Oracle (RAISE_APPLICATION_ERROR)
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleOracleTrigger(
            DataIntegrityViolationException ex) {

        String msg = ex.getMostSpecificCause().getMessage();

        if (msg.contains("ORA-20001")) {
            // TRG_REPRODUCCIONES_BI: cuenta inactiva
            return ResponseEntity.unprocessableEntity()
                .body(new ErrorResponse("CUENTA_INACTIVA",
                    "Tu cuenta está inactiva. Realiza tu pago para continuar."));
        }
        if (msg.contains("ORA-20002")) {
            // TRG_CALIFICACIONES_BI: avance insuficiente
            return ResponseEntity.unprocessableEntity()
                .body(new ErrorResponse("AVANCE_INSUFICIENTE",
                    "Debes reproducir al menos el 50% del contenido para calificar."));
        }
        if (msg.contains("ORA-20003")) {
            // TRG_PERFILES_BI o SP_CAMBIAR_PLAN: exceso de perfiles
            return ResponseEntity.unprocessableEntity()
                .body(new ErrorResponse("PERFILES_EXCEDIDOS",
                    "No puedes realizar esta acción: excede el límite de perfiles de tu plan."));
        }
        if (msg.contains("ORA-20004")) {
            // TRG_REPRODUCCIONES_BI: contenido no permitido para infantil
            return ResponseEntity.unprocessableEntity()
                .body(new ErrorResponse("CONTENIDO_NO_PERMITIDO",
                    "Este contenido no está disponible para perfiles infantiles."));
        }
        if (msg.contains("ORA-00001")) {
            // Unique constraint violation (email duplicado)
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ErrorResponse("DUPLICADO",
                    "Ya existe un registro con estos datos únicos."));
        }

        // Error genérico de BD
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("ERROR_BD", "Error en la base de datos."));
    }

    @ExceptionHandler(EmptyResultDataAccessException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            EmptyResultDataAccessException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NO_ENCONTRADO", "El recurso solicitado no existe."));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(
            MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDACION", "Datos inválidos", errors));
    }
}
```

**Códigos HTTP estándar:**

| Situación | HTTP | Body |
|-----------|------|------|
| OK con datos | 200 | JSON con datos |
| Recurso creado | 201 | JSON del recurso creado |
| Lista vacía | 200 | `[]` |
| Validación fallida (Bean Validation) | 400 | ErrorResponse con lista de campos |
| No encontrado | 404 | ErrorResponse "NO_ENCONTRADO" |
| Duplicado (unique constraint) | 409 | ErrorResponse "DUPLICADO" |
| Trigger rechaza operación | 422 | ErrorResponse con código de negocio |
| Error inesperado de BD | 500 | ErrorResponse "ERROR_BD" |

### 8.3 DTOs — Estructura

```java
// Request DTOs
public record RegistroUsuarioRequest(
    @NotBlank String nombre,
    @Email @NotBlank String email,
    @NotBlank String telefono,
    @NotNull LocalDate fechaNacimiento,
    @NotBlank String ciudadResidencia,
    @NotNull Long idPlan
) {}

public record CambioPlanRequest(
    @NotNull Long idNuevoPlan
) {}

public record ReproduccionRequest(
    @NotNull Long idPerfil,
    @NotNull Long idContenido,
    Long idEpisodio,
    @NotNull LocalDateTime fechaHoraInicio,
    LocalDateTime fechaHoraFin,
    @NotBlank String dispositivo,
    @NotNull @DecimalMin("0") @DecimalMax("100") BigDecimal porcentajeAvance
) {}

public record CalificacionRequest(
    @NotNull Long idPerfil,
    @NotNull Long idContenido,
    @Min(1) @Max(5) Integer estrellas,
    String resena
) {}

// Response DTOs
public record ErrorResponse(
    String codigo,
    String mensaje,
    List<String> detalles
) {
    public ErrorResponse(String codigo, String mensaje) {
        this(codigo, mensaje, null);
    }
}

public record ContenidoPopularResponse(
    Long idContenido,
    String titulo,
    String categoria,
    Long totalReproducciones,
    BigDecimal calificacionPromedio
) {}
```

### 8.4 Secuencias Oracle en JPA

Como Oracle usa secuencias explícitas (no IDENTITY en todas las tablas), cada entidad con secuencia debe declarar:

```java
@Entity
@Table(name = "USUARIOS")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "SEQ_USUARIOS")
    @SequenceGenerator(name = "SEQ_USUARIOS", sequenceName = "SEQ_USUARIOS",
                       allocationSize = 1)
    @Column(name = "ID_USUARIO")
    private Long id;
    // ...
}
```

> **Nota IA**: Para REPRODUCCIONES con clave compuesta, la secuencia `SEQ_REPRODUCCIONES` solo genera `id_reproduccion`. La `fecha_hora_inicio` viene del request. Usar JdbcTemplate para el INSERT:

```java
public void crearReproduccion(ReproduccionRequest req) {
    String sql = """
        INSERT INTO REPRODUCCIONES (id_reproduccion, id_perfil, id_contenido,
            id_episodio, fecha_hora_inicio, fecha_hora_fin, dispositivo, porcentaje_avance)
        VALUES (SEQ_REPRODUCCIONES.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)
        """;
    jdbcTemplate.update(sql,
        req.idPerfil(), req.idContenido(), req.idEpisodio(),
        req.fechaHoraInicio(), req.fechaHoraFin(),
        req.dispositivo(), req.porcentajeAvance());
}
```

---

## 9. Especificación Técnica del Frontend

### 9.1 Configuración Axios — Manejo Centralizado de Errores Oracle

```typescript
// api/axios.ts
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: { 'Content-Type': 'application/json' },
});

// Interceptor: transformar errores Oracle en mensajes legibles
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const errorData = error.response?.data;

    if (errorData?.codigo) {
      // Error de negocio Oracle (ORA-20001, ORA-20002, etc.)
      // Ya viene traducido por GlobalExceptionHandler
      return Promise.reject({
        type: 'business',
        code: errorData.codigo,
        message: errorData.mensaje,
      });
    }

    if (error.response?.status === 400) {
      // Error de validación Bean Validation
      return Promise.reject({
        type: 'validation',
        message: errorData.mensaje,
        details: errorData.detalles,
      });
    }

    // Error genérico
    return Promise.reject({
      type: 'unknown',
      message: 'Error inesperado. Intenta de nuevo.',
    });
  }
);

export default api;
```

### 9.2 Tipos TypeScript — Mapeo de DTOs

```typescript
// types/api.types.ts
export interface ErrorResponse {
  codigo: string;
  mensaje: string;
  detalles?: string[];
}

export interface PaginatedResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
}

// types/usuario.types.ts
export interface Usuario {
  id: number;
  nombre: string;
  email: string;
  telefono: string;
  fechaNacimiento: string;
  ciudadResidencia: string;
  estadoCuenta: 'ACTIVO' | 'INACTIVO' | 'SUSPENDIDO';
  fechaRegistro: string;
  fechaUltimoPago: string | null;
}

export interface RegistroUsuarioForm {
  nombre: string;
  email: string;
  telefono: string;
  fechaNacimiento: string;
  ciudadResidencia: string;
  idPlan: number;
}

// types/contenido.types.ts
export interface Contenido {
  id: number;
  titulo: string;
  anioLanzamiento: number;
  duracion: number;
  sinopsis: string;
  clasificacionEdad: 'TP' | '+7' | '+13' | '+16' | '+18';
  fechaAgregado: string;
  esProduccionOriginal: boolean;
  categoria: { id: number; nombre: string };
  generos: { id: number; nombre: string }[];
}

// types/suscripcion.types.ts
export interface Suscripcion {
  id: number;
  idUsuario: number;
  plan: Plan;
  fechaInicio: string;
  fechaVencimiento: string;
  estado: 'ACTIVA' | 'VENCIDA' | 'CANCELADA';
}

export interface Plan {
  id: number;
  nombre: string;
  pantallasSimultaneas: number;
  calidad: string;
  precioMensual: number;
}
```

### 9.3 Páginas y Componentes — Funcionalidad por Página

| Página | Componente Principal | API Calls | Funcionalidad |
|--------|---------------------|-----------|---------------|
| Home | Home.tsx | GET /api/contenido (top 10) | Landing page con contenido destacado |
| Registro | RegistroForm.tsx | POST /api/usuarios/registrar | Formulario con validación. Muestra errores Oracle (email duplicado → 409) |
| Login | Login.tsx | GET /api/usuarios?email= | Autenticación simulada (sin JWT para simplificar) |
| Catalogo | Catalogo.tsx + ContenidoList.tsx + ContenidoCard.tsx | GET /api/contenido (paginado), GET /api/categorias, GET /api/generos | Grid de contenido con filtros por categoría/género |
| ContenidoDetalle | ContenidoDetail.tsx + PlayerSimulator.tsx + StarRating.tsx + ResenaForm.tsx | GET /api/contenido/{id}, POST /api/reproducciones, POST /api/calificaciones | Detalle + reproductor simulado + calificación. Muestra errores de trigger (cuenta inactiva, avance < 50%) |
| Perfil | PerfilSelector.tsx | GET /api/perfiles?usuarioId=, GET /api/perfiles/{id}/recomendacion | Selector de perfiles + recomendación IA (FN_CONTENIDO_RECOMENDADO) |
| Favoritos | ContenidoList.tsx | GET /api/perfiles/{id}/favoritos, POST /api/favoritos, DELETE /api/favoritos/{idPerfil}/{idContenido} | Lista de favoritos con agregar/quitar |
| Suscripcion | CambioPlanForm.tsx | GET /api/suscripciones/usuario/{id}, PUT /api/usuarios/{id}/plan, GET /api/usuarios/{id}/monto-proximo-mes | Cambio de plan con validación. Muestra error si excede perfiles |
| Pagos | Pagos.tsx | GET /api/pagos?usuarioId=, POST /api/pagos | Historial y registro de pagos. Actualización automática de estado |
| Reportes | ReporteConsumo.tsx + ReporteFinanciero.tsx + ReportePopularidad.tsx | GET /api/reportes/* (todos los endpoints de reportes) | Tablas y gráficas con datos de MVs, PIVOT, ROLLUP, CUBE |
| AdminDashboard | DashboardAdmin.tsx + ModeracionPanel.tsx + EmpleadoList.tsx | GET /api/reportes/popularidad, GET /api/empleados, GET /api/reportes/contenido-popular | Panel administrativo |

### 9.4 Manejo de Errores Oracle en el Frontend — Patrones

```typescript
// En cualquier componente que llame a la API:
const handleCalificar = async (estrellas: number, resena: string) => {
  try {
    await calificacionApi.crear({ idPerfil, idContenido, estrellas, resena });
    showToast('Calificación registrada exitosamente', 'success');
  } catch (error: any) {
    if (error.code === 'AVANCE_INSUFICIENTE') {
      // Trigger TRG_CALIFICACIONES_BI rechazó
      showToast(error.message, 'warning'); // "Debes reproducir al menos el 50%..."
    } else if (error.code === 'CUENTA_INACTIVA') {
      // Trigger TRG_REPRODUCCIONES_BI rechazó
      showToast(error.message, 'error');
      navigate('/pagos'); // Redirigir a pagos
    } else {
      showToast('Error inesperado', 'error');
    }
  }
};
```

---

## 10. Estrategia de Datos de Prueba

### 10.1 Cantidad y Distribución Asimétrica

Los datos deben ser **deliberadamente asimétricos** para que los reportes con ROLLUP, CUBE y PIVOT muestren diferencias reales.

| Tabla | Mín. Registros | Distribución |
|-------|---------------|-------------|
| PLANES | 3 | Básico, Estándar, Premium |
| CATEGORIAS | 5 | Películas, Series, Documentales, Música, Podcasts |
| GENEROS | 8+ | Acción, Comedia, Drama, Suspenso, Romance, Ciencia Ficción, Terror, Infantil |
| USUARIOS | 30 | 12 Bogotá, 10 Medellín, 8 Cali. Planes: 12 Básico, 10 Estándar, 8 Premium. Estados: 25 ACTIVO, 3 INACTIVO, 2 SUSPENDIDO |
| SUSCRIPCIONES | 30 | 25 ACTIVA, 3 VENCIDA, 2 CANCELADA |
| PERFILES | 50 | Premium: 4-5 perfiles, Estándar: 2-3, Básico: 1-2. ~8 perfiles infantiles |
| CONTENIDO | 40 | 15 películas, 12 series, 6 documentales, 4 música, 3 podcasts |
| TEMPORADAS | 15 | Para 12 series + 3 podcasts |
| EPISODIOS | 50 | 2-6 episodios por temporada |
| REPRODUCCIONES | 200 | Dispositivos: 40% celular, 25% TV, 20% computador, 15% tablet. Fechas esparcidas Ene 2024 - Jun 2025. Avance: mezcla de 10%, 45%, 78%, 95%, 100% |
| CALIFICACIONES | 60 | Más de 3-5 estrellas. Algunas con reseña |
| PAGOS | 80 | ~70% exitosos, 15% fallidos, 10% pendientes, 5% reembolsados. Métodos: 40% TC, 25% Nequi, 15% PSE, 12% Daviplata, 8% TD |
| FAVORITOS | 40 | 2-8 por perfil |
| DEPARTAMENTOS | 5 | Tecnología, Contenido, Marketing, Soporte, Finanzas |
| EMPLEADOS | 10 | ~2 por depto, con jerarquía de supervisión |
| REPORTES_CONTENIDO | 5 | Mix de pendientes y resueltos |
| REFERIDOS | 8 | 4 con beneficio_otorgado='SI', 4 con 'NO' |

### 10.2 Principios de Asimetría

- **No** distribuir uniformemente por ciudad: Bogotá > Medellín > Cali
- **No** distribuir uniformemente por plan: más Básico que Premium
- **No** todos los pagos exitosos: incluir fallidos, pendientes, reembolsados
- **No** todas las reproducciones completas: mezclar avances de 10%, 45%, 78%, 95%, 100%
- **No** todas las calificaciones altas: incluir calificaciones bajas (1-2 estrellas)
- **Sí** concentrar reproducciones en ciertos contenidos para que "más popular" tenga ganadores claros
- **Sí** incluir al menos 2 usuarios INACTIVO con reproducciones recientes (para probar trigger de cuenta inactiva)
- **Sí** incluir calificaciones de usuarios que no reproducieron el 50% (para probar trigger de calificación)

---

## 11. Cronograma y Plan de Entregas

### 11.1 Mapa de Entregas

```
SEMANA  6     7     8     9     10    11    12    13    14    15    16
        ├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
        │ ASIGNACIÓN          │ ENTREGA1             │ ENTREGA2         │ ENTREGA3
        │ Leer enunciado      │ 30%                  │ 35%              │ 35% + Sustentación
        │ Modelo negocio      │ MER+DDL+DML+NT1      │ NT2+Correcciones │ NT3+NT4+NT5+Doc
```

### 11.2 Cronograma de Desarrollo para IA

La IA debe seguir este orden de generación de artefactos, respetando las dependencias:

#### Fase 0: Preparación (Antes de cualquier código)
1. Crear repositorio Git con estructura de directorios completa
2. Crear `.editorconfig`, `.gitignore`
3. Crear scripts utilitarios (`setup-oracle.sh`, `run-all-scripts.sh`)

#### Fase 1: Base de Datos — DDL (Dependencia: ninguna)
1. `database/01_schema/001_create_tablespaces.sql`
2. `database/01_schema/002_create_user_schema.sql`
3. `database/01_schema/003_grant_base_privileges.sql`
4. `database/02_ddl/001_planes.sql` → `020_seq_and_defaults.sql` (en orden de dependencias FK)

#### Fase 2: Base de Datos — DML (Dependencia: Fase 1)
1. `database/03_dml/001_planes.sql` → `013_pagos.sql` (en orden de dependencias FK)

#### Fase 3: NT1 — Consultas Avanzadas (Dependencia: Fase 2)
1. `database/04_nt1_consultas/05_fragmentacion.sql` (modifica DDL de REPRODUCCIONES si no se hizo antes)
2. `database/04_nt1_consultas/01_parametrizadas.sql`
3. `database/04_nt1_consultas/02_pivot_unpivot.sql`
4. `database/04_nt1_consultas/03_group_by_avanzado.sql`
5. `database/04_nt1_consultas/04_vistas_materializadas.sql`

#### Fase 4: Backend — Infraestructura (Dependencia: Fase 1)
1. `backend/build.gradle.kts`, `settings.gradle.kts`
2. `application.yml`
3. `QuindioFlixApplication.java`
4. `OracleConfig.java`, `OpenApiConfig.java`, `CorsConfig.java`
5. Todas las entidades JPA (`entity/`)
6. Todas las interfaces Repository (`repository/`)

#### Fase 5: Backend — CRUD y SP (Dependencia: Fase 4)
1. DTOs (`dto/request/`, `dto/response/`)
2. `GlobalExceptionHandler.java` + clases de excepción
3. Services con JPA para CRUD simple
4. Services con SimpleJdbcCall para SP (requiere que Fase 6 esté lista para probar)

#### Fase 6: NT2 — PL/SQL (Dependencia: Fase 2)
1. `database/05_nt2_plsql/04_excepciones.sql` (define excepciones primero)
2. `database/05_nt2_plsql/01_cursors.sql`
3. `database/05_nt2_plsql/02_procedimientos.sql`
4. `database/05_nt2_plsql/03_funciones.sql`
5. `database/05_nt2_plsql/05_triggers.sql`

#### Fase 7: Backend — Integración PL/SQL (Dependencia: Fase 5 + Fase 6)
1. Services con SimpleJdbcCall para SP y funciones
2. Services con JdbcTemplate para reproducciones y calificaciones (activan triggers)
3. Services con JdbcTemplate para reportes (MVs, PIVOT, ROLLUP)
4. Controllers REST completos

#### Fase 8: NT3 — Transacciones (Dependencia: Fase 6)
1. `database/06_nt3_transacciones/01_transaccion_registro.sql`
2. `database/06_nt3_transacciones/02_transaccion_renovacion.sql`
3. `database/06_nt3_transacciones/03_transaccion_eliminacion.sql`
4. `database/06_nt3_transacciones/04_concurrencia_demo.sql`
5. Services correspondientes en Spring Boot

#### Fase 9: NT4 — Índices (Dependencia: Fase 2)
1. `database/07_nt4_indices/02_explain_plan_before.sql`
2. `database/07_nt4_indices/01_creacion_indices.sql`
3. `database/07_nt4_indices/03_explain_plan_after.sql`

#### Fase 10: NT5 — Roles (Dependencia: Fase 1)
1. `database/08_nt5_roles/01_creacion_roles.sql`
2. `database/08_nt5_roles/02_creacion_usuarios.sql`
3. `database/08_nt5_roles/03_grant_privilegios.sql`
4. `database/08_nt5_roles/04_profiles.sql`
5. `database/08_nt5_roles/05_demo_restricciones.sql`

#### Fase 11: Frontend (Dependencia: Fase 7)
1. Configuración Vite + TypeScript + Tailwind
2. Tipos TypeScript (`types/`)
3. Instancia Axios con interceptors (`api/axios.ts`)
4. API modules (`api/*.api.ts`)
5. Componentes comunes (Navbar, Card, Button, Table, Modal, Toast, ErrorMessage)
6. Layouts (MainLayout, AuthLayout)
7. Páginas en orden: Registro → Login → Home → Catalogo → ContenidoDetalle → Perfil → Favoritos → Suscripcion → Pagos → Reportes → AdminDashboard

#### Fase 12: Documentación (Dependencia: todas las anteriores)
1. Modelo de negocio (actores, procesos, reglas)
2. MER y modelo relacional
3. Documento de sustentación

### 11.3 Entregas Académicas

#### Entrega 1 — Semana 9 (30%)

| Componente | Contenido | Archivos |
|------------|-----------|---------|
| A. Modelo de negocio | Actores, procesos, 20 reglas, restricciones de dominio | `docs/entregas/entrega1/DocumentoModeloNegocio.pdf` |
| B. MER | Entidades, atributos, cardinalidades, relaciones, 3FN | `docs/entregas/entrega1/MER_QuindioFlix.png` |
| C. Scripts SQL | DDL + DML completos | `database/01_schema/`, `02_ddl/`, `03_dml/` |
| D. NT1 | Consultas parametrizadas, PIVOT/UNPIVOT, ROLLUP/CUBE, MVs, fragmentación | `database/04_nt1_consultas/` |

#### Entrega 2 — Semana 12 (35%)

| Componente | Contenido | Archivos |
|------------|-----------|---------|
| Cursores | 2 cursores explícitos | `database/05_nt2_plsql/01_cursors.sql` |
| Procedimientos | SP_REGISTRAR_USUARIO, SP_CAMBIAR_PLAN, SP_REPORTE_CONSUMO | `02_procedimientos.sql` |
| Funciones | FN_CALCULAR_MONTO, FN_CONTENIDO_RECOMENDADO | `03_funciones.sql` |
| Excepciones | E_EMAIL_DUPLICADO, E_PERFILES_EXCEDIDOS | `04_excepciones.sql` |
| Triggers | 4 triggers (ver tabla 7.3) | `05_triggers.sql` |
| Correcciones E1 | Ajustes según retroalimentación | `database/02_ddl/` actualizado |

#### Entrega 3 — Semana 16 (35%)

| Componente | Contenido | Archivos |
|------------|-----------|---------|
| NT3 | 3 transacciones + concurrencia | `database/06_nt3_transacciones/` |
| NT4 | 4 índices + EXPLAIN PLAN | `database/07_nt4_indices/` |
| NT5 | 4 roles + usuarios + GRANT + PROFILE | `database/08_nt5_roles/` |
| Doc. sustentación | Máximo 10 páginas | `docs/entregas/entrega3/DocumentoSustentacion.pdf` |
| Sustentación oral | Todos explican cualquier parte | — |

---

## 12. Convenciones y Nomenclatura

### 12.1 Convenciones SQL

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Tabla | SNAKE_UPPERCASE | REPRODUCCIONES, CONTENIDO_GENERO |
| Columna | snake_case | id_usuario, fecha_hora_inicio |
| Primary Key | `id_` + nombre tabla (singular) | id_usuario, id_contenido |
| Foreign Key | `id_` + tabla referenciada (singular) | id_plan, id_perfil |
| Secuencia | `SEQ_` + tabla | SEQ_USUARIOS, SEQ_CONTENIDO |
| Procedimiento | `SP_` + verbo_accion | SP_REGISTRAR_USUARIO |
| Función | `FN_` + descripción | FN_CALCULAR_MONTO |
| Trigger | `TRG_` + tabla + evento | TRG_REPRODUCCIONES_BI (Before Insert) |
| Vista materializada | `MV_` + descripción | MV_CONTENIDO_POPULAR |
| Tablespace | `TS_` + descripción | TS_REP_2024 |
| Rol | `ROL_` + descripción | ROL_ADMIN |
| Profile Oracle | `PROF_` + descripción | PROF_QFLIX_LIMITS |
| Excepción personalizada | `E_` + descripción | E_EMAIL_DUPLICADO |
| Constante PL/SQL | `C_` + descripción | C_MAX_PERFILES_BASICO |

### 12.2 Convenciones Java / Spring Boot

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Paquete | lowercase | `co.edu.uniquindio.quindioflix.controller` |
| Clase | PascalCase | `UsuarioService`, `ContenidoController` |
| Método | camelCase | `registrarUsuario()`, `cambiarPlan()` |
| Constante | SNAKE_UPPERCASE | `MAX_PERFILES_PREMIUM` |
| Variable | camelCase | `idUsuario`, `fechaPago` |
| Endpoint REST | kebab-case, plural | `/api/usuarios`, `/api/contenidos` |
| DTO request | `*Request` | `RegistroUsuarioRequest` |
| DTO response | `*Response` | `UsuarioResponse` |
| Entidad JPA | Mismo nombre que tabla en PascalCase | `Usuario` → USUARIOS |

### 12.3 Convenciones React / TypeScript

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Componente | PascalCase | `ContenidoCard`, `PerfilSelector` |
| Hook custom | camelCase con prefijo `use` | `useAuth`, `useContenido` |
| Tipo/Interface | PascalCase | `Usuario`, `Contenido` |
| Archivo tipo | `*.types.ts` | `usuario.types.ts` |
| Archivo API | `*.api.ts` | `usuario.api.ts` |
| Constante | SNAKE_UPPERCASE | `API_BASE_URL` |
| Función utilitaria | camelCase | `formatCurrency`, `validateEmail` |
| Store Zustand | `*Store.ts` | `authStore.ts` |

### 12.4 Convenciones Git

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Rama principal | `main` | — |
| Rama por entrega | `entrega/N` | `entrega/1`, `entrega/2` |
| Rama de feature | `feature/descripcion` | `feature/sp-registrar-usuario` |
| Rama de fix | `fix/descripcion` | `fix/restriccion-perfiles-trigger` |
| Commit | `tipo: descripción` | `feat: agregar SP_REGISTRAR_USUARIO` |
| Tipos de commit | `feat`, `fix`, `docs`, `refactor`, `test`, `chore` | — |

---

## 13. Checklist de Calidad por Entrega

### 13.1 Checklist — Entrega 1

#### Componente A: Modelo de Negocio
- [ ] Actores identificados con roles claros
- [ ] Procesos de negocio descritos con detalle
- [ ] 20 reglas de negocio (explícitas + implícitas) con trazabilidad
- [ ] Restricciones de dominio completas (17+ restricciones)

#### Componente B: MER
- [ ] 19 entidades con atributos, tipos y restricciones
- [ ] Cardinalidad y participación correctas en 16 relaciones
- [ ] 3 relaciones reflexivas (contenido_relacionado, referidos, supervisión)
- [ ] Tablas intermedias para N:M
- [ ] Normalización 3FN verificada
- [ ] Diagrama profesional y legible

#### Componente C: Scripts SQL
- [ ] CREATE TABLE con PK, FK, CHECK, UNIQUE, NOT NULL, COMMENT ON
- [ ] REPRODUCCIONES con particionamiento por rango en tablespaces separados
- [ ] Datos de prueba con cantidades mínimas (30 usuarios, 40 contenido, 200 reproducciones)
- [ ] Datos asimétricos (no uniformes)
- [ ] Datos coherentes (no rompen restricciones)
- [ ] Scripts se ejecutan sin errores en Oracle XE

#### Componente D: NT1
- [ ] 3+ consultas parametrizadas con bind variables
- [ ] 2+ PIVOT con resultados legibles
- [ ] 2+ UNPIVOT demostrados
- [ ] ROLLUP con subtotales y gran total
- [ ] CUBE con todas las combinaciones
- [ ] GROUPING() para identificar subtotales
- [ ] GROUPING SETS sin cruce
- [ ] 2+ vistas materializadas con REFRESH COMPLETE ON DEMAND
- [ ] Fragmentación por rango en tablespaces + justificación

### 13.2 Checklist — Entrega 2

- [ ] 2 cursores explícitos (morosos, popularidad) con DBMS_OUTPUT
- [ ] SP_REGISTRAR_USUARIO: valida email, crea usuario + perfil + pago
- [ ] SP_CAMBIAR_PLAN: valida límite de perfiles, rechaza si excede
- [ ] SP_REPORTE_CONSUMO: reporte por perfil y categoría con cursor OUT
- [ ] FN_CALCULAR_MONTO: monto con descuentos por antigüedad y referido
- [ ] FN_CONTENIDO_RECOMENDADO: basado en géneros más reproducidos
- [ ] E_EMAIL_DUPLICADO (-20001): excepción personalizada
- [ ] E_PERFILES_EXCEDIDOS (-20003): excepción personalizada
- [ ] TRG_REPRODUCCIONES_BI: verifica cuenta activa + contenido infantil
- [ ] TRG_PERFILES_BI: verifica límite de perfiles por plan
- [ ] TRG_CALIFICACIONES_BI: verifica reproducción >= 50%
- [ ] TRG_PAGOS_AIU: actualiza estado_cuenta y fecha_ultimo_pago
- [ ] Correcciones de Entrega 1 aplicadas
- [ ] Todos los scripts se ejecutan sin errores

### 13.3 Checklist — Entrega 3

- [ ] TX1: registro atómico (usuario + perfil + pago) con COMMIT/ROLLBACK
- [ ] TX2: renovación batch con SAVEPOINT
- [ ] TX3: eliminación en cascada (hijas → padre) con COMMIT/ROLLBACK
- [ ] Escenario de concurrencia documentado y reproducible
- [ ] 4 índices creados con justificación
- [ ] EXPLAIN PLAN antes y después con capturas
- [ ] Análisis de mejora en COST documentado
- [ ] 4 roles con privilegios diferenciados
- [ ] 1+ usuario Oracle por rol
- [ ] PROFILE con límites de recursos
- [ ] Demostración de restricciones (permitida vs denegada)
- [ ] Documento de sustentación máximo 10 páginas
- [ ] Backend: todos los endpoints funcionales vía Swagger/Postman
- [ ] Frontend: navegación completa, errores Oracle manejados
- [ ] Todos los integrantes explican cualquier parte

---

## 14. Riesgos y Mitigación

| # | Riesgo | Impacto | Probabilidad | Mitigación |
|---|--------|---------|-------------|------------|
| 1 | Modelo de datos mal diseñado que requiere cambios drásticos | Alto | Media | Invertir tiempo significativo en Entrega 1. Validar MER con casos de uso concretos antes de crear tablas. Consultar al docente en semana 7. |
| 2 | Incompatibilidad entre datos de prueba y restricciones | Medio | Alta | Probar DML inmediatamente después del DDL. Usar `run-all-scripts.sh` para verificar orden. Datos asimétricos pero coherentes. |
| 3 | Triggers que generan errores en cascada | Alto | Media | Implementar triggers de forma incremental, uno a la vez. Probar cada trigger individualmente. Usar `DBMS_OUTPUT` para depuración. |
| 4 | Entidades JPA no coinciden con tablas Oracle (ddl-auto: validate falla) | Alto | Media | Generar entidades JPA DESPUÉS de crear las tablas. Usar `validate` para detectar desajustes inmediatamente. Verificar nombres de columna con `@Column(name="...")`. |
| 5 | Escenario de concurrencia no reproducible | Alto | Baja | Documentar paso a paso con timestamps. Script SQL con instrucciones exactas para dos sesiones SQL*Plus. |
| 6 | Oracle XE no disponible o problemas de conexión | Alto | Baja | Instalación local como backup. Documentar configuración de conexión. Driver ojdbc11 requiere cuenta Oracle o repositorio Maven de Oracle. |
| 7 | Scripts no idempotentes | Medio | Alta | `CREATE OR REPLACE`, `DROP TABLE ... PURGE` con manejo de excepciones. Probar `99_drop_all.sql` + `run-all-scripts.sh` regularmente. |
| 8 | Frontend consume demasiado tiempo de desarrollo | Alto | Media (si humanos) / Bajo (si IA) | La IA genera el frontend rápidamente. Priorizar que los errores Oracle se muestren correctamente. El frontend es complementario, no principal. |
| 9 | Zona horaria: Oracle devuelve fechas sin zona horaria | Medio | Alta | Configurar `hibernate.jdbc.time_zone=UTC` en application.yml. Usar `LocalDateTime` (sin zona) en Java, no `ZonedDateTime`. |

---

## 15. Anexos Técnicos

### Anexo A: Script de Ejecución Automatizada

```bash
#!/bin/bash
# run-all-scripts.sh
USER=${1:-QFLIX_ADMIN}
PASS=${2:-qflix_pass}
CONN=${3:-localhost:1521/XEPDB1}

SQLPLUS="sqlplus $USER/$PASS@$CONN"

echo "=== QuindioFlix — Ejecución de Scripts ==="

run_script() {
    echo ">>> Ejecutando: $1"
    echo "@$1" | $SQLPLUS
    if [ $? -ne 0 ]; then
        echo "!!! ERROR en: $1"
        exit 1
    fi
}

# Ejecutar en orden
for f in database/01_schema/*.sql; do run_script "$f"; done
for f in database/02_ddl/*.sql; do run_script "$f"; done
for f in database/03_dml/*.sql; do run_script "$f"; done
for f in database/04_nt1_consultas/*.sql; do run_script "$f"; done
for f in database/05_nt2_plsql/*.sql; do run_script "$f"; done
for f in database/06_nt3_transacciones/*.sql; do run_script "$f"; done
for f in database/07_nt4_indices/*.sql; do run_script "$f"; done
for f in database/08_nt5_roles/*.sql; do run_script "$f"; done

echo "=== Ejecución completada exitosamente ==="
```

### Anexo B: Colección Postman

Organizar la colección en carpetas que coincidan con los núcleos:

```
QuindioFlix API/
├── Setup
│   └── GET  /api/planes          (smoke test de conexión)
├── Usuarios y Perfiles
│   ├── POST /api/usuarios/registrar
│   ├── PUT  /api/usuarios/{id}/plan
│   └── GET  /api/usuarios/{id}/monto-proximo-mes
├── Contenido
│   ├── GET  /api/contenido
│   └── GET  /api/perfiles/{id}/recomendacion
├── Reproducciones
│   ├── POST /api/reproducciones  (fecha 2024 → partición P_REP_2024)
│   ├── POST /api/reproducciones  (fecha 2025 → partición P_REP_2025)
│   └── POST /api/calificaciones
├── Reportes NT1
│   ├── GET  /api/reportes/contenido-popular
│   ├── GET  /api/reportes/ingresos-mensuales?anio=2025&mes=3
│   ├── GET  /api/reportes/usuarios-por-ciudad-plan
│   ├── GET  /api/reportes/reproducciones-por-dispositivo
│   ├── GET  /api/reportes/ingresos-rollup
│   └── GET  /api/reportes/top-contenido-ciudad?ciudad=Bogota
├── Transacciones NT3
│   ├── POST /api/usuarios/registro-completo
│   └── DELETE /api/usuarios/{id}/cuenta-completa
└── Casos de error (triggers)
    ├── POST /api/reproducciones  (cuenta inactiva → 422)
    └── POST /api/calificaciones  (avance < 50% → 422)
```

### Anexo C: Comandos SQL de Depuración

```sql
-- Ver tablas del esquema
SELECT table_name FROM user_tables ORDER BY table_name;

-- Ver restricciones de una tabla
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints WHERE table_name = 'REPRODUCCIONES';

-- Ver columnas y comentarios
SELECT column_name, data_type, data_length, nullable
FROM user_tab_columns WHERE table_name = 'USUARIOS'
ORDER BY column_id;

-- Ver triggers
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers ORDER BY trigger_name;

-- Ver índices
SELECT index_name, table_name, column_name
FROM user_ind_columns ORDER BY table_name, index_name;

-- Ver privilegios de un rol
SELECT privilege, table_name FROM role_tab_privs
WHERE role = 'ROL_ADMIN' ORDER BY table_name;

-- EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT u.ciudad_residencia, p.nombre, COUNT(*)
FROM USUARIOS u JOIN SUSCRIPCIONES s ON u.id_usuario = s.id_usuario
JOIN PLANES p ON s.id_plan = p.id_plan
GROUP BY u.ciudad_residencia, p.nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ver particiones de REPRODUCCIONES
SELECT partition_name, tablespace_name, num_rows
FROM user_tab_partitions WHERE table_name = 'REPRODUCCIONES';
```

### Anexo D: Asignación de Responsabilidades (Grupo de 3)

| Integrante | Rol | Responsabilidad Principal | Entregables |
|------------|-----|--------------------------|-------------|
| **A** | DBA / Arquitecto | Modelo negocio, MER, DDL, fragmentación, índices, roles, backend config | Componentes A+B E1, NT4, NT5, config backend |
| **B** | Desarrollador PL/SQL | Cursores, SPs, funciones, excepciones, triggers, transacciones | NT1 (consultas), NT2, NT3 |
| **C** | Full-Stack | DML (datos prueba), MVs, services Spring Boot, frontend, doc. sustentación | Componente C E1, services backend, frontend completo |

> **Nota**: Todos los integrantes deben entender y poder explicar TODO el proyecto. La asignación es para eficiencia, no para compartimentación.

### Anexo E: Notas Importantes para la IA

1. **Nunca usar `ddl-auto: create` ni `update`**: Las tablas ya existen con restricciones, secuencias y particiones. Spring solo las lee y valida.

2. **El driver ojdbc11 no está en Maven Central por licencia Oracle**. Opciones:
   - Descargar manualmente desde oracle.com y publicar en repositorio local: `./gradlew publishToMavenLocal`
   - Agregar repositorio Maven de Oracle: `maven { url = uri("https://maven.oracle.com") }`

3. **Secuencias en JPA**: Oracle usa secuencias explícitas. Declarar `@GeneratedValue(strategy = GenerationType.SEQUENCE)` con `@SequenceGenerator` en cada entidad.

4. **Zona horaria**: Configurar `hibernate.jdbc.time_zone=UTC` para evitar desfases.

5. **FETCH FIRST vs ROWNUM**: Oracle 21c soporta `FETCH FIRST N ROWS ONLY` (estándar SQL). Preferir sobre `ROWNUM`.

6. **Los endpoints de reportes devuelven `List<Map<String, Object>>`** porque las columnas son dinámicas (especialmente PIVOT). No intentar mapear a DTOs fijos.

7. **Cada script SQL debe tener cabecera estándar** con: Proyecto, Script, Núcleo, Descripción, Autor, Fecha, Dependencias.

8. **El frontend es complementario al curso de BD**: Si el tiempo es limitado, priorizar que los endpoints funcionen correctamente (verificable vía Swagger/Postman) sobre perfeccionar el frontend.

9. **`CREATE OR REPLACE` para objetos PL/SQL** (procedures, functions, triggers, packages). `DROP TABLE ... IF EXISTS` o manejo de excepciones para tablas.

10. **Comentar cada tabla y columna** con `COMMENT ON TABLE` y `COMMENT ON COLUMN` para que el profesor vea profesionalismo y la IA tenga contexto en el diccionario de datos.
