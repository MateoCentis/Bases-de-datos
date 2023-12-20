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

GO
CREATE TRIGGER tr_ejercicio4
    ON titles
    AFTER INSERT
    AS
    DECLARE @cantidad INTEGER,
            @id VARCHAR,
            @precio FLOAT,
            @monto FLOAT;
    BEGIN
    SET @id = (SELECT pub_id FROM INSERTED)
    SET @monto = (SELECT SUM(qty*price)
                    FROM sales S INNER JOIN Titles T ON 
                        S.title_id = T.title_id
                        WHERE T.pub_id = @id)
    IF (@monto < 1500)
        BEGIN
            RAISERROR('Tiene que vender mas de 1500 la editorial',5,1)
            ROLLBACK TRANSACTION
        END
    END