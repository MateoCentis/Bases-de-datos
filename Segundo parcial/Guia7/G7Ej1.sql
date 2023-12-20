-- Ejercicio 1.
-- En SQL Server, cree una copia (Autores) de la tabla Authors. 
-- Luego defina un trigger llamado tr_ejercicio1 asociado al evento
-- DELETE sobre la misma. El trigger debe retornar un
-- mensaje (usando PRINT) “Se eliminaron n filas” indicando 
-- la cantidad de filas afectadas en la operación. Dispare luego 
-- la siguiente sentencia SQL para probar el trigger.
DELETE
FROM autores
WHERE au_id = '172-32-1176' or
au_id = '213-46-8915'
GO
CREATE TRIGGER tr_ejercicio1
    ON autores
    AFTER DELETE
    AS
    DECLARE
        @cantFilas INTEGER;
    BEGIN
        SET @cantFilas = (SELECT COUNT(*) FROM DELETED);
        PRINT 'Se eliminaron ' +Convert(varchar,@CantFilas) + ' filas'
    END
