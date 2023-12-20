--------------------------------------------------------------------------------------------------------------------------
--PRIMERA PARTE
--1)Obtenga el código de título, título, tipo y precio incrementado en un 8% de todas las
--publicaciones, ordenadas por tipo y título. 
--con el as asignamos un alias para mostrar en el 
--------------------------------------------------------------------------------------------------------------------------
--2)Ponerle alias a la columna precio
--Comando para SQL server

/*
SELECT title_id,
  title,
  type,
  price * 1.08 'precio actualizado'
FROM titles
ORDER BY type,title
*/

--Comando para Postgres

/*
 SELECT title_id, title, type, price*1.08 as "precio actualizado"
 FROM titles
 ORDER BY type,title
 */
--------------------------------------------------------------------------------------------------------------------------
--3)Modifique la consulta del ejercicio 2 a fin de obtener los datos por orden descendente de
--precio actualizado.
/*
SELECT title_id, title, type, price * 1.08 'precio actualizado'
FROM titles
ORDER BY 'precio actualizado' DESC
*/
--------------------------------------------------------------------------------------------------------------------------
/*4) Es posible expresar el número de orden en la lista de salida del SELECT para identificar la
columna sobre la cual se desea ordenar. Por ejemplo: ORDER BY 5. Reescriba la consulta de
esta forma.*/
/*
SELECT title_id, title, type, price * 1.08 'precio actualizado'
FROM titles
ORDER BY 4 DESC
*/
--------------------------------------------------------------------------------------------------------------------------
/*5) Obtenga en una única columna el apellido y nombres de los autores separados por coma
con una cabecera de columna Listado de Autores. Ordene el conjunto resultado.*/
--Comando SQL server
/*
SELECT au_lname +', '+ au_fname 'Listado de Autores'
FROM authors
ORDER BY 1
*/
--Comando Postgres
/*
SELECT au_lname || ', ' || au_fname as "Listado de Autores"
FROM authors
ORDER BY 1
*/
--------------------------------------------------------------------------------------------------------------------------
/*6 y 7. Obtenga un conjunto resultado para la tabla de
publicaciones que proporcione, para cada fila, una
salida como la siguiente.*/
--Fila ej: BU1032 posee un valor de $19.99
/*
SELECT title_id + ' posee un valor de $' + CAST(price as varchar)
FROM titles
*/
--CAST(columna-a-convertir as tipoDatoAConvertir)
--otra posibilidad es, en microsoft SQL, usar convert(tipoDatoAConvertir,columna-a-convertir) 
/*
SELECT title_id + ' posee un valor de $' + convert(varchar,price)
FROM titles
*/
--En postgres columna-a-convertir::tipoDatoAConvertir
/*
SELECT title_id || ' posee un valor de $' || price::varchar
FROM titles
*/
--------------------------------------------------------------------------------------------------------------------------
--SEGUNDA PARTE: LA CLAUSULA WHERE
--WHERE: permite especificar una condición que las filas deben cumplir para formar parte de la lista de salida del SELECT
/*8. Obtenga título y precio de todas las publicaciones que no valen más de $13. Pruebe definir
la condición de WHERE con el operador NOT.*/
/*
SELECT title,price
FROM titles
WHERE NOT(price > 13)
*/
--fechas en WHERE: entre comillas simples 'mm/dd/aaaa'
--predicado BETWEEN: especifica la comparacion dentro de un intervalo entre valores cuyos tipos de datos son comparables. 
--EJ: WHERE precio BETWEEN 5 AND 10
--con NOT se usa para valores fuera de ese intervalo: WHERE precio NOT(BETWEEN 5 AND 10)
--------------------------------------------------------------------------------------------------------------------------
/*9. Obtenga los apellidos y fecha de contratación de todos los empleados que fueron
contratados entre el 01/01/1991 y el 01/01/1992. Use el predicado BETWEEN para elaborar la
condición.*/
/*
SELECT lname, hire_date
FROM employee
WHERE hire_date BETWEEN '01/01/1991' AND '01/01/1992'
*/
--------------------------------------------------------------------------------------------------------------------------
--El operador [NOT] IN: especifica la comparación cuantificada, hace una lista de valores y evalúa si un valor está en la lista ()
--EJ: WHERE precio IN (25,30).
/*10. Obtenga los códigos, domicilio y ciudad de los autores con código 172-32-1176 y
238-95-7766. Utilice el operador IN para definir la condición de búsqueda.
Modifique la consulta para obtener todos los autores que no poseen esos códigos. */
/*
SELECT au_id, address, city
FROM authors
WHERE au_id IN ('172-32-1176','238-95-7766')
*/
--LIKE: compara caracteres comodín (wild cards) para recuperar filas cuando solo se conoce un PATRON del dato buscado
--los caracteres comodín son:
--% 0 a n caracteres (de cualquier caracter)
--_ Exactamente un caracter (de cualquier caracter)
--[] exactamente un caracter del conjunto o rango especificado. EJ: [aAc] o [a-c].
--11. Obtenga código y título de todos los títulos que incluyen la palabra Computer en su título.
/*
SELECT title_id, title
FROM titles
WHERE title LIKE '%Computer%'
*/
--NULL: indica valor desconocido o no significativo para una columna 
--Deben ser tratados con cuidados en las comparaciones, son considerados siempre los más bajos
/*
SELECT pub_name, city, state
FROM publishers
WHERE state IS NULL
*/
--es incorrecto usar state=NULL ya que no es un valor
--------------------------------------------------------------------------------------------------------------------------
--Parte 3 - Limitar la cantidad de tuplas
--obtenemos las primeras n tuplas usando el modificador TOP
--En sql server
--EJ: SELECT TOP 1 *
--      FROM titles
--En postgres
--EJ: SELECT *
--      FROM titles
--      LIMIT 1;
--------------------------------------------------------------------------------------------------------------------------
--Parte 4 - Funciones
--4.1 - Fechas
--Componentes de una fecha:
--SQL server
--YEAR(columna) retorna año de la fecha como un entero de 4 digitos
--MONTH(columna) retorna mes de la fecha como un entero de 1 a 12
--DAY(columna) retorna día del mes de la fecha como un entero

