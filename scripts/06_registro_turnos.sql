-- =====================================================================
-- Ejercicio 06: Registro de turnos (citas)
-- Base de datos: CentroMedico
-- =====================================================================
-- Receta de 5 pasos para registrar una cita:
--   1. INSERT en Turno                     -> crea la cita
--   2. SELECT MAX(idTurno) FROM Turno       -> ¿qué número le tocó?
--   3. SELECT ... FROM Paciente WHERE ...   -> ¿qué número es el paciente?
--   4. SELECT ... FROM Medico WHERE ...     -> ¿qué número es el médico?
--   5. INSERT en TurnoPaciente              -> conecta los tres números
--
-- Reglas aprendidas:
--   * Fechas en formato 'AAAAMMDD' (seguro en cualquier configuración).
--   * Números sin comillas; texto y fechas con comillas.
--   * Filtrar con el valor tal como está guardado ('Lopez', no 'López').
--   * Nunca suponer el idTurno: el IDENTITY puede tener saltos.
-- Ejecutar cada paso por separado (seleccionar las líneas + F5).
-- =====================================================================
USE CentroMedico
GO

-- Consulta de apoyo: significado de cada estado
SELECT * FROM TurnoEstado

-- ---------------------------------------------------------------------
-- Turno 1: Leandro Paredes con el Dr. Rafael Castro
-- ---------------------------------------------------------------------
INSERT INTO Turno (fechaTurno, estado, observacion)
VALUES ('20230315', 0, 'Paciente en ayunas')                 -- 0 = Pendiente

SELECT MAX(idTurno) AS ultimoTurno FROM Turno                -- resultado: 1

SELECT idPaciente, nombre, apellido
FROM Paciente
WHERE nombre = 'Leandro' AND apellido = 'Paredes'            -- resultado: 9

SELECT idMedico, nombre, apellido
FROM Medico
WHERE nombre = 'Rafael' AND apellido = 'Castro'              -- resultado: 1

INSERT INTO TurnoPaciente (idTurno, idPaciente, idMedico)
VALUES (1, 9, 1)

-- ---------------------------------------------------------------------
-- Turno 2: Carlos López con el Dr. Rafael Castro
-- ---------------------------------------------------------------------
INSERT INTO Turno (fechaTurno, estado, observacion)
VALUES ('20230320', 2, 'El paciente no pudo asistir')        -- 2 = Cancelado

SELECT MAX(idTurno) AS ultimoTurno FROM Turno                -- resultado: 2

SELECT idPaciente, nombre, apellido
FROM Paciente
WHERE nombre = 'Carlos' AND apellido = 'Lopez'               -- resultado: 5

INSERT INTO TurnoPaciente (idTurno, idPaciente, idMedico)
VALUES (2, 5, 1)

-- ---------------------------------------------------------------------
-- Turno 3: Claudio López con el Dr. Rafael Castro
-- ---------------------------------------------------------------------
INSERT INTO Turno (fechaTurno, estado, observacion)
VALUES ('20230401', 4, 'El paciente solicito cambiar la fecha')  -- 4 = Postergado

SELECT MAX(idTurno) AS ultimoTurno FROM Turno
-- resultado: 4 (¡no 3!). El IDENTITY se saltó un número porque un intento
-- anterior lo "gastó". Usar (3, 6, 1) dio el error Msg 547 de Foreign Key.

SELECT idPaciente, nombre, apellido
FROM Paciente
WHERE nombre = 'Claudio' AND apellido = 'Lopez'              -- resultado: 6

INSERT INTO TurnoPaciente (idTurno, idPaciente, idMedico)
VALUES (4, 6, 1)

-- ---------------------------------------------------------------------
-- Verificación final
-- ---------------------------------------------------------------------
SELECT * FROM Turno
SELECT * FROM TurnoPaciente
