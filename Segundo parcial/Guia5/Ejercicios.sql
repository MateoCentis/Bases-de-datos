use pubs2

------------------------------------------------------------------------------------
------------------------------- E j e r c i c i o    3  ---------------------------
------------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-------------------------------------- Pre - requisitos --------------------------
----------------------------------------------------------------------------------


CREATE TABLE cliente 
  (
   codCli 	int		NOT NULL, 
   ape  	varchar(30)	NOT NULL,
   nom		varchar(30) 	NOT NULL,
   dir		varchar(40)	NOT NULL,
   codPost	char(9)	NULL DEFAULT 3000
  )



CREATE TABLE proveed 
  (
   codProv 	int		IDENTITY(1,1),
   razonSoc  varchar(30)	NOT NULL,
   dir		varchar(30) 	NOT NULL
  )




CREATE TABLE pedidos 
  (
   numPed 	int		NOT NULL,
   fechPed  	datetime	NOT NULL,
   codCli	int 		NOT NULL
  )


--DROP TABLE Productos
CREATE TABLE productos 
  (
   codProd 	int		NOT NULL,
   descr  	varchar(30)	NOT NULL,
   precUnit	float		NULL,  --- Modificar la condicion de NULLable
   stock	smallint	NULL   --- Modificar la condicion de NULLable
  )

CREATE TABLE detalle 
  (
   codDetalle		int		NOT NULL,
   numPed		int		NOT NULL,
   codProd  		int		NOT NULL,
   cant		int 		NOT NULL,
   precioTot		float		NULL
  )


----De Guia 2 --------


---------------- INSERT de dos clientes -----------------
Select * from cliente
INSERT
   INTO cliente
   (codcli,ape, nom, dir)
   VALUES (1, 'LOPEZ', 'JOSE MARIA', 'Gral. Paz 3124')


INSERT
   INTO cliente
   (codcli,ape, nom, dir, codPost)
   VALUES (2, 'GERVASOLI ', 'MAURO', ' San Luis 472', NULL)


---------------- INSERT de dos proveeedores -----------------
Select * from proveed
INSERT 
   INTO proveed
   (razonsoc, dir)
   VALUES ('FLUKE INGENIERIA', 'RUTA 9 Km. 80')

INSERT 
   INTO proveed
   (razonsoc, dir)
   VALUES ('PVD PATCHES', 'Pinar de Rocha 1154')





----------------- Trabajamos con tablas Productos y Detalle -----------------

SELECT * FROm Productos
--DELETE Productos

INSERT INTO PRODUCTOS VALUES (10, 'Articulo 1', 50, 20)
INSERT INTO PRODUCTOS VALUES (20, 'Articulo 2', 70, 40)
INSERT INTO PRODUCTOS VALUES (30, 'Articulo 3', NULL, 40)




---------------------------------------------------------------------
-------------------1. Desarrollar el SP buscarPrecio -----------------
---------------------------------------------------------------------

DROP PROCEDURE buscarPrecio
GO
CREATE PROCEDURE buscarPrecio
   (
    @CodProd int,                  -- Parametro de entrada 
    @PrecUnit float  OUTPUT        -- Parametro de salida
   )	                             
   AS
      SELECT @PrecUnit = PrecUnit
         FROM Productos
         WHERE CodProd = @Codprod
      RETURN



---------------------------------------------------------------------
----------2. Testear el SP buscarPrecio desde un batch---------------
---------------------------------------------------------------------

/*


*/

SELECT * from productos
--ELETE Productos

DECLARE  @PrecioObtenido FLOAT
EXECUTE buscarPrecio 10, @PrecioObtenido OUTPUT
SELECT 'El valor obtenido es ' + CONVERT(VARCHAR, @PrecioObtenido)


--Teniendo en cuenta los datos insertados en la  tabla Producto, 
--para el producto 10 debemos obtener el precio 50:



-----------------------------------------------------------------------
----------3. Desarrollar el Procedure principal (insertarDetalle) -----
-----------------------------------------------------------------------


--DROp PROCEDURE insertarDetalle
GO
CREATE PROCEDURE insertarDetalle
   (
    @CodDetalle Int,    -- IN
    @NumPed Int,	    -- IN
    @CodProd int,       -- IN
    @Cant  Int          -- IN
   )                        
   AS
      ------ Identica la invocacion que haciamos desde el batch -----------
      DECLARE  @PrecioObtenido FLOAT   --Parametro OUT del inner procedure
      EXECUTE buscarprecio @CodProd, @PrecioObtenido OUTPUT
      
      ---------- Aca ya tenemos el precio del producto ---------
      
      INSERT Detalle Values(@CodDetalle, @NumPed, @CodProd, @Cant, 
                            @Cant * @PrecioObtenido)
                            
      If @@RowCount = 1
         PRINT 'Se inserto una fila'
      RETURN



