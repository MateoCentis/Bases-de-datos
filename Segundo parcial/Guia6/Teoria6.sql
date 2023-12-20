--1 - ERRORES EN POSTGRES
--SQLSTATE define el status de la última operación realizada
--los que mas se evaluan son de la clase P0: 
--P0000 plpgsql_error
--P0001 raise_exception
--P0002 no_data_found
--P0003 too_many_rows

--2 - ERRORES EN TSQL

--2.1 - Tipos de errores
--Fatales: abortan el procedimiento y finalizan la conexión con el programa cliente
--No fatales: No abortan.

--2.2 - Componentes de un error
--Tienen 4 partes:
--Number: seria el equivalente a SQLSTATE
--Message: comunica la condicion de error
--Severity: un entero de 0 a 25 donde un número más alto implica mayor severidad
--State: refiere al contexto en el cual sucedió el error, es un valor entero entre 0 y 127. 
    --En los errores de aplicación se suele utilizar el 1

--3 - POSTGRES: LA CLAUSULA STRICT

--3.1 - No se encuentran datos
CREATE OR REPLACE FUNCTION test7B()
 RETURNS VOID
 LANGUAGE plpgsql
 AS
 DECLARE
 recTitles RECORD;

 BEGIN
  SELECT price, type INTO recTitles
    FROM titles
    WHERE title_id = 'VVU7777';
  IF recTitles.price IS NULL THEN
    RAISE NOTICE 'La publicación no tiene precio';
  END IF;

 END
--La publicación no existe pero la funcion no dispara ninguna excepción, asumiento un valor NULL

--3.2 - No es una sentencia SINGLE ROW
CREATE OR REPLACE FUNCTION test7C()
 RETURNS VOID
 LANGUAGE plpgsql
 AS
 DECLARE
 recTitles RECORD;

 BEGIN
   SELECT price, type INTO recTitles
    FROM titles;
 RAISE NOTICE 'El precio es %', recTitles.price;

 END 
--La consulta retorna más de una tupla, pero no se da ninguna excepcion

--Las dos consultas anteriores representan dos de las excepciones más comunes: NO_DATA_FOUND y TOO_MANY_ROWS.

--Para que Postgres las considere excepciones debemos agregar al SELECT INTO la clausula STRICT

CREATE OR REPLACE FUNCTION test7E()
 RETURNS VOID
 LANGUAGE plpgsql
 AS
 DECLARE
  recTitles RECORD;

 BEGIN
  SELECT price, type INTO STRICT recTitles
    FROM titles
    WHERE title_id = 'VVU7777';
  IF recTitles.price IS NULL THEN
    RAISE NOTICE 'La publicación no tiene precio';
  END IF;

 END

--Nos devuelve:
--ERROR: la consulta no regresó filas
--SQL state: P0002
--Context: funcion PgSQL en la linea 7 en sentencia SQL

CREATE OR REPLACE FUNCTION test7F()
 RETURNS VOID
 LANGUAGE plpgsql
 AS
 DECLARE
  recTitles RECORD;

 BEGIN
  SELECT price, type INTO STRICT recTitles
    FROM titles;
 RAISE NOTICE 'El precio es %', recTitles.price;

 END 

--Error: la consulta regresó más de una fila
--SQL state: P0003
--Context: funcion PgSQL en la linea 7 en sentencia SQL

--4 - CAPTURA DE EXCEPCIONES

--4.1 - Postgres
CREATE OR REPLACE FUNCTION test7G()
 RETURNS VOID
 LANGUAGE plpgsql
 AS
 DECLARE
  recTitles RECORD;

 BEGIN 
  NULL;
  --Otras operaciones--
  ----------Try/catch I-------------
  BEGIN--BEGIN define lo que sería el “try”. O sea, vamos a “intentar” ejecutar un código “peligroso”
       -- que sabemos a priori puede disparar una excepción. 

 SELECT price, type INTO STRICT recTitles
 FROM titles;
 RAISE NOTICE 'El precio es %', recTitles.price;

