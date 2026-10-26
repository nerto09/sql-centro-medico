# SQL Server – Centro Médico 🏥

Práctica de **SQL Server (SSMS)** sobre la base de datos de un centro médico, realizada como parte de un curso de Udemy.

Además de los ejercicios, este repositorio documenta **los errores que encontré, cómo los diagnostiqué y cómo los resolví**. Para mí, aprender a investigar un problema es tan importante como escribir la consulta correcta.

---

## 📂 Contenido

| Script | Qué hace |
|---|---|
| [`01_insert_paciente.sql`](scripts/01_insert_paciente.sql) | Primer `INSERT` en la tabla `Paciente` |
| [`02_catalogo_turnoestado.sql`](scripts/02_catalogo_turnoestado.sql) | Carga de la tabla de catálogo `TurnoEstado` (estados 0 a 6) |
| [`03_comprobar_primary_key.sql`](scripts/03_comprobar_primary_key.sql) | Prueba de la Primary Key y renombrado de la restricción |
| [`04_diagnostico_tabla_turno.sql`](scripts/04_diagnostico_tabla_turno.sql) | Consultas a las vistas del sistema para diagnosticar la tabla `Turno` |
| [`05_reparacion_tabla_turno.sql`](scripts/05_reparacion_tabla_turno.sql) | Reparación de `Turno`: quitar FKs, recrear la tabla y restaurar las FKs |
| [`06_registro_turnos.sql`](scripts/06_registro_turnos.sql) | Registro de citas siguiendo una "receta" de 5 pasos |

---

## 🗂️ Tablas utilizadas

| Tabla | Tipo | Para qué sirve |
|---|---|---|
| `Paciente` | Movimiento | Datos de los pacientes |
| `Medico` | Movimiento | Datos de los médicos |
| `Turno` | Movimiento | Las citas: fecha, estado y observación |
| `TurnoPaciente` | Intermedia | Conecta una cita con su paciente y su médico |
| `TurnoEstado` | Catálogo | Significado de cada estado (0 = Pendiente … 6 = Derivado) |
| `PagoPaciente` | Movimiento | Pagos asociados a una cita |

```
 Paciente            TurnoPaciente              Turno                 TurnoEstado
┌──────────────┐    ┌──────────────────┐    ┌───────────────────┐    ┌──────────────┐
│ idPaciente   │◄───│ idPaciente       │    │ idTurno (PK)      │    │ idEstado (PK)│
│ nombre       │    │ idTurno          │───►│ fechaTurno        │    │ descripcion  │
│ apellido     │    │ idMedico         │    │ estado            │───►└──────────────┘
└──────────────┘    └────────┬─────────┘    │ observacion       │
 Medico                      │              └───────────────────┘
┌──────────────┐             │                       ▲
│ idMedico     │◄────────────┘               PagoPaciente.idTurno
│ nombre       │
└──────────────┘
```

---

## 🐞 Bitácora de errores

### 1. Un paciente insertado dos veces
- **Síntoma:** después de ejecutar el `INSERT`, el paciente no aparecía en los resultados. Lo ejecuté de nuevo y quedó duplicado.
- **Causa:** el script tenía el `SELECT` **antes** del `INSERT`. Al presionar F5 se ejecuta todo de arriba hacia abajo, así que el `SELECT` mostraba la tabla antigua.
- **Solución:** borrar el duplicado con `DELETE ... WHERE idPaciente = 10`.
- **Aprendizaje:** revisar la pestaña **Messages** (`1 row affected`), poner el `SELECT` después del `INSERT` y ejecutar solo las líneas seleccionadas.

### 2. "Edit Top 200 Rows" no mostraba los datos nuevos
- **Síntoma:** la ventana de edición de la tabla no mostraba el registro insertado, pero "Select Top 1000 Rows" sí.
- **Causa:** la ventana de edición es una **foto** de la tabla en el momento en que se abrió; no se actualiza sola.
- **Solución:** refrescarla con `Ctrl + R` o volver a abrirla.

