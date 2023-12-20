-- Ejemplo 1: Mostrar una columna de una tabla, ambos, variables.

-- En BD covid19

DECLARE @cadena VARCHAR(100)
DECLARE @nomTabla VARCHAR(30) = 'importacion.localidad'
DECLARE @nomColumna VARCHAR(60) = 'nombre'
SET @cadena = 'SELECT ' + @nomColumna + ' FROM ' + @nomTabla;
EXEC (@cadena)


-- En pubs
select * from authors
DECLARE @cadena VARCHAR(100)
DECLARE @nomTabla VARCHAR(30) = 'authors'
DECLARE @nomColumna VARCHAR(60) = 'zip' -- zip
SET @cadena = 'SELECT ' + @nomColumna + ' FROM ' + @nomTabla;
EXEC (@cadena)