------------------------------------------------------------------------------------------------
--1. Cursores y loops
--Sirven para trabajar sobre un lote de datos fila por fila
--debe ser usado como último recurso, es un conjunto de tuplas
--se usan cuando queremos recuperar informacion especifica de cada tupla
--EJEMPLO 1: obtener el maximo valor de price en la tabla titles
--algo que podria hacerse con SELECT MAX(price) FROM titles
--pero recorriendo fila a fila


--TSQL:
DECLARE curPrecios CURSOR 
  FOR --especifica el conjunto de datos que recuperamos para recorrer
    SELECT price--no hacer SELECT *, tiene que ser económico
FROM titles

DECLARE @price money,
        @priceMaximo FLOAT;

SET @priceMaximo = 0;

OPEN curPrecios--Abre el cursor, en este caso el DBMS ejecuta el SELECT

FETCH NEXT --FETCH se posiciona en una tupla, y NEXT en la proxima tupla
  FROM curPrecios --se especifica de que cursor 
  INTO @price--y en que variable lo vamos a meter

WHILE @@fetch_status = 0--mientras haya filas retorna igual a 0
  BEGIN
  IF @price IS NOT NULL
      IF @price > @priceMaximo
        SET @priceMaximo = @price;
  ---END IF; los end if no son necesarios porque hay una sola sentencia
  --END IF;

  FETCH NEXT
      FROM curPrecios
      INTO @price

END
--END WHILE
CLOSE curPrecios
--esto sirve para cerrar el cursor
DEALLOCATE curPrecios

SELECT @priceMaximo
--aqui creamos un cursor en un batch pero también puede usarse dentro de SP's

--EN POSTGRES:
CREATE FUNCTION test()
  RETURNS FLOAT
  LANGUAGE plpgsql
  AS
  $$
DECLARE 
    vPrice FLOAT;
    vPriceMaximo FLOAT;
    cursorPrice CURSOR FOR
SELECT price
FROM titles;
BEGIN 
    vPriceMaximo := 0;
OPEN cursorPrice;


LOOP
--para iterar sobre el cursor usamos LOOP
FETCH NEXT FROM cursorPrice
INTO vPrice;
      EXIT WHEN NOT FOUND;

IF vPrice IS NOT NULL THEN
IF vPrice > vPriceMaximo THEN
          vPriceMaximo := vPrice;
END IF;
END IF;
    
    END LOOP;

CLOSE cursorPrice;
RETURN vPriceMaximo;
END
  $$;

--se puede hacer lo mismo con FOR
--FOR TARGET(variable) IN QUERY(el select que recupera lo que va e) LOOP
------------------------------------------------------------------------------------------------
--2. Loops y estructu ras de datos para sentencias SINGLE-ROW
  --2.1 cursor que retorna un tupla completa
  --si recupera una fila completa podemos usar 
  DECLARE titleREc titles %ROWTYPE
  --EJemplo de uso:
  CREATE FUNCTION test702()
    RETURNS FLOAT
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
      tuplaTitles titles %ROWTYPE;
      vPriceMaximo FLOAT;

    BEGIN
      vPriceMaximo := 0;
      FOR tuplaTitles IN Select *
                          From Titles LOOP
        IF tuplaTitles.price IS NOT NULL THEN                       
          IF tuplaTitles.price > vPriceMaximo THEN
            vPriceMaximo := tuplaTitles.price;
          END IF;
        END IF;
END LOOP;
RETURN vPriceMaximo;
END
$$;
--cuando una funcion tiene más de un output se debe hacer un RECORD, que toma la forma del select(query)
------------------------------------------------------------------------------------------------
--3. Cursores for update
--recupero las filas con un cursor para modificar una o varias filas
--EJ:
SELECT title
FROM titles
WHERE title LIKE 'The gourmet%'
-- The Gourmet Microwave
Declare curTitles Cursor
 For
  Select title
--DECLARE CURSOR FOR QUERY FOR UPDATE (NO ES NECESARIO) 
From Titles
FOR
UPDATE

Declare @title VARCHAR(255)

OPEN curTitles
FETCH NEXT
 FROM curTitles
 INTO @title
WHILE @@fetch_status = 0
 BEGIN
  IF @title LIKE 'The gourmet%'
 UPDATE titles
 SET title = title + ' Second Edition'
 WHERE CURRENT OF curTitles--LUEGO EN EL WHERE VA CURRENT OF nombreCursor
  --END IF;

  FETCH NEXT
 FROM curTitles
 INTO @title

END
-- END WHILE
CLOSE curTitles
DEALLOCATE curTitles
------------------------------------------------------------------------------------------------
--4. SCROLL CURSORS
  --4.1 Operaciones FETCH - estos cursors te permiten hacer fetch al primer(FETCH FIRST) y último elemento (FETCH LAST)
  --DECLARE nomCursor CURSOR
    --SCROLL
      --FOR
        --SELECT price FROM titles
      
------------------------------------------------------------------------------------------------