### 3. Primary Key con un nombre ilegible
- **Síntoma:** el error de clave duplicada mostraba `PK__TurnoEst__62EA894A8A9006CE`.
- **Causa:** si la Primary Key se crea sin nombre, SQL Server genera uno aleatorio, distinto en cada servidor.
- **Solución:** `EXEC sp_rename` para darle un nombre legible, y en adelante declararla con `CONSTRAINT PK_NombreTabla PRIMARY KEY (...)`.

### 4. ⭐ El `IDENTITY` estaba en la columna equivocada
- **Síntoma:** `Msg 544 – Cannot insert explicit value for identity column`, aunque el `INSERT` **no** incluía `idTurno`.
- **Diagnóstico:** consultando `sys.columns` (`is_identity`) descubrí que `estado` era `IDENTITY` e `idTurno` no.
- **Causa:** error al crear la tabla.
- **Solución:** SQL Server no permite mover un `IDENTITY` con `ALTER`. Como la tabla estaba vacía, quité las dos Foreign Keys que dependían de ella (`sys.foreign_keys`), la borré, la recreé correctamente y restauré las FKs.
- **Aprendizaje:** una Primary Key **no tiene que ser** `IDENTITY`; son conceptos distintos. Y ante un error que no tiene sentido, se consulta cómo está construida la tabla en vez de adivinar.

### 5. Una coma faltante convirtió una columna en alias
- **Síntoma:** `SELECT name max_length ...` devolvía una sola columna titulada `max_length` con el texto `observacion`.
- **Causa:** sin la coma, `max_length` se interpretó como **alias** de `name` (el `AS` es opcional).
- **Solución:** `SELECT name, max_length ...`

### 6. Una búsqueda vacía por una tilde
- **Síntoma:** `WHERE apellido = 'López'` no devolvía nada, aunque el paciente existía.
- **Causa:** el dato estaba guardado como `Lopez`, sin tilde. Con la configuración por defecto, SQL Server **no** distingue mayúsculas pero **sí** distingue tildes.
- **Aprendizaje:** filtrar con el valor tal como está guardado. Un resultado vacío no siempre significa "no existe".

### 7. `MAX` no es lo mismo que `COUNT`
- **Síntoma:** usé el alias `CantidadTurno` para `MAX(idTurno)`.
- **Causa:** `MAX` devuelve el id más alto, no la cantidad. En `Paciente` (ids 1, 5, 6, 8, 9), `MAX` da 9 pero `COUNT(*)` da 5.
- **Aprendizaje:** un alias debe decir exactamente lo que contiene (`ultimoTurno`).

### 8. Conflicto de Foreign Key por un salto en el `IDENTITY`
- **Síntoma:** `Msg 547 – The INSERT statement conflicted with the FOREIGN KEY constraint "FK_TurnoPaciente_Turno"` al usar `idTurno = 3`.
- **Diagnóstico:** `SELECT * FROM Turno` mostró que la cita existía, pero con `idTurno = 4`.
- **Causa:** un número de `IDENTITY` que se entrega nunca se reutiliza, aunque el `INSERT` falle. El 3 se había "gastado".
- **Aprendizaje:** nunca suponer el id generado; consultarlo siempre con `MAX` (o `SCOPE_IDENTITY()`) antes de usarlo.

---

## 🧠 Conceptos practicados

- `INSERT`, `SELECT`, `DELETE`, filtros con `WHERE` y `AND`
- `IDENTITY` vs. Primary Key
- Foreign Keys e integridad referencial
- Tablas de catálogo (*lookup tables*) y datos semilla
- `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, `sp_rename`
- Vistas del sistema: `sys.columns`, `sys.foreign_keys`, `sys.foreign_key_columns`, `sys.key_constraints`
- Funciones de agregado (`MAX`, `COUNT`) y alias
- Transacciones con `BEGIN TRANSACTION` / `COMMIT` y `SET XACT_ABORT ON`
- Comandos de **datos** (`rows affected`) vs. comandos de **estructura** (`Commands completed successfully`)

---

## 🛠️ Herramientas

- SQL Server
- SQL Server Management Studio (SSMS)

---

## 👤 Autor

**Jhonniel García Samboy** — Estudiante de Ingeniería en Ciencia de Datos.
