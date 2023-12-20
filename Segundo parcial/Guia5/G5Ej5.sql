-- Ejercicio 5
-- En la tabla Employee hay varios empleados que son editores (columna job_id con valor 5):
--Select * from employee where job_id = 5  --editores
--PXH22250M de 0877
--CFH28514M de 9999
--JYL26161F de 9901
--LAL21447M de 0736
--RBM23061F de 1622
--SKO22412M de 1389
--MJP25939M de 1756

-- Se deben analizar los empleados con job_id 5 y, de los que pertenezcan a las dos
-- editoriales que menos han facturado (en dinero) a lo largo del tiempo, se debe seleccionar
-- el más antiguo (columna hire_date).
-- Este empleado debe pasar a formar parte de la editorial que más ha facturado (en dinero)
-- a lo largo del tiempo.
-- Por ejemplo, la editorial que más ha vendido es la '1389'.
-- Las dos que menos han vendido son las '0736' y '0877'
-- Terminan siendo evaluados dos empleados:
-- PXH22250M de editorial 0877 contratado el 1993-08-19 00:00:00.000
-- LAL21447M de editorial 0736 contratado el 1990-06-03 00:00:00.000

-- El más antiguo es el empleado LAL21447M, contratado en 1990. Este empleado debe
-- pasara trabajar en la editorial '1389'.
-- Resuélva el ejercicio utilizando T-SQL
-- Nota: existen soluciones sin cursores para este problema. Resuelva el Ejercicio con algún
-- uso de los mismos.

--1) empleados con job_id = 5
--2) empleados que pertenezcan a las dos editoriales que menos han facturado
--3) se desea seleccionar el mas antiguo (columna hire_date)
--este empleado debe pasar a formar parte de la editorial que mas ha facturado
CREATE PROCEDURE g5Ej5
AS
DECLARE cursorEmpleado CURSOR 
    FOR (SELECT E.emp_id
        FROM Employee E
        WHERE E.job_id = 5 AND
              E.emp_id IN (SELECT E1.emp_id
                            FROM Employee E1 INNER JOIN Publishers P1 ON E1.pub_id = P1.pub_id
                            WHERE P1.pubid IN (SELECT TOP (2) P.pub_id
                                                FROM publishers P INNER JOIN titles T ON P.pub_id = T.pub_id 
                                                                INNER JOIN Sales S ON S.title_id = T.title_id
                                                ORDER BY (S.qty*T.price) ASC)
                        )
        AND MIN(E.hire_date)
        )

--2 editoriales que menos han facturado
