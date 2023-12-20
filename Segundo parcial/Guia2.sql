--1. Scripts de creacion
--En SQL
/*
CREATE TABLE cliente
 (
 codCli int NOT NULL,
 ape varchar(30) NOT NULL,
 nom varchar(30) NOT NULL,
 dir varchar(40) NOT NULL,
 codPost char(9) NULL DEFAULT 3000
 )
CREATE TABLE productos
 (
 codProd int NOT NULL,
 descr varchar(30) NOT NULL,
 precUnit float NOT NULL,
 stock smallint NOT NULL
 )
CREATE TABLE proveed
 (
 codProv int IDENTITY(1,1),
 razonSoc varchar(30) NOT NULL,
 dir varchar(30) NOT NULL
 )
CREATE TABLE pedidos
 (
 numPed int NOT NULL,
 fechPed datetime NOT NULL,
 codCli int NOT NULL
 )
CREATE TABLE detalle
 (
 codDetalle int NOT NULL,
 numPed int NOT NULL,
 codProd int NOT NULL,
 cant int NOT NULL,
 precioTot float NULL
 )
 */
--En Postgres
/*
 CREATE TABLE cliente
 (
 codCli int NOT NULL,
 ape varchar(30) NOT NULL,
 nom varchar(30) NOT NULL,
 dir varchar(40) NOT NULL,
 codPost char(9) NULL DEFAULT 3000
 );
CREATE TABLE productos
 (
 codProd int NOT NULL,
 descr varchar(30) NOT NULL,
 precUnit float NOT NULL,
 stock smallint NOT NULL
 );
CREATE TABLE proveed
 (
 codProv SERIAL,
 razonSoc varchar(30) NOT NULL,
 dir varchar(30) NOT NULL
 );
CREATE TABLE pedidos
 (
 numPed int NOT NULL,
 fechPed date NOT NULL,
 codCli int NOT NULL
 );
CREATE TABLE detalle
 (
 codDetalle int NOT NULL,
 numPed int NOT NULL,
 codProd int NOT NULL,
 cant int NOT NULL,
 precioTot float NULL
 ) ;
 */
/*Columnas con valores incrementales:
--En SQL server 
se definen especificando la clausula IDENTITY(SEED,STEP),
SEED es el valor inicial que recibirá la primer fila insertada
STEP es el incremento entre filas consecutivas
EJEMPLO:
CREATE TABLE proveed
 (
 codProv int IDENTITY(1,1),
 razonSoc varchar(30) NOT NULL,
 dir varchar(30) NOT NULL,
 ) 

--En Postgres
se utiliza SERIAL. Este crea una secuencia implícita para la columna definida con el tipo de dato SERIAL,
la sentencia: <nombre-tabla>_<nombre-columna-serial>_seq
EJEMPLO
CREATE TABLE proveed
 (
 codProv SERIAL,
 razonSoc varchar(30) NOT NULL,
 dir varchar(30) NOT NULL
 )

Secuencia (sequence)
Una secuencia es una característica para generar valores
enteros secuenciales únicos y asignárselos a columnas numéricas.
Internamente, una secuencia es generalmente una tabla con una columna numérica en la
cual se almacena un valor que es consultado e incrementado por el sistema. 
*/
--------------------------------------------------------------------------------------------------------------------------
/*Usamos INSERT para insertar filas en tablas, la sintaxis es
INSERT [INTO] <tabla>
 [ (<columna1>, <columna2> [, <columnan> ...] ) ]
 VALUES ( <dato1> [, <dato2>...] )

*En postgres la cláusula INTO es obligatoria
*si proporcionamos datos para TODAS las columnas entonces no es necesario especificarlas explicitamente:
INSERT [INTO] <tabla>
 VALUES ( <dato1> [, <dato2>...] ) 
*Los datos char o varchar se especifican entre comillas simples.
*float se especifican con un punto decimal. (Por ejemplo: 243.2).
*El formato de las fechas varía según la configuración del DBMS. Un formato usual es
aaaa/mm/dd. El mismo se especifica entre comillas simples (Por ejemplo:
'2007/11/30').
*/
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 2:  Inserte en la tabla cliente una fila con los siguientes datos:
--1, 'LOPEZ', 'JOSE MARIA', 'Gral. Paz 3124'. Permita que el código
--postal asuma el valor por omisión previsto. Verifique los datos insertados.
--en SQL server
/*
INSERT INTO cliente
  (codCli,ape,nom,dir)
VALUES
  (1, 'LOPEZ', 'JOSE MARIA', 'Gral. Paz 3124')
--Para chequear que aparece
SELECT *
FROM cliente
*/
/*
INSERT INTO cliente
  (codCli,ape,nom,dir)
VALUES
  (1, 'LOPEZ', 'JOSE MARIA', 'Gral. Paz 3124')
*/
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 3 Inserte en la tabla cliente una fila con los siguientes datos: 2, 'GERVASOLI',
--'MAURO', 'San Luis 472'. ¿Podemos evitar que la fila asuma el valor por omisión para el
--código postal?. Verifique los datos insertados.
/*
INSERT INTO cliente
  (codCli,ape,nom,dir,codPost)
VALUES
  (2, 'GERVASOLI', 'MAURO', 'San Luis 472',NULL)

SELECT *
FROM cliente
*/
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 4. Inserte en la tabla proveed dos proveedores: 'FLUKE
--INGENIERIA', 'RUTA 9 Km. 80' y 'PVD PATCHES', 'Pinar de Rocha
--1154'. Verifique los datos insertados.
--Se omite la columna id ya que es autoincremental
/*
INSERT INTO proveed
  (razonSoc,dir)
VALUES
  ('FLUKE INGENIERIA', 'RUTA 9 Km. 80')

INSERT INTO proveed
  (razonSoc,dir)
VALUES
  ('PVD PATCHES', 'Pinar de Rocha 1154')
*/

