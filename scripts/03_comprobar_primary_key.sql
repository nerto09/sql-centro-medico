-- =====================================================================
-- Ejercicio 03: Comprobar la Primary Key de TurnoEstado
-- Base de datos: CentroMedico
-- =====================================================================
USE CentroMedico
GO

-- 1. Insertar un idEstado que ya existe.
--    RESULTADO ESPERADO: error Msg 2627 (Violation of PRIMARY KEY).
--    El error es la prueba de que la Primary Key funciona.
INSERT INTO TurnoEstado (idEstado, descripcion)
VALUES (0, 'Prueba')

-- 2. Ver el nombre que SQL Server le puso a la Primary Key.
--    Como se creó sin nombre, era algo como PK__TurnoEst__62EA894A8A9006CE
SELECT name
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('TurnoEstado')

-- 3. Darle un nombre legible (aparece un aviso "Caution", no es error).
--    Reemplazar el nombre actual por el que devuelva la consulta anterior.
EXEC sp_rename 'dbo.PK__TurnoEst__62EA894A8A9006CE', 'PK_TurnoEstado'

-- 4. Verificar el cambio
SELECT name
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID('TurnoEstado')
