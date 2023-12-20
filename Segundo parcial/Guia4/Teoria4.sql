-------------------------------------------------------------------------------------------
--2. Creación de procedures
--En TSQL: nos permite retornar un SELECT
CREATE PROCEDURE cambiarDomicilio
  (
  @prmAu_lname VARCHAR(40) = 'Lopez',--valor por omisión
  @prmAddress VARCHAR(40) OUTPUT
)
AS
UPDATE authors
    SET address = @prmAddress
    WHERE au_lname LIKE @prmAu_lname;
RETURN
--es opcional
-- setof del tipo y luego RETURN ..

--En postgres FUNCIONES
..
-- CREATE FUNCTION cambiarDomicilio
-- (
--   IN prmAu_lname VARCHAR(40) DEFAULT 'LOPEZ', --Valor por omisión 
--   IN prmAddress VARCHAR (40)
-- )
-- RETURNS void
-- LANGUAGE plppgsql
-- AS
-- $$
-- BEGIN
--   UPDATE authors
--     SET address = prmAddress
--     WHERE au_lname LIKE prmAu_lname;
--   RETURN;
-- END;
-- $$;

-------------------------------------------------------------------------------------------
--3. Declaración de variables locales
--TSQL: se pueden declarar en cualquier parte del procedimiento
--luego del AS. EJ:
--DECLARE @apellido VARCHAR(40)

--En postgres: se declaran antes del BEGIN pero despues 
--de $$ con la sentencia DECLARE apellido VARCHAR(40)
--Tambien es posible asignar un valor por omision con :=
-------------------------------------------------------------------------------------------
--4. Ejecución
--En TSQL: EXECUTE nombreSP [@nombreParametro =] valorParametro ...

--En postgres se usa SELECT funcion ('palabra','dsfa');
  
  --4.1 - especificación de parametros
    --Se pueden pasar los parametros por posicion o por el nombre
    --de cada uno y asignandole valor
-------------------------------------------------------------------------------------------
--5. Asignacion
  --TSQL: se asigna con SET o SELECT, EJ:
  --SET @apellido = @prmAu_lname;

  --Postgres:Se usa el operador :=, EJ:
  --apellido := prmAu_lname;
-------------------------------------------------------------------------------------------
--6. Mensajes informacionales
--TSQL: PRINT muestra mensajes en la pestañana mensajes y se concatena con + 
--DATA OPTUT es para la pestaña DATA OUTPUT que va hacia programas clientes
--Postgres: en vez de PRINT es RAISE NOTICE
--EJ: RAISE NOTICE 'El precio es %', price;
-------------------------------------------------------------------------------------------
--7. Estructuras condicionales
--TSQL:
-- IF <condicion>
--     BEGIN
--     --..
--     END
-- [ELSE]
--    BEGIN
--     ...
--    END

--Postgres:
--IF price < 100 THEN
  --RETURN 'El precio es menor a 100';
--ELSE 
--  RETURN 'El precio es mayor a 100';
--END iF;
-------------------------------------------------------------------------------------------
--8. CASE: se puede incluir en cualquier ocasión
-- SET @cad = 'El precio es ' + CASE
--                                WHEN @price < 10 THEN 'menor que 10 '
--                                WHEN @price = 10 THEN 'igual a 10'
--                                ELSE 'mayor a 10'
--                             END;
-- SELECT @cad;
-------------------------------------------------------------------------------------------
-- 9.Estructuras repetitivas
  --9.1 Loop
  --Postgres:
--   cont:=0;
-- <<loopContador>>
-- LOOP
--  EXIT loopContador WHEN cont = 5;
--  cont := cont + 1;
-- END LOOP;

  --9.2. While
  -- SQL
--   WHILE <condicion>
--  BEGIN
--  ...
--  END

-- Postgres
-- cont:=0;
-- WHILE cont < 5 LOOP
--  cont := cont + 1;
-- END LOOP;

-- 9.3. FOR
-- suma:=0;
-- FOR i IN 1..10 LOOP
--  suma := suma + i;
-- END LOOP;
-------------------------------------------------------------------------------------------
-- 10. Finalizar la ejecución de un batch
--con RETURN
-------------------------------------------------------------------------------------------
--11. Trabajar con stored procedures
  --11.1 Modificar SP
  --SQL: igual todo pero con ALTER en vez CREATE
  --Postgres CREATE OR REPLACE FUNCTION
  --11.2 - Eliminar SP
  --SQL: DROP PROCEDURE Nombre
  --Postgres: DROP FUNCTION nombre (parametros)
