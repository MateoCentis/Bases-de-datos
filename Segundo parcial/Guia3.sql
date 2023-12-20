--Primera parte JOIN
--Join se usa cuando lo que necesito recuperar está en más de una tabla
--1.1 - Producto cartesiano
--El producto cartesiano de RxS toma cada una de las n tuplas de R y las combina con las m de S:
--nos queda como resultado una nueva tabla con n*m tuplas.
--Para hacerlo, en SQL:
/*
CREATE TABLE R1
 (
 A Integer,
 B Integer
 )

CREATE TABLE S1
 (
 B Integer,
 C Integer,
 D Integer
 )
INSERT R1 VALUES (1, 2)
INSERT R1 VALUES (3, 4)
INSERT S1 VALUES (2, 5, 6)
INSERT S1 VALUES (4, 7, 8)
INSERT S1 VALUES (9, 10, 11) 

SELECT A, R1.B 'R1.B', S1.B 'S1.B', C, D
  FROM R1 CROSS JOIN S1
*/
--EJEMPLO DE USO CON AUTHORS
--Select COUNT(*) FROM authors  nos da el numero de autores.

--Podemos combinar cada autor con todos los demás usando la siguiente sentencia:
--SELECT a1.au_lname, a1.city, a2.au_lname, a2.city
-- FROM authors a1 CROSS JOIN authors a2

--Podemos mejorar la consulta a leds de evitar que un autor se “empareje” con si mismo. Ejemplo:
--SELECT a1.au_lname, a1.city, a2.au_lname, a2.city
-- FROM authors a1 CROSS JOIN authors a2
-- WHERE a1.au_lname <> a2.au_lname

--Esta consulta no parece ser muy útil, pero podemos adecuarla para -por ejemplo- listar todos
--los autores que viven en una misma ciudad: =>
--SELECT a1.au_lname, a2.au_lname, a1.city, a2.city
-- FROM authors a1 CROSS JOIN authors a2
-- WHERE a1.au_lname <> a2.au_lname AND
-- a1.city = a2.city

--Igual todavía pasa que se puede repetir el par odenado (x,y) en la forma (y,x). Así:
--SELECT a1.au_lname, a2.au_lname, a1.city, a2.city
-- FROM authors a1 CROSS JOIN authors a2
-- WHERE a1.au_lname < a2.au_lname AND
-- a1.city = a2.city
--------------------------------------------------------------------------------------------------------------------------
--1.2 Natural JOIN (no sirve)
--Busca columnas en comun y a partir de estas encastra las tablas
--------------------------------------------------------------------------------------------------------------------------
--1.3 - Equi INNER JOINS 
--Se usa el comparador de igualdad. se usa para que la PK de una tabla coincide con la FK de otra.
--el atributo A de R se empareja con el atributo D de S:
--EJ:
--SELECT R2.*,S2.*
--  FROM R2 INNER JOIN S2
--  ON R2.A = S2.D

--Ejemplo más claro:
--SELECT P.ApeNom, A.Condicion
-- FROM Alumno A INNER JOIN Persona P
--  ON A.tipoDoc = P.tipoDoc AND A.NroDoc = P.NroDoc
--WHERE A.edad > 25 
--El on me interesa para el join para traer alumno y persona,
-- en cambio el where filtra por edad.
--------------------------------------------------------------------------------------------------------------------------
--1.4 - Enlazar más de dos tablas en un INNER JOIN 
--Se debe navegar entre FK y PK
--EJ:
--SELECT P.pub_name
-- FROM Publishers P INNER JOIN Titles T
-- ON P.pub_id = T.pub_id 
-- INNER JOIN titleauthor TA
-- ON T.title_id = TA.title_id
-- WHERE TA.au_id = '998-72-3567'

--Primero chequea entre publisher y titles y luego entre titles y titlesAuthor.
--------------------------------------------------------------------------------------------------------------------------
--1.5 - Outer JOINS
--Sirven para ademas de recuperar los que tienen igual pk y fk ademas recupera los que no cumplen esta condicion
--EJ:
--SELECT publishers.pub_id, pub_name, titles.title_id
-- FROM publishers LEFT JOIN titles
-- ON publishers.pub_id = titles.pub_id