--EXCEPTION define lo que sería el “catch”
 EXCEPTION -- Try I
 WHEN NO_DATA_FOUND THEN--Discriminamos cada error con la clausula WHEN, tambien se puede usar el valor SQL_STATE
 RAISE NOTICE 'No se encontraron datos';
 RETURN;

 WHEN TOO_MANY_ROWS THEN
 RAISE NOTICE 'La sentencia SELECT retornó más de una fila';
 RETURN;

 WHEN OTHERS THEN --Catch ALL, OTHERS hace catch de cualquier otro error 
 RAISE NOTICE 'ERROR Others';
 RETURN;

 END; -- Try I
 RETURN;

 END 

--4.1.1. Ejemplo de uso de bloques Exception en una función compleja
 ----------------------------- Try/catch I ---------------------------
 BEGIN
 Operación peligrosa I

 -- Hacer fileopen de un archivo
 --Si tuvo éxito, continúo.
    ----------------------------- Try/catch II ---------------------------
    BEGIN
    Operacion peligrosa II

 -- Enviar un email al administrador
 --Si tuvo éxito, continúo.
 ----------------------------- Try/catch III ---------------------------
        BEGIN
        Operacion peligrosa III

        --Realizar un INSERT
        --Si tuvo éxito, continúo.

        EXCEPTION -- Try III
        WHEN OTHERS THEN
        --Mostrar información del error;
        END;
    
    EXCEPTION -- Try II
      WHEN OTHERS THEN
    --Mostrar información del error;
    END;
 EXCEPTION -- Try I
  WHEN OTHERS THEN
 ----Mostrar información del error;
 END;
 

--  4.1.2. Mostrar información del error
--Una forma es a trabés de RAISE NTOICE, dos variables auxiliares: SLERRM y SQLSTATE que proporcionan mensaje y codigo 
  --SQLSTATE correspondiente.
  --EJ:
  ----------------------------- Try/catch I ---------------------------
 BEGIN
  SELECT price, type INTO STRICT recTitles

    FROM titles
 
  RAISE NOTICE 'El precio es %', recTitles.price;

 EXCEPTION -- Try I

  WHEN TOO_MANY_ROWS THEN
    RAISE NOTICE 'ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
    RETURN;

  WHEN OTHERS THEN
    RAISE NOTICE 'ERROR SQLERRM: % SQLSTATE: %', SQLERRM, SQLSTATE;
    RETURN;
 END; -- Try I
 RETURN;

 END 

-- 4.2 - SQL SERVER
--TSQL proporciona una variable del sistema llamada @@error que es especifica por cada conexion al DBMS
--@@error contiene el número del error (number) producido por la última sentencia SQL ejecutada.
--Un valor 0 indica ausencia de error.
--Ej:
DECLARE @Error Integer

DROP TABLE noexiste
SET @Error = @@Error
IF @Error != 0
 PRINT 'Ocurrio el error ' + Convert(varchar,@Error);
-- END IF 
--Por cada sentencia debemos guardarnos el valor de @@error 

-- Cuando usamos @@Error, se usa GOTO para reducir la cantidad de codigo para implementar el manejo 
--   de errores. Supongamos que necesitamos ejecutar n operaciones "peligrosas". EJ:

DECLARE @Error Int
BEGIN TRANSACTION

INSERT Prueba Values (@Col2)
SET @Error = @@Error
IF @Error <> 0 GOTO lblError

INSERT Prueba Values (@Col2)
SET @Error = @@Error
IF @Error <> 0 GOTO lblError
...

COMMIT TRANSACTION
lblError:
 ROLLBACK TRANSACTION
 RETURN @Error 

--Por cada operaciones recuperamos el valor de @@Error pero si existe vamos a una seccion definida por un LABEL.

