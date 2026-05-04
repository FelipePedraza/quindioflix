# QuindioFlix - Backend

**Universidad del Quindío · Bases de Datos II · 2026-1**

Plataforma de streaming desarrollada con Java 21, Spring Boot 4.0.6 y Oracle Database.

## Tecnologías

- **Backend:** Java 21, Spring Boot 4.0.6
- **Seguridad:** Spring Security + JWT (jjwt)
- **Base de datos:** Oracle Database (ojdbc11)
- **Build:** Gradle 9.4.1

## Estructura del Proyecto

```
src/main/java/com/uniquindio/quindioflix/
├── config/           # Configuraciones
├── controller/        # REST Controllers
├── exception/        # Manejo de excepciones
├── model/
│   ├── dto/         # Data Transfer Objects
│   └── entity/       # Entidades
├── repository/       # Capa de acceso a datos
├── service/          # Lógica de negocio
└── util/             # Utilidades

src/main/resources/
├── sql/              # Scripts SQL
│   ├── 01_DDL_tablas.sql
│   ├── 02_DML_datos_prueba.sql
│   ├── 03_NT1_consultas_avanzadas.sql
│   ├── 04_NT2_cursores_sp_funciones.sql
│   ├── 05_NT2_excepciones_triggers.sql
│   ├── 06_NT3_transacciones.sql
│   ├── 07_NT4_indices.sql
│   └── 08_NT5_usuarios_roles.sql
└── application.properties
```

## Configuración

### Variables de entorno

```properties
# Oracle
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:XE
spring.datasource.username=quindioflix_owner
spring.datasource.password=quindioflix2025

# JWT
jwt.secret=tu_secret_key
jwt.expiration=86400000
```

## Ejecución

### Requisitos

- JDK 21
- Oracle Database Xe 21c
- Gradle 9.4.1

### Compilar

```bash
./gradlew build
```

### Ejecutar

```bash
./gradlew bootRun
```

La aplicación arrancará en `http://localhost:8080`

## Ejecución de Scripts SQL

Ejecutar en el siguiente orden:

```sql
-- 1. Crear modelo de datos
@src/main/resources/sql/01_DDL_tablas.sql

-- 2. Insertar datos de prueba
@src/main/resources/sql/02_DML_datos_prueba.sql

-- 3. Consultas avanzadas
@src/main/resources/sql/03_NT1_consultas_avanzadas.sql

-- 4. PL/SQL: Cursores y funciones
@src/main/resources/sql/04_NT2_cursores_sp_funciones.sql

-- 5. PL/SQL: Triggers
@src/main/resources/sql/05_NT2_excepciones_triggers.sql

-- 6. Transacciones
@src/main/resources/sql/06_NT3_transacciones.sql

-- 7. Índices
@src/main/resources/sql/07_NT4_indices.sql

-- 8. Seguridad Oracle
@src/main/resources/sql/08_NT5_usuarios_roles.sql
```

## Endpoints REST

### Autenticación

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/login` | Iniciar sesión |
| POST | `/api/auth/logout` | Cerrar sesión |

### Usuarios

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/usuarios` | Listar usuarios |
| GET | `/api/usuarios/{id}` | Obtener usuario |
| POST | `/api/usuarios` | Crear usuario |
| POST | `/api/usuarios/registrar` | Registrar (SP) |
| PUT | `/api/usuarios/{id}/plan` | Cambiar plan |
| DELETE | `/api/usuarios/{id}` | Eliminar usuario |

### Contenido

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/contenido` | Listar catálogo |
| GET | `/api/contenido/{id}` | Detalle contenido |
| GET | `/api/contenido/categoria/{id}` | Por categoría |
| GET | `/api/contenido/buscar?q=` | Buscar |
| POST | `/api/contenido` | Crear contenido |
| PUT | `/api/contenido/{id}` | Actualizar |
| DELETE | `/api/contenido/{id}` | Eliminar |

### Sistema

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/health` | Health check |

## API Responses

Todos los endpoints retornan:

```json
{
  "success": true,
  "message": "Mensaje",
  "data": { ... }
}
```

## Seguridad

### Roles y Acceso

| Rol | Endpoints |
|-----|----------|
| ADMIN | Todos |
| ANALISTA | GET /api/reportes/** |
| SOPORTE | /api/pagos/**, /api/usuarios/{id}/plan |
| CONTENIDO | CRUD /api/contenido/** |
| USER | Propios datos |

### JWT

- Token válido por 24 horas (86400000 ms)
- Header: `Authorization: Bearer <token>`

## Modelo de Datos

### Tablas Principales

- **PLANES**: Planes de suscripción
- **USUARIOS**: Usuarios registrados
- **PERFILES**: Perfiles por usuario
- **CONTENIDO**: Catálogo audiovisual
- **CATEGORIAS**: Películas, Series, Documentales, Música, Podcasts
- **GENEROS**: Géneros del contenido
- **REPRODUCCIONES**: Historial de reproducciones (particionada)
- **CALIFICACIONES**: Calificaciones y reseñas
- **FAVORITOS**: Contenidos favoritos
- **PAGOS**: Historial de pagos
- **EMPLEADOS**: Empleados
- **DEPARTAMENTOS**: Departamentos

## Documentación Adicional

- Diagrama del modelo: `docs/BasesDatosII.svg`
- Plan de sprints: `docs/QuindioFlix_Sprints_Backend.md`
