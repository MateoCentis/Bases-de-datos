CREATE OR REPLACE FUNCTION G5Ej2()
RETURNS VOID 
LANGUAGE plpgsql
AS
$$
DECLARE tuplaTitles titles%ROWTYPE;
BEGIN
FOR tuplaTitles IN SELECT * 
              FROM titles 
                WHERE pub_id = '0736'
LOOP
	IF tuplaTitles.price > 10 THEN
	  UPDATE titles 
	  SET price = tuplaTitles.price - tuplaTitles.price*0.25
	  WHERE title_id = tuplaTitles.title_id;
	ELSE
	  UPDATE titles 
	  SET price = tuplaTitles.price + tuplaTitles.price*0.25
	  WHERE title_id = tuplaTitles.title_id;
	END IF;
END LOOP;
END--end func
$$

SELECT G5Ej2();