------------------------------------------- COMIENZO SOLUCION -----------------------------------
Use pubs

/*
En el modelo de datos de Pubs se necesitan eliminar los autores (y sus publicaciones) 
cuando todas sus publicaciones hayan vendido 
menos de 25 ejemplares en el per�odo comprendido entre el 1/1/1993 y el 31/12/1994.

Utilice T-SQL para la resoluci�n.

Se debe tener en cuenta que:

a. El c�lculo de ventas de debe realizar a partir de la columna qty en la tabla Sales.
b. Son excluidos de la evaluaci�n los autores que son coautores (cuandola publicaci�n tiene varios autores).
c.  Son excluidos de la evaluaci�n los autores que no poseen publicaciones editadas.
d. Son excluidos de la evaluaci�n los autores que no han vendido ejemplares en el per�odo analizado. 
*/


/*
------------------------------------------------------------------------
--b. Son excluidos de la evaluaci�n los autores que son coautores (cuando la publicaci�n tiene varios autores).
------------------------------------------------------------------------

titleAuthor
title_id     au_id      royaltyper
1             10         40
1             20         60
2             30         100



*/



SELECT COUNT(*)
   FROM Authors
-- 23

   
----------------------------------------------------------------------------------
------------------------- Excluir los autores que nunca publicaron -------------
----------------------------------------------------------------------------------


SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE A.au_id IN (SELECT au_id 
                        FROM TitleAuthor)  -- relaci�n unaria de autores que publicaron

                        
-- o bien

SELECT COUNT(*)
   FROM authors A
   WHERE A.au_id IN (SELECT au_id 
                        FROM TitleAuthor) 
--Son 19 los querealmente publicaron

--------------------------------------------------------------
--- Corroboramos los excluidos por no haber publicado ---------
--------------------------------------------------------------

SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE A.au_id NOT IN (SELECT au_id 
                            FROM TitleAuthor) 
                        

-- Son los que aparecen listados en el Cuestionario 2                        
                       
 -- 19 (descarte 4)
 
 /*
 au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
527-72-3246 Morningstar          Greene
893-72-1158 Heather              McBadden
341-22-1782 Meander              Smith
724-08-9931 Dirk                 Stringer
*/
 
 
----------------------------------------------------------------------------------------------------
---------------- Excluir los autores que no poseen ventas entre 1/1/1993 y 31/12/1994-------------
----------------------------------------------------------------------------------------------------


SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE EXISTS 
               (
                SELECT *
                   FROM sales INNER JOIN Titles
                                 ON sales.title_id = titles.title_id
                              INNER JOIN titleauthor TA
                                 ON titles.title_id = TA.title_id
                   WHERE YEAR(ord_date) IN (1993, 1994) AND
                         TA.au_id = A.au_id 
               )
               
               
                         
 -- Obtengo 15
 
 
 -- Los que no tienen ventas son:
 
SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE NOT EXISTS 
                   (
                    SELECT *
                       FROM sales INNER JOIN Titles
                                     ON sales.title_id = titles.title_id
                                  INNER JOIN titleauthor TA
                                     ON titles.title_id = TA.title_id
                       WHERE YEAR(ord_date) IN (1993, 1994) AND
                             TA.au_id = A.au_id 
                   )     
                   
                   
/*
au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
                                                        
341-22-1782 Meander              Smith
472-27-2349 Burt                 Gringlesby  
527-72-3246 Morningstar          Greene
648-92-1872 Reginald             Blotchet-Halls
672-71-3249 Akiko                Yokomoto
724-08-9931 Dirk                 Stringer
807-91-6654 Sylvia               Panteley
893-72-1158 Heather              McBadden
*/                        
 
----------------------------------------------------------------------------------
------------------------- Excluir los autores que son coautores -------------
----------------------------------------------------------------------------------
 
 
 
SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE NOT EXISTS (
                     SELECT *
                        FROM TitleAuthor TA
                        WHERE TA.au_id = A.au_id AND 
                              royaltyper <> 100
                    ) 


