-- =====================================================================
-- Ejercicio 04: Diagnóstico de la tabla Turno
-- Base de datos: CentroMedico
-- =====================================================================
-- Problema: INSERT en Turno daba "Msg 544 – Cannot insert explicit value
-- for identity column", aunque el INSERT NO incluía idTurno.
-- En lugar de adivinar, se consulta cómo está construida la tabla.
-- =====================================================================
USE CentroMedico
GO

-- 1. ¿Qué columnas de Turno son IDENTITY? Tipo y si aceptan NULL.
--    HALLAZGO: estado tenía is_identity = 1 e idTurno tenía 0.
SELECT name                      AS columna,
       TYPE_NAME(system_type_id) AS tipo,
       is_nullable               AS acepta_null,
       is_identity               AS es_identity
FROM sys.columns
WHERE object_id = OBJECT_ID('Turno')

-- 2. Largo del VARCHAR de observacion (resultado: 1000).
--    Ojo: sin la coma entre name y max_length, max_length se vuelve un alias.
SELECT name, max_length
FROM sys.columns
WHERE object_id = OBJECT_ID('Turno') AND name = 'observacion'

-- 3. ¿Qué Foreign Keys apuntan a Turno y con qué columna?
--    HALLAZGO: FK_PagoPaciente_Turno y FK_TurnoPaciente_Turno, ambas sobre idTurno.
SELECT fk.name                          AS foreign_key,
       OBJECT_NAME(fk.parent_object_id) AS tabla,
       COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS columna
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE fk.referenced_object_id = OBJECT_ID('Turno')