--Catch de errores usando try/catch
GO--El go no va 
CREATE PROCEDURE usp_GetErrorInfo

 AS
 SELECT ERROR_NUMBER() AS ErrorNumber,--TSQL proporciona cuatro funciones que permiten averiguar las caracteristicas 
        ERROR_MESSAGE() AS ErrorMessage,--de un error en un bloque try/catch. Estas son: ERROR_NUMBER(), ERROR_MESSAGE(),
        ERROR_SEVERITY() AS ErrorSeverity,--ERROR_SEVERITY(), y ERROR_STATE() que retornan las 4 partes del error.
        ERROR_STATE() AS ErrorState,--Si bien estan solo disponibles dentro del catch podemos incluirlas en un SP para no duplicar codigo

        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine
--Se define un bloque try y un bloque catch
BEGIN TRY
 DROP TABLE noexiste 
 -- ...otras sentencias  --Dentro del try ejecutamos las sentencias peligrosas
 COMMIT TRANSACTION
END TRY

BEGIN CATCH 
 EXECUTE usp_GetErrorInfo --Dentro del catch tratamos las excepciones
 ROLLBACK TRANSACTION
END CATCH 


--5 - ERRORES DE APLICACION
--Hasta ahora vimos errores del DMBS, sin embargo existen otros que son significativos para el dominio de nuestra aplicación.
--EJ: violación de una regla de negocio. 

--5.1 - Disparar errores de aplicación

--TSQL
--Se usa la funcion RAISEERROR. EJ: 
RAISERROR ('Codigo de producto inexistente',16,1)--El primer termino es el mensaje, el segundo es la severidad y el tercero un valor state
--Como con el raise notice se puede escificar placeholders cuyos valores son especificados como argumentos adicionales a la función, por ej:
RAISERROR('El producto %s no existe',16,1,@cod_prod)
--%d es utilizado para placeholders numéricos, mientras que %s para los de tipo string
--RAISERROR modifica el valor de @@Error

--POSTGRES
--Se usa RAICE EXCEPTION, EJ:
RAISE EXCEPTION 'El prpoducto % no existe', vCod_prod
                using ERRCODE = 'P0001'

--USING ERRCODE permite especificar el valor SQLSTATE, el valor por omision es P0001
--Existenlas class codes asignables a errores de aplicacion, por ejemplo las entre la I y la Z, EJ:
--podemos decir que 'El producto % no existe' posea un SQLSTATE 'I0001'

--6 - ERRORES Y TRANSACCIONES
--La ocurrencia de un error NO SIEMPRE deshace una transacción

--POSTGRES
--Podemos asegurarnos que todas las operaciones no se lleven a cabo 
--incluyendo las sentencias peligrosas en un bloque catch

CREATE OR REPLACE FUNCTION testE()
 RETURNS void
 LANGUAGE plpgsql
 AS
 BEGIN
    BEGIN
    INSERT INTO publishers values('9988', 'Editora Ingenieria Web',
                                  'Texas', 'TA', 'USA');
    UPDATE publishers
      SET pub_name = 'Editora Ingenieria Web 2000'
      WHERE pub_id = '9988';
    
    DROP TABLE noexiste;

    EXCEPTION
    WHEN SQLSTATE '42P01' THEN
      RAISE NOTICE 'ERROR SQLERRM: % SQLSTATE: %',
                   SQLERRM, SQLSTATE;
      RETURN;
    END;
    RETURN;
 END
BEGIN TRANSACTION;
 SELECT test();
COMMIT TRANSACTION; 

--TSQL
--En caso de error dentro de una transacción se realiza el catch de la excepción y un ROLLBACK manual, EJ:
BEGIN TRANSACTION

BEGIN TRY
 INSERT
  INTO publishers
  values('9988', 'Editora Ingenieria Web', 'Texas', 'TA','USA');

 UPDATE publishers
  SET pub_name = 'Editora Ingenieria Web 2000'
  WHERE pub_id = '9988';

 DROP TABLE noexiste;

 COMMIT TRANSACTION
END TRY

BEGIN CATCH
 EXECUTE usp_GetErrorInfo
 ROLLBACK TRANSACTION
END CATCH 