-----------------------------------------------------------------------
----------4. Testear el Procedure principal (insertarDetalle) -----
-----------------------------------------------------------------------

Select * from Detalle
Select precUnit from productos where codprod = 10

insertarDetalle 1540, 120, 56, 2

--insertarDetalle @CodDetalle=1540, 120, 10, 2

--Delete Detalle where codprod = 56
--DELETE Detalle


----------------------------------------------------------------------------
------------------------------ E J E R C I C I O   4 ----------------------
----------------------------------------------------------------------------
GO
------------- Version 2 -------------
--DROP PROCEDURE buscarPrecioV2
CREATE PROCEDURE buscarPrecioV2
   (
    @CodProd int                  -- IN
   )	                             
   AS
      ------------- Verificar que el producto exista ----------
      IF EXISTS (SELECT *
                    FROM Productos
                    WHERE CodProd = @Codprod)
         BEGIN
            PRINT 'El producto existe'
            RETURN 0
         END   
      -- END IF              


------------ Testeo ------------------
buscarPrecioV2 56     

      

------------- Version 3 -------------
GO
CREATE PROCEDURE buscarPrecioV3
   (
    @CodProd int                  -- IN
   )	                             
   AS
      ------------- Verificar que el producto exista ----------
      IF NOT EXISTS (SELECT *
                    FROM Productos
                    WHERE CodProd = @Codprod)
      
         RETURN 70 -- Va a indicar al SP invocante que el producto no existe
      -- END IF   

      RETURN 0


------------ Testeo ------------------
--buscarPrecioV3 56     



------------- Version 4 -------------
GO
CREATE PROCEDURE buscarPrecioV4
   (
    @CodProd int                  -- IN
   )	                             
   AS
      ------------- Verificar que el producto exista ----------
      IF EXISTS (SELECT *
                    FROM Productos
                    WHERE CodProd = @Codprod)
                    
         BEGIN           
                    
            PRINT 'El producto existe'
         
            IF EXISTS (SELECT *
                          FROM Productos
                          WHERE CodProd = @Codprod AND
                                precUnit IS NOT NULL )
               BEGIN          
                   --Esta todo bien       
                   PRINT 'El producto posee precio'
                   RETURN 0
               END    
               
               
            ELSE  
               BEGIN 
                  PRINT 'El producto no posee precio'                     
                  RETURN 71 -- Va a indicar al SP invocante que el produuto no tiene precio definido                         
               END   
            -- END IF                    
          
          END
      ELSE
         BEGIN
            PRINT 'El producto no existe'
            RETURN 70 -- Va a indicar al SP invocante que el produuto no existe   
         END 
      -- END IF   

    


Select * from productos
-- 10 y 20 existen
---Inserto uno sin precio




------------ Testeo con un prodcuto inexistente ------------------
buscarPrecioV4 67   


------------ Testeo con un prodcuto sin precio ------------------
buscarPrecioV4 30 


---------- Me falta recuperar el precio -------------------

------------- Version 5 -------------
GO
CREATE PROCEDURE buscarPrecioV5
   (
    @CodProd int,                  -- IN
    @PrecUnit float  OUTPUT        -- OUT
   )	                             
   AS
      ------------- Verificar que el producto exista ----------
      IF EXISTS (SELECT *
                    FROM Productos
                    WHERE CodProd = @Codprod)
                    
         BEGIN           
                    
            PRINT 'El producto existe'
         
            IF EXISTS (SELECT *
                          FROM Productos
                          WHERE CodProd = @Codprod AND
                                precUnit IS NOT NULL )
                                
               BEGIN                    
                  PRINT 'El producto posee precio'
               
                  SELECT @PrecUnit = PrecUnit
                     FROM Productos
                     WHERE CodProd = @Codprod
                     
                  RETURN 0   
                  
               END      
               
            ELSE  
               BEGIN 
                  PRINT 'El producto no posee precio'                     
                  RETURN 71 -- Va a indicar al SP invocante que el produuto no tiene precio definido                         
               END   
            -- END IF                    
          
          END
      ELSE
         BEGIN
            PRINT 'El producto no existe'
            RETURN 70 -- Va a indicar al SP invocante que el produuto no existe   
         END 
      -- END IF   






  
