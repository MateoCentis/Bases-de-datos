-- Escriba una función PL/pgSQL que dado un código de almacén 
--(stor_id) y un número de
-- factura (ord_num), retorne la fecha de dicha venta. 

CREATE OR REPLACE FUNCTION obtenerFechaVenta
(
    IN prmStor_id VARCHAR(4),
    IN prmOrd_num VARCHAR(20),
    OUT prmFechaVenta DATE
)

LANGUAGE plpgsql

AS

$$
    BEGIN
        SELECT ord_date
        INTO prmFechaVenta
        FROM sales
        WHERE stor_id = prmStor_id AND ord_num = prmOrd_num;
    END
$$;

SELECT obtenerFechaVenta('7067','P2121');