-- Lo mismo pero con IN
SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE A.au_id NOT IN (
                         SELECT TA.au_id
                            FROM TitleAuthor TA
                            WHERE royaltyper <> 100
                        ) 





/*
Permanecen 11
au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
172-32-1176 Johnson              White
238-95-7766 Cheryl               Carson
274-80-9391 Dean                 Straight
341-22-1782 Meander              Smith
486-29-1786 Charlene             Locksley
527-72-3246 Morningstar          Greene
648-92-1872 Reginald             Blotchet-Halls
712-45-1867 Innes                del Castillo
724-08-9931 Dirk                 Stringer
807-91-6654 Sylvia               Panteley
893-72-1158 Heather              McBadden
*/
                        

--Cuales exclu�?

SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE EXISTS (
                 SELECT *
                    FROM TitleAuthor TA
                    WHERE TA.au_id = A.au_id AND 
                          royaltyper <> 100
                ) 


/*
au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
213-46-8915 Marjorie             Green
267-41-2394 Michael              O'Leary
409-56-7008 Abraham              Bennet
427-17-2319 Ann                  Dull
472-27-2349 Burt                 Gringlesby
672-71-3249 Akiko                Yokomoto
722-51-5454 Michel               DeFrance
724-80-9391 Stearns              MacFeather
756-30-7391 Livia                Karsen
846-92-7186 Sheryl               Hunter
899-46-2035 Anne                 Ringer
998-72-3567 Albert               Ringer


*/

-----------------------------------------------------------------------------------------------------
--------Excluir los autores que tengan (al menos una) publicaci�n que vendi� 
--    mas de 25 unidades -------------
-----------------------------------------------------------------------------------------------------

SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE 25 <= ANY (
                    SELECT SUM(qty)  
                       FROM sales S INNER JOIN Titles T
                                       ON S.title_id = T.title_id
                                    INNER JOIN titleauthor TA
                                       ON T.title_id = TA.title_id
                       WHERE YEAR(ord_date) IN (1993, 1994) AND
                             TA.au_id = A.au_id
                       GROUP BY S.title_id  --Necesito una suma por cada publicaci�n
                   ) 


                            
/*
Los excluidos son:

au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
213-46-8915 Marjorie             Green
238-95-7766 Cheryl               Carson
267-41-2394 Michael              O'Leary
427-17-2319 Ann                  Dull
486-29-1786 Charlene             Locksley
722-51-5454 Michel               DeFrance
724-80-9391 Stearns              MacFeather
846-92-7186 Sheryl               Hunter
899-46-2035 Anne                 Ringer
998-72-3567 Albert               Ringer
*/

--- Los candidatos a eliminar son:

SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE 25 > ALL (
                   SELECT SUM(qty)  
                      FROM sales S INNER JOIN Titles T
                                      ON S.title_id = T.title_id
                                   INNER JOIN titleauthor TA
                                      ON T.title_id = TA.title_id
                      WHERE YEAR(ord_date) IN (1993, 1994) AND
                            TA.au_id = A.au_id
                      GROUP BY S.title_id
                  ) 


/*
au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
172-32-1176 Johnson              White
274-80-9391 Dean                 Straight
341-22-1782 Meander              Smith
409-56-7008 Abraham              Bennet
472-27-2349 Burt                 Gringlesby
527-72-3246 Morningstar          Greene
648-92-1872 Reginald             Blotchet-Halls
672-71-3249 Akiko                Yokomoto
712-45-1867 Innes                del Castillo
724-08-9931 Dirk                 Stringer
756-30-7391 Livia                Karsen
807-91-6654 Sylvia               Panteley
893-72-1158 Heather              McBadden
*/

----------------------------------------------------------------------------------
-------------------------- Poniendo todas las condiciones juntas ------------------
----------------------------------------------------------------------------------