--Postgres usa la funcion date_part
--date_part('year', columna) retorna año de la fecha como un número de doble precisión.
--date_part('month',columna) retorna mes de la fecha como un número ...
--date_part('day',columna) retorna mes de ...
--Mismo resultado reemplazando date_part con la funcion EXTRACT
--------------------------------------------------------------------------------------------------------------------------
--13. La información de publicaciones vendidas reside en la tabla Sales. Liste las filas de
--    ventas correspondientes al mes de Junio de cualquier año. 
--para SQL server
/*
SELECT *
FROM sales
WHERE MONTH(ord_date) = 6
*/
--para Postgres
/*
SELECT *
FROM sales
WHERE date_part('month',ord_date) = 6
*/
--SQL server: CURRENT_TIMESTAMP retorna fecha y hora actual como un valor datetime, se invoca sin parentesis
--Postgres: se puede usar CURRENT_TIMESTAMP o now()

--FECHAS COMO texto
--convert() posee una version extendida que permite convertir datos de columnas de tipo datetime a formatos de texto
--la sintaxis es convert(varchar,columna-datetime,codigo-de-formato)
--codigo-de-formato estable como se va a mostrar en formato varchar. EJ: el formato 3 muestra la fecha con formato dd/mm/yyyy
--EJ: SELECT CONVERT(varchar,hire_date,3)
--      FROM Employee
--4.2 - Strings
--substring(columna-o-expresion,desde,cantidad) extrae una subcadena principal, donde
--columna-o-expresion es la cadena donde se extraera y desde es la posicion. retorna un varchar
--EJ: SELECT substring(title,5,4)
--      FROM titles
--Conversion de numeros a Strings con str(expresion-numerica,longitud-total,cantidad-decimales) donde 
--longitud es la longitud total incluyendo la coma y los decimales. 
--EJ:  