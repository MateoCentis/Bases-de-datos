-- Ejercicio 2.
-- Implemente en T-SQL un trigger (tr_ejercicio2) asociado a la 
-- tabla autores para inserción y actualización. El trigger debe 
-- mostrar un mensaje 'Datos insertados en transaction log', y a 
-- continuación los datos insertados. Luego 'Datos eliminados 
-- en transaction log' y a continuación los datos eliminados.
-- Modifique la configuración del menú Query a fin de que pueda
-- visualizar la salida de la ejecución como texto. 
-- (Query/Results to/Results to text). 
--Luego inserte la siguiente fila y evalúe los resultados:
INSERT INTO autores
SELECT '111-11-1111', 'Lynne', 'Jeff', '415 658-9932',
'Galvez y Ochoa', 'Berkeley', 'CA', '94705', 1
--Modifique la fila insertada y evalúe los resultados:
UPDATE Autores
SET au_fname = 'Nicanor' WHERE au_id = '111-11-1111'

GO
CREATE TRIGGER tr_ejercicio2 
    ON Autores
    FOR INSERT,UPDATE
    AS
    BEGIN
        PRINT 'Datos insertados en transaction log'
        --datos insertados (INSERTED)
        SELECT * FROM INSERTED
        PRINT 'Datos eliminados en transaction log'
        --datos eliminados (DELETED)
        SELECT * FROM DELETED
    END