--En este caso recuperariamos todas las editoriales, no solo las que tienen titles
--------------------------------------------------------------------------------------------------------------------------
--1.6 - Tuple variable
--Usamos esto cuando necesitamos varias tuplas de la misma tabla
--Lo hacemos a traves de un alias. Ej:
--SELECT Autor1.au_lname, Autor2.au_lname
-- FROM authors Autor1, authors Autor2
-- WHERE Autor1.city = Autor2.city AND
-- Autor1.au_lname < Autor2.au_lname
--------------------------------------------------------------------------------------------------------------------------
--2 - Subqueries 
--subconsulta: SELECT anidado.
--outer query: usa subqueries.
--inner query: subquery usado por outer query.
--2.1 - subqueries que retornan escalares
--El caso más común es cuando obtenemos de un SELECT
--un valor escalar para comparar en el WHERE,EJ:
--SELECT pub_name
-- FROM publishers
-- WHERE pub_id = (SELECT pub_id
--       FROM titles
--       WHERE title_id = 'PC8888')

--2.2 - Condiciones que involucran relaciones
--2.2.1 - El operador IN que dado un intervalo devuelve una relación unaria (VECTOR), es decir, 
--es como preguntar si esta en el vector resultado de la relación R
--2.2.2. El cuantificador ALL 
--se usa cuando un escalar s es (operador) que todos los R, EJ:
--SELECT title, price
-- FROM titles
-- WHERE price >= ALL (SELECT price
--                      FROM titles Titles2
--                      WHERE price IS not NULL)
--En este ejemplo obtenemos el titulo y el precio cuando el precio sea mayor al precio maximo dado por la relacion R
--2.2.3 - El cuantificador ANY 
--cumple siempre y cuando un valor s de cumpla con la operación con cualquier valor de R
--SELECT title, price
-- FROM titles
-- WHERE price > ANY (SELECT price
--                    FROM titles Titles2
--                    WHERE price IS NOT NULL AND
--                    price > 20) 
--2.2.5 - Subqueries correlacionados
--SELECT pub_id, fname, lname, hire_date
-- FROM employee e
-- WHERE e.hire_date = (SELECT MIN(hire_date)
--                     FROM employee e2
--                     WHERE e2.pub_id = e.pub_id)
--2.2.6 El cuantificador EXISTS
--Siempre precede a un subquery, chequea que la lista resultado de la relacion R no sea vacia
--SELECT title, titles.title_id
-- FROM titles
-- WHERE EXISTS (SELECT *
--               FROM sales
--               WHERE sales.title_id = titles.Title_id AND
--               YEAR(ord_date) NOT IN (1993, 1994)
--               ) 
--------------------------------------------------------------------------------------------------------------------------
--3 - SELECTs en la lista de salida de un SELECT, el SELECT secundario debe retornar un escalar
--SELECT title, (Select SUM(qty)
--               FROM sales
--               WHERE sales.title_id = titles.title_id) AS 'Cantidad vendida'
-- FROM titles 
--------------------------------------------------------------------------------------------------------------------------
--4 - Subqueries en la cláusula FROM
--SELECT au_lname
-- FROM authors INNER JOIN titleauthor
--               ON authors.au_id = titleauthor.au_id
--              INNER JOIN (SELECT titles.*
--                          FROM titles
--                          WHERE pub_id = '0736'
--                           )
--TitlesAlgodata ON titleauthor.title_id = TitlesAlgodata.title_id
--------------------------------------------------------------------------------------------------------------------------
--5 - Eliminación de duplicados, se usa el comando DISTINCT, EJ:
--SELECT DISTINCT type
-- FROM titles

--6 - Agregacion en SQL
--Diferencia entre atributos de tupla (valores que corresponden a una tupla) - ejemplo edad- y 
--atributos de grupo (valores que corresopnden a todo un grupo de tuplas ) -ejemplo promedio edades-.
--Operadores de agregacion: SUM, AVG, MIN, MAX y COUNT.
--se usan aplicandoles a una expresion de valor escalar -normalmenta un valor de columna- en una clausula SELECT.
--EJEMPLO DE USO:
-- SELECT AVG(Edad)
--   FROM Alumnos;
--o
--SELECT COUNT(DISTINCT type)
--  FROM Titles;
--Si queremos asegurarnos de que no se cuenten más de una vez los duplicados, se pone DISTINCT antes del atributo agregado

--7 - Grupos
--GROUP BY nos permite agrupar filas en base a los valores de UNA o MÁS COLUMNAS.
--Divide el resultado de SELECT en un conjunto de grupos, tal que para cada grupo LOS VALORES DE LA o LAS COLUMNAS 
--QUE DEFINEN EL GRUPO SON IDENTICOS. Se ubica luego del WHERE.
--EJEMPLO:
--SELECT columna1
--  FROM tabla
--  GROUP BY columna1 
-- EJEMPLO: queremos encontrar el promedio de precios de cada tipo de publicacion:
--SELECT type, AVG(price)
--  FROM titles
--  GROUP BY type