SELECT A.au_id, au_fname, au_lname                   -- La salida del SELECT es siempre la misma
   FROM authors A
   WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                        FROM TitleAuthor) AND
                        
         EXISTS                                       -- Que haya vendido en 1993/1994
                SELECT *
                   FROM sales INNER JOIN Titles
                                 ON sales.title_id = titles.title_id
                              INNER JOIN titleauthor TA
                                 ON titles.title_id = TA.title_id
                   WHERE YEAR(ord_date) IN (1993, 1994) AND
                         TA.au_id = A.au_id 
               ) AND        
         NOT EXISTS (                                   -- No sean coautores
                     SELECT *
                        FROM TitleAuthor TA
                        WHERE TA.au_id = A.au_id AND 
                              royaltyper <> 100
                    ) AND
         
         25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                   SELECT SUM(qty)  
                      FROM sales S INNER JOIN Titles T
                                      ON S.title_id = T.title_id
                                   INNER JOIN titleauthor TA
                                      ON T.title_id = TA.title_id
                      WHERE YEAR(ord_date) IN (1993, 1994) AND
                            TA.au_id = A.au_id
                      GROUP BY S.title_id
                  )                 



-------------------- Tengo nombres de tablas repetidos -------------
----------------------- Ajusto los ALIAS ---------------------------




SELECT A.au_id, au_fname, au_lname
   FROM authors A
   WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                        FROM TitleAuthor) AND
                        
         EXISTS                                       -- Que haya vendido en 1993/1994
               (
                SELECT *
                   FROM sales INNER JOIN Titles
                                 ON sales.title_id = titles.title_id
                              INNER JOIN titleauthor TA2
                                 ON titles.title_id = TA2.title_id
                   WHERE YEAR(ord_date) IN (1993, 1994) AND
                         TA2.au_id = A.au_id 
               ) AND        
         NOT EXISTS (                                   -- No sean coautores
                     SELECT *
                        FROM TitleAuthor TA3
                        WHERE TA3.au_id = A.au_id AND 
                              royaltyper <> 100
                    ) AND
         
         25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                   SELECT SUM(qty)  
                      FROM sales S INNER JOIN Titles T
                                      ON S.title_id = T.title_id
                                   INNER JOIN titleauthor TA4
                                      ON T.title_id = TA4.title_id
                      WHERE YEAR(ord_date) IN (1993, 1994) AND
                            TA4.au_id = A.au_id
                      GROUP BY S.title_id
                  )   



/*
Los que tengo que eliminar son:

au_id       au_fname             au_lname
----------- -------------------- ----------------------------------------
172-32-1176 Johnson              White
274-80-9391 Dean                 Straight
712-45-1867 Innes                del Castillo

*/


------------------------------------------------------------------------------------
-------------------------------- P r o c e d u r e s --------------------------------
------------------------------------------------------------------------------------

/*
Eliminaci�n de Publicaciones y Autores

Para la eliminaci�n, implemente los procedimientos almacenados 
EliminarPublicacion y EliminarAutor. 



CREATE PROC EliminarPublicacion
   @title_id varchar(6)
(este tiene que eliminar todas las dependencias...) 

CREATE PROC EliminarAutor
   @au_id varchar(12)


EliminarPublicaci�n debe encargarse de eliminar las entradas en todas las tablas 
dependientes antes de proceder a eliminar la publicaci�n.

Ambos procedimientos deben validar posibles errores usando bloques try/catch y 
retornar:
Un c�digo de status 0 si no se produjeron errores.
El c�digo de status igual al valor de @@Error si se produjeron errores.

*/

GO
CREATE PROCEDURE usp_GetErrorInfo
   AS
      SELECT ERROR_NUMBER() AS ErrorNumber,
             ERROR_MESSAGE() AS ErrorMessage,
             ERROR_SEVERITY() AS ErrorSeverity,
             ERROR_STATE() AS ErrorState,
             ERROR_PROCEDURE() AS ErrorProcedure,
             ERROR_LINE() AS ErrorLine

GO

