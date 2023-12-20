--1. Describa un SP T-SQL (obtenerPrecio) que proporcione el 
--precio de cualquier publicación para la cual se proporcione 
--su codigo. Testee su funcionamiento con un codigo de publicacion, 
--por ejemplo, PS1372
CREATE PROCEDURE obtenerPrecio
  (
  @prmtitle_id VARCHAR(6),
  @prmPrecio FLOAT OUTPUT
)
AS
SELECT @prmPrecio = (
    SELECT price
  FROM titles
  WHERE title_id = @prmtitle_id
  )

--SOLO TSQL
DECLARE @salida FLOAT
EXECUTE obtenerPrecio 'PS1372', @salida OUTPUT
--11.95
PRINT 'El precio retornado es ' + CONVERT(VARCHAR,@salida)

--En postgres 
CREATE OR REPLACE FUNCTION obtenerPrecio2
(
      IN prmtitle_id VARCHAR
(6)
    --IN prmAddress VARCHAR(40)
)
RETURNS NUMERIC--diez digitos enteros y 2 decimales
--RETURNS setof numeric(10,2)
LANGUAGE plpgsql
 
AS

$$
DECLARE precio Numeric;
BEGIN
  --RETURN QUERY
  SELECT price
  INTO precio
  FROM titles
  WHERE title_id = prmtitle_id;

  return precio;
END
$$;

--hay que hacerlo dentro de una función al print
DECLARE precioRetorno numeric;
precioRetorno :=
(SELEECT obtenerPrecio2
('PS1372'));
RAISE NOTICE 'El precio es de %', precioRetorno::VARCHAR
(10);

