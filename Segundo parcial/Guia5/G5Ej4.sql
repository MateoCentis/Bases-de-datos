--Usando PL/pgSQL, obtenga un listado como el siguiente para 
--los autores que viven en ciudades donde se ubican las editoriales
-- que publican sus libros.
--EJ:
--El autor: Carson reside en la misma ciudad que la editorial que lo edita
--El autor: Bennet reside en la misma ciudad que la editorial que lo edita

CREATE OR REPLACE FUNCTION autoresEditorialesCiudades()
RETURNS setof VARCHAR
LANGUAGE plpgsql
AS
$$
--se quiere lista de autores (cumplen la condicion de vivir en misma ciudad que su publisher)
--Author (city) <- TitleAuthor -> titles -> Publishers (city)
DECLARE apellido varchar(30);
DECLARE salida varchar(255);
DECLARE cursorAutores CURSOR
  FOR (SELECT A.au_lname
        FROM authors A
        WHERE A.au_id IN (SELECT A1.au_id 
                          FROM authors A1 INNER JOIN TitleAuthor TA ON A1.au_id = TA.au_id 
                          INNER JOIN titles T ON T.title_id = TA.title_id
                          INNER JOIN publishers P ON P.pub_id = T.pub_id
                          WHERE A1.city = P.city)
        );
BEGIN
OPEN cursorAutores;
LOOP
FETCH NEXT FROM cursorAutores INTO apellido;
EXIT WHEN NOT FOUND;
salida := 'El autor: ' || apellido || ' reside en la misma ciudad que la editorial que lo edita';
RETURN NEXT salida;
END LOOP;
CLOSE cursorAutores;
END;
$$;

SELECT autoresEditorialesCiudades();