------------------- Otra version alternativa mas atada a T-SQL -----------
-------- Usa @@rowcount ---------------------------------
GO
CREATE PROCEDURE buscarPrecioV10
   (
    @CodProd int,                  -- Parametro de entrada 
    @PrecUnit float  OUTPUT        -- Parametro de salida
   )	                             
   AS
      SELECT @PrecUnit = PrecUnit
         FROM Productos
         WHERE CodProd = @Codprod
      
       IF @@RowCount = 0
          RETURN 70            -- No se encontro el producto       
       -- END IF
	   
	   IF @PrecUnit IS NULL
         RETURN 71            -- El producto existe pero su precio es NULL
       -- END IF  
      
       RETURN 0                -- El producto existe y su precio no es NULL    






---------------------------------------------------------------------
---------- Testear el SP buscarPreciov5 desde un batch---------------
---------------------------------------------------------------------
select * from productos

DECLARE  @PrecioObtenido FLOAT
EXECUTE buscarPreciov5 10, @PrecioObtenido OUTPUT
SELECT 'El valor obtenido es ' + CONVERT(VARCHAR, @PrecioObtenido)

--50

---------------------------------------------------------------------
---------- Modificar insertarDetalle ---------------
---------------------------------------------------------------------
GO
CREATE PROCEDURE insertarDetallev2
   (
    @CodDetalle Int,    -- IN
    @NumPed Int,	    -- IN
    @CodProd int,       -- IN
    @Cant  Int          -- IN
   )                        
   AS
      ------ Identica la invocacion que haciamos desde el batch -----------
      DECLARE  @PrecioObtenido FLOAT   --Parametro OUT del inner procedure
      DECLARE @StatusRetorno Int   --Status de retorno del inner procedure

      
      EXECUTE @StatusRetorno = buscarprecioV5 @CodProd, @PrecioObtenido OUTPUT
      PRINT 'El status de retorno vale ' + CONVERT (VARCHAR, @StatusRetorno)
      PRINT 'El precio obtenido es ' + CONVERT (VARCHAR, @PrecioObtenido)
      
      RETURN



------------ Testeo para un producto inexistente ------------------

insertarDetallev2 1540, 120, 67, 2

------------ Testeo para un producto sin precio------------------
Select * from productos
insertarDetallev2 1540, 120, 30, 2
  



---------------------------------------------------------------------
---------- Modificar insertarDetalle ---------------
---------------------------------------------------------------------
GO
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
      DECLARE @StatusRetorno Int   --Status de retorno del inner procedure

      
      EXECUTE @StatusRetorno = buscarprecioV5 @CodProd, @PrecioObtenido OUTPUT
      
      IF @StatusRetorno != 0
         BEGIN
            IF @StatusRetorno = 70
               BEGIN
                  PRINT 'insertarDetallev3: El producto no existe'
                  RETURN
               END   
            ELSE
               IF @StatusRetorno = 71
                  BEGIN
                     PRINT 'insertarDetallev3:El producto no posee precio'
                     RETURN
                  END   
               -- END IF   
            -- END IF   
          END  
       -- END IF   
      
      
     
       BEGIN TRY
          INSERT Detalle Values(@CodDetalle, @NumPed, @CodProd, @Cant, 
                                @Cant * @PrecioObtenido)
          PRINT 'Se insert� una fila'
          RETURN 0
       END TRY

       BEGIN CATCH
          EXECUTE usp_GetErrorInfo
          RETURN 72
       END CATCH   

       RETURN







SELECT * from productos

------------ Testeo para un producto inexistente ------------------

insertarDetallev4 1540, 120, 56, 2

------------ Testeo para un producto sin precio------------------

insertarDetallev4 1540, 120, 30, 2
  
------------ Testeo para un producto v�lido------------------

insertarDetallev4 1540, 120, 10, 2

delete Detalle   
SELECT * FROM detalle


 


GO
CREATE PROCEDURE usp_GetErrorInfo
   AS
      SELECT ERROR_NUMBER() AS ErrorNumber,
             ERROR_MESSAGE() AS ErrorMessage,
             ERROR_SEVERITY() AS ErrorSeverity,
             ERROR_STATE() AS ErrorState,
             ERROR_PROCEDURE() AS ErrorProcedure,
             ERROR_LINE() AS ErrorLine


