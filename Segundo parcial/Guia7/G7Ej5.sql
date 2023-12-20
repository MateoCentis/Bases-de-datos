-- Ejercicio 4.
-- Implemente un trigger T-SQL (tr_ejercicio4) que impida insertar 
-- publicaciones de editoriales que no hayan vendido por más de $1500
-- (tabla Sales). Por ejemplo, La editorial '1389' posee un monto 
-- de ventas que debería permitir la inserción de sus publicaciones. 
-- En cambio, para la editorial '0736' seguramente se debería 
-- impedir la inserción de publicaciones. Puede probar el trigger 
-- con las siguientes sentencias INSERT:
INSERT INTO titles
SELECT 'PC4545', 'Prueba 1', 'trad_cook', '1389',
14.99, 8000.00, 10, 4095, 'Prueba 1', CURRENT_TIMESTAMP

INSERT INTO titles
SELECT 'PC4646', 'Prueba 2', 'trad_cook', '0736',
14.99, 8000.00, 10, 4095, 'Prueba 1', CURRENT_TIMESTAMP

-- Ejercicio 5.
-- Escriba el mismo trigger como tr_ejercicio5 en PL/pgSQL.

CREATE OR REPLACE FUNCTION tr_function5()
RETURNS trigger
LANGUAGE plpgsql
AS
$$
    DECLARE id VARCHAR;
    DECLARE monto FLOAT;
    BEGIN
        id := NEW.pub_id;
        monto := (SELECT SUM(qty*price)
                    FROM sales S INNER JOIN Titles T ON 
                        S.title_id = T.title_id
                        WHERE T.pub_id = id);
        IF (monto < 1500) THEN
            RAISE NOTICE 'Tiene que vender mas de 1500 la editorial';
            RETURN NULL;
        ELSE
	    RETURN NEW;
	END IF;
    END
$$;

CREATE TRIGGER tr_ejercicio5
    BEFORE
    INSERT ON Titles
    FOR EACH ROW
    EXECUTE PROCEDURE tr_function5();