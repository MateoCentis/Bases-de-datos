--Se quiere mejorar el procedure insertarDetalle
--si sucediese que el codProd no exista en la tabla productos
--queremos que esta situacion sea indicada en un mensaje 
--y que el insert no se ejecute
--de misma manera si el precio del producto es NULL
--Anda con comprobaciones
CREATE PROCEDURE buscarPrecio
  (
  @prmIdProducto int,
  @prmPrecioProducto FLOAT OUTPUT
)
AS

IF 0 = (SELECT COUNT(1)
FROM productos
WHERE codProd = @prmIdProducto)
  BEGIN
  SET @prmPrecioProducto = -1
  RETURN
END

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
IF @precio = NULL OR @precio = -1
  PRINT 'Codigo de producto inexistente o sin precio'
RETURN

DECLARE @precioTot FLOAT = @precio*@prmCantVendida
INSERT INTO detalle
VALUES
  (@prmCodDetalle, @prmNumPed, @prmCodProd, @prmCantVendida, @precioTot)

EXECUTE insertarDetalle 1540,120,10,2