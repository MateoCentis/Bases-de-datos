-- Implemente un batch T-SQL que actualice los precios de las publicaciones de la editorial
-- '0736'.
-- Por cada publicación de esta editorial, se desea incrementar en un 25% el precio de las
-- publicaciones que cuestan $10 o menos y decrementar también en un 25% las publicaciones
-- que cuestan más de $10.

DECLARE cursorPrecios CURSOR
  FOR 
  SELECT price
FROM titles
WHERE pub_id = '0736'

DECLARE @price FLOAT;

OPEN cursorPrecios

FETCH NEXT
	FROM cursorPrecios 
	INTO @price

WHILE @@fetch_status = 0
  BEGIN
  --while

  IF @price > 10
  BEGIN
    UPDATE titles
      SET price = @price - @price*0.25
      WHERE CURRENT OF cursorPrecios
  END   --END IF
  ELSE 
  BEGIN
    UPDATE titles
    SET price = @price + @price*0.25
    WHERE CURRENT OF cursorPrecios
  END
  --END ELSE
  FETCH NEXT
    FROM cursorPrecios
    INTO @price
END
--END while
CLOSE cursorPrecios
DEALLOCATE cursorPrecios
GO