ALTER PROC EliminarPublicacion
   @title_id varchar(6)
   AS
      BEGIN TRY
         DELETE Sales where title_id = @title_id 
         DELETE Roysched where title_id = @title_id 
         DELETE TitleAuthor where title_id = @title_id 
         DELETE Titles where title_id = @title_id 
         RETURN 0
      END TRY

      BEGIN CATCH
         EXECUTE usp_GetErrorInfo
         RETURN @@Error
      END CATCH  


GO
ALTER PROC EliminarAutor
   @au_id varchar(12)
   AS
      BEGIN TRY
         DELETE Authors where au_id = @au_id      
         RETURN 0
      END TRY

      BEGIN CATCH
         EXECUTE usp_GetErrorInfo
         RETURN @@Error
      END CATCH   



------------------------------------------------------------------------------------
--------------------------- B a t c h     p r i n c i p a l v1------------------------
------------------------------------------------------------------------------------



DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname


      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

CLOSE curAutores
DEALLOCATE curAutores



------------------------------------------------------------------------------------
--------------------------- B a t c h     p r i n c i p a l v2------------------------
-- Cursor de Autores y de Publicaciones
------------------------------------------------------------------------------------


DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname

      ------------------------- Recorrer publicaciones -----------------------------
      
      DECLARE curPublicaciones CURSOR
         FOR SELECT Titles.title_id
                FROM titles INNER JOIN titleauthor
                               ON titles.title_id = titleauthor.title_id
                WHERE titleauthor.au_id = @au_id

      DECLARE @title_id varchar(6)
      OPEN curPublicaciones
      FETCH NEXT FROM curPublicaciones INTO @title_id

      WHILE @@FETCH_STATUS = 0
         BEGIN
            PRINT 'Procesando publicacion ' + @title_id
            
            FETCH NEXT FROM curPublicaciones INTO @title_id
            END
         -- END WHILE
         
         CLOSE curPublicaciones
         DEALLOCATE curPublicaciones

      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

CLOSE curAutores
DEALLOCATE curAutores




------------------------------------------------------------------------------------
--------------------------- B a t c h     p r i n c i p a l v3------------------------
-- Invocar procedure EliminarPublicacion
------------------------------------------------------------------------------------



DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname

      ------------------------- Recorrer publicaciones -----------------------------
      
      DECLARE curPublicaciones CURSOR
         FOR SELECT Titles.title_id
                FROM titles INNER JOIN titleauthor
                               ON titles.title_id = titleauthor.title_id
                            INNER JOIN Authors
                               ON titleauthor.au_id = authors.au_id
                WHERE Authors.au_id = @au_id

      DECLARE @title_id varchar(6)
      OPEN curPublicaciones
      FETCH NEXT FROM curPublicaciones INTO @title_id

      WHILE @@FETCH_STATUS = 0
         BEGIN
            PRINT 'Procesando publicacion ' + @title_id
            
            DECLARE @Retorno Int
            EXECUTE @Retorno = EliminarPublicacion @title_id 
            
            PRINT 'La eliminacion de publicaciones retorno ' + convert(varchar, @Retorno)
            IF @Retorno != 0 
               BEGIN
                  RAISERROR ('Error en eliminaci�n de publicaci�n o sus dependencias', 15, 0)
                  RETURN
               END
            -- END IF
            
            
            FETCH NEXT FROM curPublicaciones INTO @title_id
            END
         -- END WHILE
         
         CLOSE curPublicaciones
         DEALLOCATE curPublicaciones

      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

CLOSE curAutores
DEALLOCATE curAutores





------------------------------------------------------------------------------------
--------------------------- B a t c h     p r i n c i p a l v4------------------------
-- Invocar procedure EliminarAutor
------------------------------------------------------------------------------------



DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname

      ------------------------- Recorrer publicaciones -----------------------------
      
      DECLARE curPublicaciones CURSOR
         FOR SELECT Titles.title_id
                FROM titles INNER JOIN titleauthor
                               ON titles.title_id = titleauthor.title_id
                            INNER JOIN Authors
                               ON titleauthor.au_id = authors.au_id
                WHERE Authors.au_id = @au_id

      DECLARE @title_id varchar(6)
      OPEN curPublicaciones
      FETCH NEXT FROM curPublicaciones INTO @title_id

      WHILE @@FETCH_STATUS = 0
         BEGIN
            PRINT 'Procesando publicacion ' + @title_id
            
            DECLARE @Retorno Int
            EXECUTE @Retorno = EliminarPublicacion @title_id 
            PRINT 'La eliminacion de publicaciones retorno ' + convert(varchar, @Retorno)
            IF @Retorno != 0 
               BEGIN
                  RAISERROR ('Error en eliminaci�n de publicaci�n o sus dependencias', 15, 0)
                  RETURN
               END
            -- END IF
            
            
            FETCH NEXT FROM curPublicaciones INTO @title_id
            END
         -- END WHILE
         
         CLOSE curPublicaciones
         DEALLOCATE curPublicaciones
         
         EXECUTE @Retorno = EliminarAutor @au_id 
         PRINT 'La eliminacion del autor retorno ' + convert(varchar, @Retorno)
         IF @Retorno != 0 
            BEGIN
               RAISERROR ('Error en eliminaci�n de autor', 15, 0)
               RETURN
            END
         -- End If
         

      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

CLOSE curAutores
DEALLOCATE curAutores






------------------------------------------------------------------------------------
--------------------------- B a t c h     p r i n c i p a l v5------------------------
-- Transaccionar
------------------------------------------------------------------------------------


DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

BEGIN TRANSACTION
WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname

      ------------------------- Recorrer publicaciones -----------------------------
      
      DECLARE curPublicaciones CURSOR
         FOR SELECT Titles.title_id
                FROM titles INNER JOIN titleauthor
                               ON titles.title_id = titleauthor.title_id
                            INNER JOIN Authors
                               ON titleauthor.au_id = authors.au_id
                WHERE Authors.au_id = @au_id

      DECLARE @title_id varchar(6)
      OPEN curPublicaciones
      FETCH NEXT FROM curPublicaciones INTO @title_id

      WHILE @@FETCH_STATUS = 0
         BEGIN
            PRINT 'Procesando publicacion ' + @title_id
            
            DECLARE @Retorno Int
            EXECUTE @Retorno = EliminarPublicacion @title_id 
            PRINT 'La eliminacion de publicaciones retorno ' + convert(varchar, @Retorno)
            IF @Retorno != 0 
               BEGIN
                  RAISERROR ('Error en eliminaci�n de publicaci�n o sus dependencias', 15, 0)
                  ROLLBACK TRANSACTION  
                  RETURN 
               END
            -- END IF
            
            
            FETCH NEXT FROM curPublicaciones INTO @title_id
            END
         -- END WHILE
         
         CLOSE curPublicaciones
         DEALLOCATE curPublicaciones
         
         EXECUTE @Retorno = EliminarAutor @au_id 
         PRINT 'La eliminacion del autor retorno ' + convert(varchar, @Retorno)
         IF @Retorno != 0 
            BEGIN
               RAISERROR ('Error en eliminaci�n de autor', 15, 0)
               ROLLBACK TRANSACTION 
               RETURN 
            END
         -- End If

      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

COMMIT TRANSACTION
CLOSE curAutores
DEALLOCATE curAutores





----------------------------------------------------------------------------
----------------------- pre- requisitos para el trigger --------------------
----------------------------------------------------------------------------

CREATE TABLE Setup
   (
    Tabla varchar(40) NOT NULL,
    Ultimo Integer
   )

INSERT Setup VALUES ('AutoresBadSeller', 1)

DELETE setup
Select * from Setup


CREATE TABLE AutoresBadSeller
   (
    IDAutor SmallInt 		     NOT NULL,
    au_idViejo varchar(12),
    au_lname       varchar(40)       NOT NULL,
    au_fname       varchar(20)       NOT NULL,
    phone          char(12)              NULL,
    address        varchar(40)           NULL,
    city           varchar(20)           NULL,
    state          char(2)               NULL,
    zip            char(5)               NULL
   )



