-- =====================================================================
-- Ejercicio 01: Insertar un paciente
-- Base de datos: CentroMedico
-- =====================================================================
USE CentroMedico
GO

-- idPaciente NO se escribe: es IDENTITY y lo genera SQL Server.
INSERT INTO Paciente (dni, nombre, apellido, fNacimiento, domicilio, idPais, telefono, email, observacion)
VALUES ('33522159', 'Leandro', 'Paredes', '1982-05-20', 'Piedras 150', 'ARG', NULL, 'leandro@gmail.com', '')

-- Verificar: el SELECT va DESPUÉS del INSERT para ver la fila nueva.
-- (Error cometido: con el SELECT antes del INSERT, F5 mostraba la tabla
--  antigua; al ejecutar de nuevo, el paciente quedó duplicado.)
SELECT * FROM Paciente

-- Corrección del duplicado generado al ejecutar el INSERT dos veces.
-- ⚠️ Siempre usar WHERE en un DELETE: sin él se borra la tabla completa.
-- DELETE FROM Paciente WHERE idPaciente = 10
