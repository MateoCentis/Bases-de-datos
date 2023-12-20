--tabla detalle=>PrecioTot=cant*precUnit
--insertarDetalle invoca (buscarPrecio(codProducto) retorna precioUnitario)

CREATE PROCEDURE buscarPrecioV2
 (
 @CodProd int, -- Parametro de entrada
 @PrecUnit float OUTPUT -- Parametro de salida
 )
 AS
 SELECT @PrecUnit = PrecUnit
 FROM Productos
 WHERE CodProd = @Codprod

 IF @@RowCount = 0
 RETURN 70 -- No se encontro el producto
 -- END IF

 IF @PrecUnit IS NULL
 RETURN 71 -- El producto existe pero su precio es NULL
 -- END IF

 RETURN 0 -- El producto existe y su precio no es NULL
 GO
ALTER PROCEDURE insertarDetalle2
 (
 @CodDetalle Int, -- Parametro de entrada
 @NumPed Int, -- Parametro de entrada
 @CodProd int, -- Parametro de entrada
 @Cant Int -- Parametro de entrada
 ) AS

 DECLARE @PrecioObtenido FLOAT --Parametro de salida del procedimiento auxiliar
 DECLARE @StatusRetorno Int
 EXECUTE @StatusRetorno = buscarPrecioV2 @CodProd, @PrecioObtenido OUTPUT

 IF @StatusRetorno != 0 
    BEGIN
        IF @StatusRetorno = 70
            BEGIN
                PRINT 'Codigo de producto inexistente'
                RETURN
            END
         ELSE
            IF @StatusRetorno = 71
                BEGIN
                    PRINT 'El producto no posee precio'
                    RETURN
                END-- END IF
    END -- END IF

 INSERT Detalle Values(@CodDetalle, @NumPed, @CodProd, @Cant,@Cant * @PrecioObtenido)
 If @@RowCount = 1
     PRINT 'Se inserto una fila'
 RETURN 

GO--Mejorado con manejo de errores
ALTER PROCEDURE insertarDetalle3
 (
 @CodDetalle Int, -- Parametro de entrada
 @NumPed Int, -- Parametro de entrada
 @CodProd int, -- Parametro de entrada
 @Cant Int -- Parametro de entrada
 ) AS

 DECLARE @PrecioObtenido FLOAT --Parametro de salida del procedimiento auxiliar
 DECLARE @StatusRetorno Int
 EXECUTE @StatusRetorno = buscarPrecioV2 @CodProd, @PrecioObtenido OUTPUT
 --Status retorno = 0 significa que la publicación existe y su precio no es NULL
 DECLARE @error int--1)lo primero que hacemos es preparar una variable local 
 SET @error = 0;--para guardar @@error
 IF @StatusRetorno != 0 --2)evaluamos el return value de buscarPrecio
    BEGIN--si la publicacion no existe disparamos nosotros mismo el RAISERROR
        IF @StatusRetorno = 70--tambien elegimos la severidad del error
            BEGIN--
                RAISERROR('Publicacion inexistente',12,1)
                SET @error = @@error
            END
         ELSE
            IF @StatusRetorno = 71
                BEGIN
                    RAISERROR('El producto no posee precio',12,1)
                    SET @error = @@error
                END-- END IF
    END -- END IF
    
    IF (@error = 0)
    BEGIN
        BEGIN TRY       
        INSERT Detalle Values(@CodDetalle, @NumPed, @CodProd, @Cant,@Cant * @PrecioObtenido)
        PRINT 'Se inserto una fila'
        RETURN 0
        END TRY
    
    BEGIN CATCH--Si el insert tiene algun problema va a al catch
        EXECUTE usp_GetErrorInfo
        RETURN 72
    END CATCH
    END
