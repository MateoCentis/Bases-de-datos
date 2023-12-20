--Cargue el siguiente lote de prueba en la tabla productos
--(10, “Articulo 1”, 50, 20)
--(20, “Articulo 2”, 70, 40)
INSERT INTO productos
VALUES
  (10, 'Articulo 1', 50, 20)

INSERT INTO productos
VALUES
  (10, 'Articulo 1', 50, 20)
GO
-- El valor que almacena en la columna precioTot de la tabla Detalle se calcula en función
-- de la cantidad pedida de un producto (columna cant) y su precio unitario (columna
-- precUnit en la tabla productos). 

-- El valor que almacena en la columna precioTot de la tabla Detalle se calcula en función
-- de la cantidad pedida de un producto (columna cant) y su precio unitario (columna
-- precUnit en la tabla productos). 

-- Para obtener el valor correspondiente a la columna precioTot, el procedimiento principal
-- debe invocar a un procedimiento auxiliar (buscarPrecio) que retorne el precio unitario
-- correspondiente al producto recibido como parámetro en insertarDetalle.

CREATE PROCEDURE buscarPrecio
  (
  @prmIdProducto int,
  @prmPrecioProducto FLOAT OUTPUT
)
AS
(SELECT @prmPrecioProducto =  precUnit
FROM productos
WHERE codProd = @prmIdProducto)

GO

CREATE PROCEDURE insertarDetalle
  (
  @prmCodDetalle int,
  @prmNumPed int,
  @prmCodProd int,
  @prmCantVendida int
)
AS
DECLARE @precio FLOAT
EXECUTE buscarPrecio @prmCodProd, @precio OUTPUT
DECLARE @precioTot FLOAT = @precio*@prmCantVendida
INSERT INTO detalle
VALUES
  (@prmCodDetalle, @prmNumPed, @prmCodProd, @prmCantVendida, @precioTot)

EXECUTE insertarDetalle 1540,120,10,2