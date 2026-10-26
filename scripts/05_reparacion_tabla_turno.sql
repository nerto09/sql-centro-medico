-- =====================================================================
-- Ejercicio 05: Reparación de la tabla Turno
-- Base de datos: CentroMedico
-- =====================================================================
-- SQL Server no permite quitar ni agregar IDENTITY con ALTER.
-- Como Turno estaba vacía, la solución fue recrearla:
--   1. Quitar las FKs que dependen de Turno
--   2. Borrar Turno
--   3. Crearla correctamente (IDENTITY en idTurno, no en estado)
--   4. Restaurar las FKs
-- Todo va en una transacción: si un paso falla, se deshace todo.
-- ⚠️ Solo es seguro porque la tabla estaba VACÍA.
-- =====================================================================
USE CentroMedico
GO

SET XACT_ABORT ON
BEGIN TRANSACTION

    -- 1. Quitar las Foreign Keys (viven en las tablas que dependen de Turno)
    ALTER TABLE PagoPaciente  DROP CONSTRAINT FK_PagoPaciente_Turno
    ALTER TABLE TurnoPaciente DROP CONSTRAINT FK_TurnoPaciente_Turno

    -- 2. Borrar la tabla mal creada
    DROP TABLE Turno

    -- 3. Crearla correctamente, con nombre legible para la Primary Key
    CREATE TABLE Turno (
        idTurno     INT IDENTITY(1,1) NOT NULL,
        fechaTurno  DATETIME NULL,
        estado      SMALLINT NOT NULL,
        observacion VARCHAR(1000) NULL,
        CONSTRAINT PK_Turno PRIMARY KEY (idTurno)
    )

    -- 4. Restaurar las Foreign Keys
    ALTER TABLE PagoPaciente ADD CONSTRAINT FK_PagoPaciente_Turno
        FOREIGN KEY (idTurno) REFERENCES Turno(idTurno)

    ALTER TABLE TurnoPaciente ADD CONSTRAINT FK_TurnoPaciente_Turno
        FOREIGN KEY (idTurno) REFERENCES Turno(idTurno)

COMMIT
GO

-- Verificación 1: solo idTurno debe tener es_identity = 1
SELECT name AS columna, is_identity AS es_identity
FROM sys.columns
WHERE object_id = OBJECT_ID('Turno')

-- Verificación 2: deben aparecer las 2 Foreign Keys
SELECT name AS foreign_key, OBJECT_NAME(parent_object_id) AS tabla
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID('Turno')