GO
CREATE PROC ObtenerID
   @NomTabla varchar(20)
   AS
      DECLARE @Ultimo Int
      BEGIN TRY
         SELECT @Ultimo = Ultimo FROM Setup WHERE Tabla = @NomTabla
         UPDATE Setup SET Ultimo = @Ultimo +1
      END TRY
      
      BEGIN CATCH 
         EXECUTE usp_GetErrorInfo
         RETURN -100 --Error en recuperacion de UltimoID (primer valor de retorno utilizable
                     --Microsoft reserva 0 y -1 a -99
      END CATCH  

      RETURN @Ultimo


------------------------------------------------------------------------------
---------------------------------- Trigger v1 ---------------------------------
-- Recupero UltimoID
------------------------------------------------------------------------------
GO

CREATE TRIGGER InsertarBadSeller
   ON Authors
   AFTER DELETE
   AS
      DECLARE @Ultimo Integer
      EXECUTE @Ultimo = ObtenerID 'AutoresBadSeller'
      
      

------------------------------------------------------------------------------
---------------------------------- Trigger v2 ---------------------------------
-- Recupero "OLD"
------------------------------------------------------------------------------
GO
ALTER TRIGGER InsertarBadSeller
   ON Authors
   AFTER DELETE
   AS
      DECLARE @Ultimo Integer
      DECLARE @au_idViejo varchar(12), @au_lname varchar(40), @au_fname varchar(20)
       
      EXECUTE @Ultimo = ObtenerID 'AutoresBadSeller'
     
      IF @Ultimo != -100 --Error en recuperacion de UltimoID
         BEGIN
            SELECT @au_idViejo = au_id, 
                   @au_fname = au_fname, 
                   @au_lname = au_lname
               FROM DELETED

         END   
      -- END IF       



------------------------------------------------------------------------------
---------------------------------- Trigger v3 ---------------------------------
-- Manejo de errores
------------------------------------------------------------------------------
GO
ALTER TRIGGER InsertarBadSeller
   ON Authors
   AFTER DELETE
   AS
      DECLARE @Ultimo Integer
      DECLARE @au_idViejo varchar(12), @au_lname varchar(40), @au_fname varchar(20)
       
      EXECUTE @Ultimo = ObtenerID 'AutoresBadSeller'
     
      IF @Ultimo != -100 --Error en recuperacion de UltimoID
         BEGIN
            SELECT @au_idViejo = au_id, @au_fname = au_fname, @au_lname = au_lname
               FROM DELETED
         END      
      ELSE
         BEGIN
            RAISERROR ('Error en recuperacion de Ultimo ID', 15, 0)
            ROLLBACK TRANSACTION   
            RETURN         
         END   
      -- END IF      





------------------------------------------------------------------------------
---------------------------------- Trigger v4 ---------------------------------
--Insert con Try/Catch
------------------------------------------------------------------------------
GO
CREATE TRIGGER InsertarBadSeller
   ON Authors
   AFTER DELETE
   AS
      DECLARE @Ultimo Integer
      DECLARE @au_idViejo varchar(12), @au_lname varchar(40), @au_fname varchar(20)
       
      EXECUTE @Ultimo = ObtenerID 'AutoresBadSeller'
     
      IF @Ultimo != -100 --Error en recuperacion de UltimoID
         BEGIN
            SELECT @au_idViejo = au_id, @au_fname = au_fname, @au_lname = au_lname
               FROM DELETED 
               
            ----------------------------------------- INSERT ---------------------               
            BEGIN TRY
               INSERT AutoresBadSeller 
                         (IDAutor,    au_idViejo,  au_fname,  au_lname) 
                  VALUES (@Ultimo, @au_idViejo, @au_fname, @au_lname)
            END TRY
            
            BEGIN CATCH
               EXECUTE usp_GetErrorInfo
               ROLLBACK TRANSACTION   
               RETURN
            END CATCH       
               
         END      
      ELSE
         BEGIN
            RAISERROR ('Error en recuperacion de Ultimo ID', 15, 0)
            ROLLBACK TRANSACTION   
            RETURN         
         END   
      -- END IF      

RETURN




---------------------- Descomento los DELETEs -----------------------
---------------------- Batch a correr ----------------


DECLARE curAutores CURSOR
   FOR SELECT A.au_id, A.au_fname, A.au_lname
          FROM authors A
          WHERE A.au_id IN (SELECT au_id                     -- Que haya publicado
                               FROM TitleAuthor) AND
                        
                EXISTS                                       -- Que posea ventas en esos a�os
                      (
                       SELECT *
                          FROM sales INNER JOIN Titles
                                        ON sales.title_id = titles.title_id
                                     INNER JOIN titleauthor TA2
                                        ON titles.title_id = TA2.title_id
                          WHERE YEAR(ord_date) IN (1993, 1994) AND
                                TA2.au_id = A.au_id 
                      ) AND        
                NOT EXISTS (                                   -- No sean coautores
                            SELECT *
                               FROM TitleAuthor TA3
                               WHERE TA3.au_id = A.au_id AND 
                                     royaltyper <> 100
                           ) AND
         
                25 > ALL (                                              -- Todas sus publicaciones hayan vendido menos de 25  ejemplares
                          SELECT SUM(qty)  
                             FROM sales S INNER JOIN Titles T
                                             ON S.title_id = T.title_id
                                          INNER JOIN titleauthor TA4
                                             ON T.title_id = TA4.title_id
                             WHERE YEAR(ord_date) IN (1993, 1994) AND
                                   TA4.au_id = A.au_id
                             GROUP BY S.title_id
                         )   


DECLARE @au_id varchar(12), @au_fname varchar(20), @au_lname varchar(40)

OPEN curAutores

FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname

BEGIN TRANSACTION
WHILE @@FETCH_STATUS = 0
   BEGIN
      PRINT 'Procesando autor ' + @au_lname

      ------------------------- Recorrer publicaciones -----------------------------
      
      DECLARE curPublicaciones CURSOR
         FOR SELECT Titles.title_id
                FROM titles INNER JOIN titleauthor
                               ON titles.title_id = titleauthor.title_id
                            INNER JOIN Authors
                               ON titleauthor.au_id = authors.au_id
                WHERE Authors.au_id = @au_id

      DECLARE @title_id varchar(6)
      OPEN curPublicaciones
      FETCH NEXT FROM curPublicaciones INTO @title_id

      WHILE @@FETCH_STATUS = 0
         BEGIN
            PRINT 'Procesando publicacion ' + @title_id
            
            DECLARE @Retorno Int
            EXECUTE @Retorno = EliminarPublicacion @title_id 
            PRINT 'La eliminacion de publicaciones retorno ' + convert(varchar, @Retorno)
            IF @Retorno != 0 
               BEGIN
                  RAISERROR ('Error en eliminaci�n de publicaci�n o sus dependencias', 15, 0)
                  ROLLBACK TRANSACTION
                  RETURN
               END
            -- END IF
            
            
            FETCH NEXT FROM curPublicaciones INTO @title_id
            END
         -- END WHILE
         
         CLOSE curPublicaciones
         DEALLOCATE curPublicaciones
         
         EXECUTE @Retorno = EliminarAutor @au_id 
         PRINT 'La eliminacion del autor retorno ' + convert(varchar, @Retorno)
         IF @Retorno != 0 
            BEGIN
               RAISERROR ('Error en eliminaci�n de autor', 15, 0)
               ROLLBACK TRANSACTION
               RETURN
            END
         -- End If
         

      FETCH NEXT FROM curAutores INTO @au_id, @au_fname, @au_lname
   END

-- END WHILE

COMMIT TRANSACTION
CLOSE curAutores
DEALLOCATE curAutores




-------------------  Comprobacion --------------------

Select * from AutoresBadSeller



Select * from authors 
   WHERE au_id IN ('172-32-1176', '274-80-9391', '712-45-1867') 


------------------- FIN SOLUCION -----------------

