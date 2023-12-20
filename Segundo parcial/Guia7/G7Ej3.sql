-- Implemente un trigger T-SQL (tr_ejercicio3) para inserción sobre
-- la misma que, ante la inserción de un producto con stock negativo,
-- dispare el error de aplicación 'El stock debe ser positivo o cero'
-- con una severidad 12 y contexto 1 y deshaga la transacción. Testee
-- su funcionamiento disparando la siguiente sentencia INSERT:
INSERT INTO Productos
VALUES (10, 'Producto 10', 200, -6)
-- TABLE productos
-- codProd int
-- descr varchar(30)
-- precUnit float
-- stock smallint
GO
CREATE TRIGGER tr_ejercicio3
    ON Productos
    AFTER INSERT
    AS
    DECLARE @stock INTEGER;
    BEGIN
        SET @stock = (SELECT stock FROM INSERTED)
        IF (@stock < 0)
            BEGIN
                RAISERROR('El stock debe ser positivo o cero',12,1)
                ROLLBACK TRANSACTION
            END
    END
