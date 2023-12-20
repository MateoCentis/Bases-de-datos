--En T-SQL, Obtenga un listado con las tres publicaciones 
--más caras de cada tipo (columna type).
--EJEMPLO:
---------------------
--2,99
--11,95
--19,99
--Publicaciones mas caras de tipo mod_cook
---------------------
--...
CREATE PROCEDURE mostrarPubsCarasTipo5
AS
DECLARE cursorTipos CURSOR
  FOR
    SELECT DISTINCT type
      FROM titles

DECLARE @tipo varchar(30),
		@precio FLOAT;

OPEN cursorTipos

FETCH NEXT 
  FROM cursorTipos
  INTO @tipo
WHILE @@fetch_status = 0 
  BEGIN
  PRINT '--------------------------'
  DECLARE cursorPrecios CURSOR
  FOR 
	SELECT TOP 3 price
		FROM titles 
		WHERE type = @tipo
		ORDER BY price DESC
		
  OPEN cursorPrecios
  
  FETCH NEXT 
	FROM cursorPrecios
	INTO @precio
	
  WHILE @@FETCH_STATUS = 0
	BEGIN
	  PRINT @precio
	  FETCH NEXT
	  FROM cursorPrecios
	  INTO @precio
	END -- while
  
  CLOSE cursorPrecios
  DEALLOCATE cursorPrecios
  
  PRINT 'Publicaciones más caras de tipo ' + @tipo
  
  FETCH NEXT 
  FROM cursorTipos
  INTO @tipo
END--WHILE

CLOSE cursorTipos
DEALLOCATE cursorTipos


EXECUTE mostrarPubsCarasTipo5
