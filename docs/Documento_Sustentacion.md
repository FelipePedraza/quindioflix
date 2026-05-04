# QUINDIOFLIX - Documento de Sustentación

## 1. DECISIONES DE DISEÑO DEL MODELO DE DATOS

### 1.1 Normalización
- Se aplicó **3FN (Tercera Forma Normal)** a todas las tablas
- Eliminación de dependencias transitivas
- Cada tabla tiene una clave primaria única

### 1.2 Relaciones
- **Relación reflexiva** en USUARIOS (id_referidor): Permite sistema de referidos
- **Relación reflexiva** en EMPLEADOS (id_supervisor): Jerarquía organizacional
- **Relación reflexiva** en DEPARTAMENTOS (id_jefe): Estructura departamental
- **Relación N:M** en CONTENIDO_GENERO y CONTENIDO_RELACIONADO

### 1.3 Justificación de tipos de datos
- VARCHAR2 en lugar de VARCHAR (Oracle)
- NUMBER para IDs (escala 0)
- DATE para fechas simples
- TIMESTAMP para fechas con hora
- CLOB para textos largos (sinopsis, reseñas)
- BLOB para avatares
- CHAR(1) para flags (S/N)

## 2. JUSTIFICACIÓN DE FRAGMENTACIÓN

### Tabla REPRODUCCIONES
**Particionamiento por rango de fecha (año)**

- **Justificación**: 
  - Alto volumen de datos (reproducciones frecuentes)
  - Consultas típicas por rango de fechas
  - Mantenimiento independiente por año
  - Facilita purge de datos antiguos

- **Particiones**:
  - TS_REPRO_2024: Datos 2024
  - TS_REPRO_2025: Datos 2025  
  - TS_REPRO_2026: Datos 2026 y MAXVALUE

## 3. ANÁLISIS DE ÍNDICES

### IDX_REPRO_PERFIL_FECHA
- **Tabla**: REPRODUCCIONES
- **Columns**: (id_perfil, fecha_hora_inicio)
- **Justificación**: Historial por perfil es la consulta más frecuente

### IDX_USUARIOS_EMAIL
- **Tabla**: USUARIOS
- **Columns**: (email) UNIQUE
- **Justificación**: Validación de unicidad en registro/login

### IDX_CONTENIDO_CAT_ANIO
- **Tabla**: CONTENIDO
- **Columns**: (id_categoria, anio_lanzamiento)
- **Justificación**: Búsquedas por categoría y rango de años

### IDX_PAGOS_USUARIO_FECHA
- **Tabla**: PAGOS
- **Columns**: (id_usuario, fecha_pago, estado_pago)
- **Justificación**: Reportes financieros y FN_CALCULAR_MONTO

### Resultados EXPLAIN PLAN (ejemplo)
- **SIN índice**: FULL TABLE SCAN, Costo: ~150
- **CON índice**: INDEX RANGE SCAN, Costo: ~25
- **Mejora**: ~83%

## 4. ESCENARIO DE CONCURRENCIA

### Cambio de plan simultáneo
**Objetivo**: Demostrar bloqueo de fila con SELECT FOR UPDATE

**Procedimiento**:
1. Sesión A: `SELECT * FROM USUARIOS WHERE id_usuario = 5 FOR UPDATE;`
2. Sesión B: `UPDATE USUARIOS SET id_plan = 2 WHERE id_usuario = 5;`
   - Sesión B queda en **WAITING**
3. Sesión A: `COMMIT;`
   - Sesión B se ejecuta

**Tipo de bloqueo**:
- SELECT FOR UPDATE: Bloqueo exclusivo (RX)
- Modo de espera: WAIT (por defecto)

## 5. JUSTIFICACIÓN DE LA JERARQUÍA DE EMPLEADOS

### Relación reflexiva en EMPLEADOS
- **id_supervisor**: Auto-referencia al empleado supervisor
- Permite jerarquía organizacional
- FK establecida como DEFERRABLE para inserts iniciales

### Estructura:
```
EMPLEADOS
├── id_empleado (PK)
├── nombre
├── email
├── id_departamento (FK)
├── id_supervisor (FK -> EMPLEADOS)
└── rol (CHECK)
```

## 6. DECISIONES DE SEGURIDAD

### Roles y Privilegios (principio de menor privilegio)

| Rol | Justificación |
|-----|----------------|
| ROL_ADMIN | Acceso completo para administración |
| ROL_ANALISTA | Solo lectura + reportes (no modifica datos) |
| ROL_SOPORTE |Gestión de usuarios y pagos (no contenido) |
| ROL_CONTENIDO |Gestión de catálogo (no datos financieros) |

### Perfil de recursos
- Límite de sesiones: 3 (evita conexiones excesivas)
- Tiempo idle: 30 min
- Intentos fallidos: 5
- Tiempo conexión: 8 horas

## 7. ARQUITECTURA DE LA APLICACIÓN

### Capas
1. **Controller**: Endpoints REST
2. **Service**: Lógica de negocio
3. **Repository**: Acceso a datos (JDBC)
4. **DTO**: Transferencia de datos

### Integración con PL/SQL
- Stored Procedures para operaciones complejas
- Functions para cálculos (FN_CALCULAR_MONTO)
- Triggers para integridad

## 8. SPRINTS COMPLETADOS

| Sprint | Tema | Estado |
|--------|------|--------|
| 0 | Configuración | ✓ Completo |
| 1 | DDL (Modelo) | ✓ Completo |
| 2 | DML (Datos) | ✓ Completo |
| 3 | Consultas NT1 | ✓ Completo |
| 4 | PL/SQL NT2-1 | ✓ Completo |
| 5 | Triggers NT2-2 | ✓ Completo |
| 6 | Transacciones NT3 | ✓ Completo |
| 7 | Índices NT4 | ✓ Completo |
| 8 | Seguridad Oracle NT5 | ✓ Completo |
| 9 | API REST | ✓ Completo |
| 10 | JWT | ✓ Completo |
| 11 | Documentación | ✓ Completo |

---

**Universidad del Quindío**
**Bases de Datos II - 2025-1**