-- Ejercicio 6.
-- En PostgreSQL, agregue dos columnas adicionales a la tabla Publishers:
-- FechaHoraAlta está destinada a guardar la fecha y hora en que se da de alta una editorial.
-- UsuarioAlta se utilizará para registrar el usuario que realizó la operación de inserción:
ALTER TABLE publishers
ADD COLUMN FechaHoraAlta DATE NULL;
ALTER TABLE publishers
ADD COLUMN UsuarioAlta VARCHAR(255) NULL;
-- Defina un trigger (tr_ejercicio6) que, ante la inserción de una editorial, permita registrar la
-- fecha y hora de la operación (función CURRENT_TIMESTAMP) y el usuario que llevó a cabo la
-- operación (función SESSION_USER).
-- Por ejemplo:
insert into publishers
values('8888', 'Editorial Ejercicio 8', 'Boston', 'MA', 'USA');

CREATE OR REPLACE FUNCTION tr_function6()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
    BEGIN
        NEW.FechaHoraAlta := CURRENT_TIMESTAMP;
        NEW.UsuarioAlta := SESSION_USER;
        RETURN NEW;
    END;
$$;

CREATE TRIGGER tr_ejercicio6
    BEFORE
    INSERT on publishers
    FOR EACH ROW
    EXECUTE PROCEDURE tr_function6()