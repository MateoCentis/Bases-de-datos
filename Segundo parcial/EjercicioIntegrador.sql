-- En el modelo de datos de Pubs se necesitan eliminar los autores (y sus publicaciones) cuando
-- todas sus publicaciones hayan vendido menos de 25 ejemplares en el período
-- comprendido entre el 1/1/1993 y el 31/12/1994. 

-- Se debe tener en cuenta que:
-- a. El cálculo de ventas de debe realizar a partir de la columna qty en la tabla Sales.
-- b. Son excluidos de la evaluación los autores que son coautores. (si la publicacion tiene mas de un autor la salteo)
-- c. Son excluidos de la evaluación los autores que no poseen publicaciones editadas. (Si no tienen titles (titleAuthor no hace innerjoin))
-- d. Son excluidos de la evaluación los autores que no han vendido ejemplares en el período analizado.
--filtra para no llenar mucho el cursor

--[CAMINO]=Autor(au_id) INNER JOIN TitleAuthor(au_id) => titleAuthor(title_id) INNER JOIN title(title_id) => INNER JOIN sales (title_id) [qty < 25]
----------------------------------------------------------------------------------------------------------------
--------------------------------------------Mensajes de error---------------------------------------------------
----------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE usp_GetErrorInfo
 AS
 SELECT ERROR_NUMBER() AS ErrorNumber,--TSQL proporciona cuatro funciones que permiten averiguar las caracteristicas 
        ERROR_MESSAGE() AS ErrorMessage,--de un error en un bloque try/catch. Estas son: ERROR_NUMBER(), ERROR_MESSAGE(),
        ERROR_SEVERITY() AS ErrorSeverity,--ERROR_SEVERITY(), y ERROR_STATE() que retornan las 4 partes del error.
        ERROR_STATE() AS ErrorState,--Si bien estan solo disponibles dentro del catch podemos incluirlas en un SP para no duplicar codigo

        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine
GO
----------------------------------------------------------------------------------------------------------------
--------------------------------------------Trigger bad seller----(PREGUNTAR)----------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- CREATE TABLE AutoresBadSeller
--  (--creacion tabla badSeller
--  IDAutor SmallInt NOT NULL,
--  au_idViejo varchar(12),
--  au_lname varchar(40) NOT NULL,
--  au_fname varchar(20) NOT NULL,
--  phone char(12) NULL,
--  address varchar(40) NULL,
--  city varchar(20) NULL,
--  state char(2) NULL,
--  zip char(5) NULL
--  ) 


-- CREATE TABLE Setup
--  (
--  Tabla varchar(40) NOT NULL,
--  Ultimo Integer
--  ) 
-- CREATE TRIGGER InsertarBadSeller
--     ON Authors
--     AFTER DELETE
--     AS
--     DECLARE
--         @IDAutor SmallInt,
--         @au_idViejo varchar(12),
--         @au_lname varchar(40),
--         @au_fname varchar(20),
--         @phone char(12),
--         @address varchar(40),
--         @city varchar(20),
--         @state char(2),
--         @zip char(5);
--     BEGIN
--         SET @au_idViejo = (SELECT au_id FROM DELETED)
--         SET @au_lname = (SELECT au_lname FROM DELETED)
--         SET @au_fname = (SELECT au_fname FROM DELETED)
--         SET @phone = (SELECT phone FROM DELETED)
--         SET @address = (SELECT address FROM DELETED)
--         SET @city = (SELECT city FROM DELETED)
--         SET @state = (SELECT state FROM DELETED)
--         SET @zip = (SELECT zip FROM DELETED)
--         EXECUTE ObtenerID 'AutoresBadSeller', @IDAutor OUTPUT
--         INSERT INTO AutoresBadSeller
--             VALUES (@IDAutor,@au_idViejo,@au_lname,@au_fname,@phone,@address,@city,@state,@zip)
--     END
-- GO
-- CREATE PROCEDURE ObtenerID--dado el nombre debe retornar el ultimo disponible (tambien se debe validar con try catch)
-- @NomTabla varchar(20)
-- AS
-- BEGIN TRY
    
-- END TRY
-- BEGIN CATCH
--     EXECUTE usp_GetErrorInfo
--     RETURN @@Error
-- END CATCH