--Información del sistema, podemos obtener el nombre del usuario:
--En sql server: USER.
--En postgres: current_user o user.
--------------------------------------------------------------------------------------------------------------------------
/*
Ejercicio 5.
 Defina una tabla de ventas (Ventas) que contenga:
-Un código de venta de tipo entero (codVent) autoincremental.
-La fecha de carga de la venta (fechaVent) no nulo con la fecha actual como valor por
omisión.
-El nombre del usuario de la base de datos que cargó la venta (usuarioDB) no nulo con el
usuario actual de la base de datos como valor por omisión.
-El monto vendido (monto) de tipo FLOAT que admita nulos.
*/
/*
CREATE TABLE Ventas
(
  codVent int IDENTITY(1,1),
  fechaVent date NOT NULL DEFAULT CURRENT_TIMESTAMP,
  usuarioDB varchar(40) NOT NULL DEFAULT USER,
  monto float NULL
)
*/
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 6. Inserte dos ventas de $100 y $200 respectivamente. No proporcione ninguna
--información adicional. Verifique los datos insertados.
/*
INSERT INTO Ventas
  (monto)
VALUES
  (100)

INSERT INTO Ventas
  (monto)
VALUES
  (200)
*/
--Podemos crear una tabla e insertar filas una existente usando SELECT con INTO
--SELECT <lista de columnas>
-- INTO <tabla-nueva>
-- FROM <tabla-existente>
-- WHERE <condicion>

--INSERT con SELECT
--En SQL server
--INSERT <tabla-destino>
-- SELECT *
-- FROM <tabla-origen>
-- WHERE <condicion>
--En Postgres
--INSERT INTO <tabla-destino>
-- SELECT *
-- FROM <tabla-origen>
-- WHERE <condicion>

--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 7. Cree una tabla llamada clistafe a partir de los datos de la tabla cliente para
--el código postal 3000. Verifique los datos de la nueva tabla
/*
SELECT *
INTO clistafe
FROM cliente
WHERE codPost = '3000'
*/
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 8.  Inserte en la tabla clistafe la totalidad de las filas de la tabla cliente.
--Verifique los datos insertados.
/*
INSERT INTO clistafe
SELECT *
FROM cliente
*/

--3. Modificación de datos, se usa UPDATE
--UPDATE <tabla>
-- SET <col> = <nuevo valor-o-expres> [,<col> = <nuevo-valor-o-expres>...]
-- WHERE <condición> 
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 9. En la tabla cliente, modifique el dato de domicilio. Para todas las columnas
--que incluyan el texto '1' reemplace el mismo por 'TCM 168'.
/*
UPDATE cliente 
  SET dir = 'TCM 168'
  WHERE dir = '1'
*/

--4. Eliminación de filas, se usa DELETE
--DELETE [FROM] <tabla>
-- WHERE <condicion>
--En postgres se usa FROM de forma obligatoria
--------------------------------------------------------------------------------------------------------------------------
--Ejercicio 10. Elimine todos las filas de la tabla cliStaFe cuyo código postal sea nulo. 
/*
DELETE FROM clistafe
  WHERE codPost is NULL
*/

--5. Eliminar tablas DROP table

--6. Obtener copia de una tabla
--En postgres
--CREATE TABLE titles10
--  (LIKE titles);
--Sin usar CREATE, 2 ejemplos:
/*
SELECT *
 INTO titles10
 FROM titles
 WHERE 1=0

SELECT *
 INTO titles10
 FROM titles
 LIMIT 0
*/