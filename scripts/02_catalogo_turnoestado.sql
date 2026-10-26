-- =====================================================================
-- Ejercicio 02: Cargar la tabla de catálogo TurnoEstado
-- Base de datos: CentroMedico
-- =====================================================================
-- TurnoEstado es una tabla de catálogo (lookup table): guarda el
-- significado de cada estado. En Turno solo se guarda el número.
-- Aquí idEstado SÍ se escribe, porque NO es IDENTITY.
-- =====================================================================
USE CentroMedico
GO

INSERT INTO TurnoEstado (idEstado, descripcion)
VALUES (0, 'Pendiente'),
       (1, 'Realizado'),
       (2, 'Cancelado'),
       (3, 'Rechazado'),
       (4, 'Postergado'),
       (5, 'Anulado'),
       (6, 'Derivado')

-- Verificar (debe devolver 7 filas)
SELECT * FROM TurnoEstado