-------------------------------------------------------------------------------------------
--12. Recursos del sistema
  --12.1 Cant. filas afectas por sentencia
  --SQL: @@rowcount 

  --Postgres: GET DIAGNOSTICS cantFilas = ROW_COUNT;
  --12.2 Coumnas autoincrementales
  --SQL: @@identity proporciona luego de INSERT el valor insertado
  --por el DBMS para la misma
  
  --Postgres: RETURNING obtiene ultimo valor insertado, EJ:
--   INSERT
--    INTO proveed
--  (razonsoc, dir)
--  VALUES ('TCM Motors', 'Pinar de Rocha 8844')
--  RETURNING codprov INTO vUltimoId;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
---------------------------------------PARTE 2-------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--1.Queries que no almacenamos su valor
--Caso donde chequeamos con un EXISTS o algo tal que no nos importa el resultado

--2. Queries que almacenamos su resultado
  --2.1 queries que retornan un valor escalar
  --SQL:
  --SET @price = (SELECT price FROM titles WHERE title_id = @title_id)
  --Postgres 
  --price := (...)
  ---------------ANCHORED DECLARATIONS (POSTGRES)------------
  --asocia la declaración de una variable a un objeto de la base
  --estableciendo como tipo de dato al del objeto:
    --Scalar anchoring: define en base a una COLUMNA usando %TYPE
      --DECLARE price1 titles.price%TYPE;

  --2.2 Sentencias SELECT Single-row
  
--4. Salida de un stored prodecured en T-SQL 
--Existen 3 salidas para los Stored Procedures
  --4.1 - Return Value
  --es un valor entero que proporciona un código de status
    --4.1.1 - return value personalizado
    --Si tenemos un programa principal que invoca a otro secundario
    --el secundario puede indicarle al principal como resultó la op.
    --DECLARE @retorno integer
    --EXECUTE @retorno = spBuscarPublicaciones '1389'
  --4.2 - Parámetros OUTPUT
  --Si quremos retornar valores individuales, podemos usar este recurso
  --   ALTER PROCEDURE obtenerCantidadVendida
  --  (
  --  @pub_id CHAR(4),
  --  @cantidad INTEGER OUTPUT
  --  )
  --  AS
  --  SELECT @cantidad = SUM(qty)
  --  FROM sales S INNER JOIN titles T
  --  ON S.title_id = T.title_id
  --  WHERE T.pub_id = @pub_id
  --  RETURN 0 
  --Luego
  -- DECLARE @cantidad2 INTEGER
  -- EXECUTE obtenerCantidadVendida '1389', @cantidad2 OUTPUT
  -- SELECT CONVERT(VARCHAR, @cantidad2) 
  --4.3 - La salida de un SQL cualquiera sea la forma de la relación
  --T-SQL permite retornar directamente la salida de un SELECT. EJ:
  --   CREATE PROCEDURE ListarTitles
  -- AS
  --  SELECT * FROM titles 
  --EXECUTE ListarTitles

--5. Salida de una funcion Postgres
--tenemos que usar OUTPUT PARAMETERS
  --5.1 - retorno relacion unaria
  --Para retornar una relación unaria, EJEMPLOS: fechas de todos los reng. de vta
  --Por un lado definimos el tipo de retorno de la función
  --RETURNS setof FLOAT
  --por otro lado debemos utilizar la clausula RETURN QUERY
  --RETURN QUERY
  --si tengo un parametro de salida de un tipo debo ponerlo en el OUT
  --y luego afuera ponemos RETURN y el tipo de dato
  --5.4 - Return de projections
  --para esto hay que crear un nuevo tipo de dato 
  --que va a tener los tipos que queremos retornar dentro
  --Podemos crear una tupla artesanal, creamos un type y luego 
  --usamos ese type para definir un objeto de ese tipo y luego usamos esto
--6. Procedimientos almacenados e INSERT
--Se puede hacer INSERT de un execute
--T-SQL:
--INSERT tabla
--EXECUTE nombreSP
--8. Demarcación de transacción
--Iniciamos una transacción con BEGIN TRANSACTION
--Hay dos maneras de finalizarla:
--A. COMMIT TRANSACTION
--B. ROLLBACK TRANSACTION
  --8.1 - Implicancias de las transacciones

  --TRANSACTION LOG
  --Mientras se comienza una transacción esta va en el transaction log
  --y esto genera que esta tabla se bloquea hasta terminar la transacción.
  --Ya que primero se escribe en transaction log y luego en la memoria 
  --de la base de datos
  --Si la deshago no baja a disco, si le hago COMMIT si se baja a disco.