--7 - Condiciones de grupo
-- Como WHERE nos permite especificar la condicion que deben satisfacer las filas que formaran parte de la salida, 
-- HAVING nos permite especificar la condiciones que deben cumplir los grupos para formar parte de la salida.
--EJEMPLO:
--SELECT columna1
--  FROM tabla
--  GROUP BY columna1
--  HAVING condicion-de-grupo
--Si quisieramos obtener los promedios de precio por tipo de titulo y que el pub_id sea igual a '0877' y solo 
--los grupos en los cuales su publicacion mas antigua sea posterior al 1 de octubre de 1991
--EJ:
--SELECT type, AVG(price)
--  FROM titles
--  WHERE pub_id = '0877'
--  GROUP BY type
--  HAVING MIN(pubdate) > '1991-10-01' ; (condicion de grupo)
--Otro ejemplo, tenemos la consulta que lista el apellido y nombre de los autores junto a la publicación más cara y barata de su autoria a la venta
--SELECT A.au_lname, A.au_fname, MIN(price), MAX(price)
-- FROM authors A INNER JOIN titleauthor TA
--                 ON A.au_id = TA.au_id
--                INNER JOIN Titles T
--                 ON TA.title_id = T.title_id
-- GROUP BY A.au_lname, A.au_fname 
--pero si ahora se solicita que solo listemos a los autores que poseen exactamente dos publicaciones
--SELECT DISTINCT A.au_lname, A.au_fname, MIN(price), MAX(price)
-- FROM authors A INNER JOIN titleauthor TA
--                  ON A.au_id = TA.au_id
--                INNER JOIN Titles T
--                  ON TA.title_id = T.title_id
-- GROUP BY A.au_lname, A.au_fname
-- HAVING COUNT(T.title_id) = 2

--8 - La expresion CASE
--CASE compara un valor contra una lista de valores y retorna un resultado asociado al primer valor coincidente
--CASE expresion0
--  WHEN expresion1 then resultado1
--    WHEN expresion2 then resultado2
--    ...
--  ELSE resultadoExpresionN
--END
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--EJERCICIOS
--Ejercicio 1. Obtenga un listado de apellidos y
--nombres de autores junto a los títulos de las
--publicaciones de su autoría. Ordene el listado
--por apellido del autor. 
--Sin usar INNER JOIN
SELECT A.au_lname, A.au_fname, T.title
FROM titleAuthor TA, Titles T, Authors A
WHERE Ta.au_id = A.au_id AND TA.title_id = T.title_id
ORDER BY au_lname
--Usando INNER JOIN 
SELECT A.au_lname, A.au_fname, T.title
FROM titleAuthor TA INNER JOIN Titles T ON TA.title_id = T.title_id
  INNER JOIN Authors A ON TA.au_id = A.au_id
ORDER BY au_lname
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 2. Obtenga un listado que incluya los nombres
--de las editoriales (tabla publishers) y los nombres y
--apellidos de sus empleados (tabla employee) pero sólo
--para los empleados con
--job level de 200 o más.
--Sin INNER JOIN
SELECT P.pub_name, E.fname, E.job_lvl
FROM Publishers P, Employee E
WHERE E.pub_id =  P.pub_id AND E.job_lvl >= 200
--Con INNER JOIN 
SELECT P.pub_name, E.fname, E.job_lvl
FROM Publishers P INNER JOIN Employee E ON P.pub_id = E.pub_id
WHERE E.job_lvl >= 200
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 3. Recordemos que tabla sales contiene información de
--ventas de publicaciones. Cada venta era identificada unívocamente por
--un número de orden (ord_num), el almacén donde se produjo
--(stor_id) y la publicación vendida (title_id).
--La venta poseía también la fecha de venta (ord_date) y la cantidad
--vendida de la publicación (qty).

--Se desea obtener un listado como el siguiente (au_lname,au_fname,Ingresos), que muestre
--los ingresos (precio de publicación * cantidad vendida) que ha
--proporcionado cada autor a partir de las ventas de sus
--publicaciones. Ordene el listado por orden descendente de
--ingresos.
--Sin join
SELECT A.au_lname, A.au_fname, S.qty*T.price AS 'Ingresos'
FROM Sales S, Titles T, authors A, TitleAuthor TA
WHERE   T.title_id = S.title_id AND TA.au_id = A.au_id AND TA.title_id = T.title_id
ORDER BY 'Ingresos' DESC
--Con join 
SELECT A.au_lname, A.au_fname, S.qty*T.price AS 'Ingresos'
FROM Titles T INNER JOIN Sales S ON T.title_id = S.title_id
  INNER JOIN titleauthor TA ON T.title_id = TA.title_id
  INNER JOIN authors A ON A.au_id = TA.au_id
