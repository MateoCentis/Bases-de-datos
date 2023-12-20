-- Ejercicio 7.
-- Tenemos una tabla de registro con la siguiente estructura:
CREATE TABLE Registro
(
fecha DATE NULL,
tabla varchar(100) NULL,
operacion varchar(30) NULL,
CantFilasAfectadas Integer NULL
)
-- Se desean registrar en ella algunos movimientos que afectan varias filas, como UPDATE y
-- DELETE.
-- Se desea crear un trigger (tr_Ejercicio7) para DELETE sobre la tabla Employee que por
-- cada sentencia DELETE que afecte más de una tupla genere una entrada en la tabla
-- Registro.
-- Se sugiere realizar una copia de la tabla Employee a fin de realizar las pruebas.
-- Para realizar las pruebas, elimine los cuatro empleados que existen con job_id 8:
Select * from employee where job_id = 8
-- ¿Cómo escribiría el trigger y en que lenguaje (T-SQL ó PL/pgSQL)?
