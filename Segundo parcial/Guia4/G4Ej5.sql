--queremos registrar el pedido de cinco unidades de este producto
INSERT productos
VALUES
  (100, 'Articulo 3', 30, 10)

--nuestro detalle a insertar seria: 
--Estas operaciones deben tener exito o fracasar JUNTAS
--no podemos descontar unidades del stock y no registrar el pedido
--escribir un batch en TSQL, especifique un valor NULL para la columna
--precioTOT

BEGIN TRANSACTION
--debemos registrar pedido 5 unidades pero para esto chequear stock
--detalle: codDetalle 1200,NumPed 1108, codProd 100, cant 5
DECLARE @varStock smallint

SET @varStock =
(SELECT stock
FROM productos
WHERE codProd = 100)


IF @varStock < 5
BEGIN
  PRINT 'El stock no es suficiente'
  ROLLBACK TRANSACTION
END
ELSE
BEGIN
  INSERT INTO detalle
  VALUES
    (1200, 1108, 100, 5, NULL)

  UPDATE productos
SET stock = productos.stock - 5
WHERE codProd = 100
  COMMIT TRANSACTION
END