ORDER BY 'Ingresos' DESC
--Hay que hacerlo por GRUPOS, :
SELECT A.au_lname, A.au_fname, SUM(S.qty*T.price) AS 'Ingresos'
FROM Titles T INNER JOIN Sales S ON T.title_id = S.title_id
  INNER JOIN titleauthor TA ON T.title_id = TA.title_id
  INNER JOIN authors A ON A.au_id = TA.au_id
GROUP BY A.au_lname,A.au_fname
ORDER BY 'Ingresos' DESC
--Hay que agrupar ya que au_lname y au_fname son atributos de tupla y SUM retorna atributo de grupo,
--ya que queremos agrupar los ingresos por author
--------------------------------------------------------------------------------------------------------------------------
--EJercicio 4. Obtenga los tipos de publicaciones (columna type) cuya media de precio sea mayor a $12
SELECT type
FROM titles
GROUP BY type
HAVING AVG(price) > 12
--El promedio de precios de un determinado precio con AVG
--el promedio de precios es de tipo grupo
--Comparacion contra escalar
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 5. La tabla employee posee información de los empleados de cada editorial.
--Por cada empleado tenemos su identificación (emp_id), su nombre
--(fname) y apellido (lname). Cada empleado pertenece a una editorial
--(pub_id) y posee una fecha de contratación (hire_date).
--Las funciones de los empleados se describen en la tabla jobs. Cada
--empleado posee una función (job_id).
--Obtenga el apellido y nombre del empleado contratado más
--recientemente.
--Esto no lo pude hacer andar
-- SELECT TOP (1) fname, lname
-- FROM employee
-- WHERE hire_date < (SELECT TOP (1)
--   hire_date
-- FROM employee
-- ORDER BY hire_date DESC);
--Esto devuelve el mas viejo
-- SELECT TOP (1)
--   fname, lname, hire_date
-- FROM employee
-- ORDER BY hire_date
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 6. Obtenga un listado de editoriales que han editado publicaciones de tipo business
SELECT P.pub_name
FROM Publishers P INNER JOIN Titles T ON P.pub_id = T.pub_id
WHERE T.type = 'business'
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 7. Obtenga un listado de las publicaciones que no se vendieron ni en 1993 ni en 1994 (columna ord_date en tabla Sales)
SELECT title_id, title
FROM titles
WHERE NOT(title_id IN (SELECT T.title_id
FROM titles T INNER JOIN Sales S ON S.title_id = T.title_id
WHERE YEAR (S.ord_date) IN ('1993','1994')))
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 8. Obtenga un listado como el siguiente con las publicaciones que poseen un precio menor que el promedio 
--de precios de las publicaciones de la editorial a la que pertenecen
SELECT T.title, P.pub_name, T.price
FROM titles T INNER JOIN publishers P ON T.pub_id = P.pub_id
WHERE T.price < (SELECT AVG(price)
--Quiero el promedio de precios de 
FROM titles T2
--los titulos que pertencen al mismo publisher que el de comparacion
WHERE T2.pub_id = T.pub_id)
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 9.  La tabla authors posee una columna llamada
-- contract con valores 0 ó 1 indicando si el autor posee o
-- no contrato con la editora. Se desea obtener un listado
-- como el siguiente para los autores de California (columna
-- state con valor CA).
SELECT au_fname AS 'Nombre', au_lname AS 'Apellido',
  (SELECT CASE contract
 WHEN 1 THEN 'SI'
 WHEN 0 THEN 'NO'
 ELSE 'NO'
 END) AS 'Posee contrato?'
FROM Authors
WHERE state = 'CA'
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 10.  La columna job_lvl indica el puntaje del
-- empleado dentro de su área de especialización.
-- Se desea obtener un reporte como el siguiente,
-- ordenado por puntaje y apellido del empleado:
SELECT lname, (SELECT CASE 
                WHEN (job_lvl > 99 AND job_lvl < 200) THEN 'Puntaje entre 100 y 200'
                  WHEN (job_lvl < 100) THEN 'Puntaje menor que 100'
                    ELSE 'Puntaje mayor que 200'
                      END) AS 'Nivel'
FROM employee
ORDER BY lname ASC,job_lvl
--Preguntar como ordenar