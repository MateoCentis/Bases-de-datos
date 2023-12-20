
---------------------------------------------------------------------------------------------
-------------------------Ejemplo con manejo de errores y transaccionado----------------------
---------------------------------------------------------------------------------------------



ALTER PROCEDURE insertarDetallev4
   (
    @CodDetalle Int,    -- IN
    @NumPed Int,	    -- IN
    @CodProd int,       -- IN
    @Cant  Int          -- IN
   )                        
   AS
      ------ Identica la invocacion que haciamos desde el batch -----------
      DECLARE  @PrecioObtenido FLOAT   --Parametro OUT del inner procedure
      DECLARE @StatusRetorno Int,   --Status de retorno del inner procedure
              @error Integer
      
      EXECUTE @StatusRetorno = buscarprecioV5 @CodProd, @PrecioObtenido OUTPUT
      
      SET @error = 0
      
      IF @StatusRetorno != 0
         BEGIN
            IF @StatusRetorno = 70
               BEGIN
                  --PRINT 'El producto no existe'
                  --RETURN
                  RAISERROR ('Producto inexistente' , 12, 1)
                  SET @error = @@Error
               END   
            ELSE
               IF @StatusRetorno = 71
                  BEGIN
                     --PRINT 'El producto no posee precio'
                     --RETURN
                      RAISERROR ('Producto sin precio' , 12, 1)
                  SET @error = @@Error
                  END   
               -- END IF   
            -- END IF   
          END  
       -- END IF   
      
      IF (@error = 0) 
      
         BEGIN
            BEGIN TRANSACTION 

            BEGIN TRY
               INSERT Detalle Values(@CodDetalle, @NumPed, @CodProd, @Cant, 
                               @Cant * @PrecioObtenido)
                               
               BEGIN TRY
                  UPDATE Detalle Set price = ....                
               
                  COMMIT TRANSACTION  
               END TRY
               
               
               BEGIN CATCH
                  EXECUTE usp_GetErrorInfo
                  ROLLBACK TRANSACTION
                  RETURN 90
                  
               END CATCH                
                               
            END TRY    
            
            BEGIN CATCH               
               EXECUTE usp_GetErrorInfo
               ROLLBACK TRANSACTION
               RETURN 91
            END CATCH
            
               
                            
            
         END
      -- END IF                      
      
      
      RETURN