-- END
-- GO
----------------------------------------------------------------------------------------------------------------
--------------------------------------------Eliminar Publicacion------------------------------------------------
----------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE EliminarPublicacion
(
    @title_id varchar(6)
)
AS
BEGIN TRY
    DELETE FROM sales
        WHERE sales.title_id = @title_id
    DELETE FROM roysched
        WHERE roysched.title_id = @title_id
    DELETE FROM titleAuthor
        WHERE titleAuthor.title_id = @title_id
    DELETE FROM titles
        WHERE titles.title_id = @title_id
    RETURN 0
END TRY

BEGIN CATCH
    EXECUTE usp_GetErrorInfo
    RETURN @@Error
END CATCH

GO
----------------------------------------------------------------------------------------------------------------
--------------------------------------------Eliminar autor------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE EliminarAutor
(
    @au_id varchar(12)
)
AS
BEGIN TRY
    DELETE FROM titleAuthor
        WHERE titleAuthor.au_id = @au_id
    DELETE FROM authors
        WHERE authors.title_id = @au_id
END TRY

BEGIN CATCH
    EXECUTE usp_GetErrorInfo
    RETURN @@Error
END CATCH
GO
----------------------------------------------------------------------------------------------------------------
--------------------------------------------Proceso principal---------------------------------------------------
----------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE main
AS
DECLARE @idAutor varchar(6),
        @au_lname varchar(40),
        @au_fname varchar(20),
        @title_id varchar(6),
        @retorno smallint;

DECLARE cursorAutores CURSOR
    FOR (SELECT A.au_id, A.au_fname, A.au_lname
    FROM authors A
    WHERE (A.au_id IN (SELECT au_id 
                        FROM titleAuthor))--(c)
         AND (NOT EXISTS (SELECT *
                            FROM titleauthor TA
                             WHERE TA.au_id = A.au_id AND royaltyper <> 100))--(b)
         AND (A.au_id IN(SELECT A.au_id 
                            FROM Authors A INNER JOIN titleAuthor T ON A.au_id = T.au_id 
                                            INNER JOIN titles Ti ON T.title_id = Ti.title_id 
                                            INNER JOIN sales S ON S.title_id = Ti.title_id
                                            WHERE (YEAR(S.ord_date) IN(1993,1994))))--(d)
        AND (25 > ALL(SELECT SUM(qty)
                    FROM sales S INNER JOIN Titles T ON T.title_id = S.title_id 
                                 INNER JOIN titleAuthor TA ON T.title_id = TA.title_id
                                    WHERE (YEAR(S.ord_date) IN(1993,1994) AND TA.au_id = A.au_id)
                                    GROUP BY S.title_id)))
OPEN cursorAutores

FETCH NEXT FROM cursorAutores
    INTO @idAutor,@au_lname,@au_fname
BEGIN TRANSACTION
BEGIN
    WHILE @@fetch_status = 0 --proceso publicaciones por Autor en otro bucle, eliminando cada una de estas y leugo elimino el autor 
        BEGIN
            PRINT 'Procesando autor ' + @au_fname + ' ' + @au_lname 
            DECLARE curPublicaciones CURSOR
                FOR (SELECT title_id
                        FROM titles T INNER JOIN titleAuthor TA ON T.title_id = TA.title_id
                                        INNER JOIN authors A ON A.au_id = TA.au_id
                            WHERE A.au_id = @idAutor)
            OPEN curPublicaciones
            FETCH NEXT FROM curPublicaciones INTO @title_id
            WHILE @@fetch_status = 0
                BEGIN
                    PRINT 'Procesando publicacion ' + @title_id
                    EXECUTE EliminarPublicacion @title_id, @retorno OUTPUT
                    IF @retorno <> 0
                        BEGIN
                            RAISERROR('Error en eliminación de publicación o sus dependencias',15,0)
                            ROLLBACK TRANSACTION
                            RETURN
                        END--END IF
                    FETCH NEXT FROM curPublicaciones INTO @title_id
                    END--END 1er WHILE
                    CLOSE curPublicaciones
                    DEALLOCATE curPublicaciones
                    EXECUTE EliminarAutor @idAutor, @retorno
                    IF @retorno <> 0
                        BEGIN
                            RAISERROR('Error en eliminación de autor',15,0)
                            ROLLBACK TRANSACTION
                            RETURN
                        END--END IF
                    FETCH NEXT FROM cursorAutores
                        INTO @idAutor,@au_lname,@au_fname
                END--END 2do WHILE
    CLOSE cursorAutores
    DEALLOCATE cursorAutores
    COMMIT TRANSACTION
END


