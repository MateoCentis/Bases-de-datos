------------------------------------------------------------------------------------------------
--Triggers:
--1)se activan cuando ocurren ciertos eventos (triggering events) especificados por el desarrollador
--los tipos de eventos son normalmente: insert, udpate o delete sobre una tabla.

--2)en algunos DBMS una vez activado por su triggering even el trigger evalúa una condition. Si la condicion no aplica
--el ttrigger finaliza sin ejecutar nada.

--3)Se ejecuta la Action asociada al trigger. Si la DBMS permite Condition, esta Action se ejecuta solo si Condition=True

--Triggering event: Activan el trigger, los tipos son INSERT, UPDATE o DELETE.
    --*En el caso de UPDATE, podemos especificar que los mismos deben estar limitados a un atributo(columna)
        --O  conjunto de atributos en particular
--Condition: se debe cumplir para que el trigger realiza alguna acción. Si no esta siempre se ejecuta el trigger.
--Action: El el codigo que puede modificar los efectos del evento. Inclusive abortar la transacción.
    --El códgio puede llevar a cabo cualquier secuencia de operaciones de bases de datos.

--EJ 1: Postgres

CREATE TRIGGER trTitles
 {BEFORE | AFTER} 
 UPDATE ON Titles--Clausula que indica el TRIGGERING EVENT

WHEN (date_part('year', now()) = '2015')--CONDITION: se expresa con WHEN
 EXECUTE PROCEDURE test200();--ACTION: en este caso TRIGGERING FUNCTION

--Triggering function: se declara sin parámetros, su clausula RETURNS debe especificar TRIGGER, EJ:
CREATE OR REPLACE FUNCTION test7000()
  RETURNS trigger ..

--Si hay más de un triggering event, se separa con OR

CREATE TRIGGER trTitles
    [BEFORE|AFTER] UPDATE OR INSERT ON titles
    --...
 
--TSQL
GO
CREATE TRIGGER trTitles

    ON Tittles--Primero se especifica sobre que tabla 

    FOR UPDATE--luego sobre que evento (tambien se puede usar AFTER)
    --si hay más de un trigger event se separa con coma FOR UPDATE, INSERT, DELETE
    AS--No permite especificar CONDITION

        IF(YEAR(CURRENT_TIMESTAMP) = '2015')
            SELECT * INTO auditoria FROM titles
        RETURN--no puede especificar valor de retorno

------------------------------------------------------------------------------------------------
--El trigger y el estado de la base de datos:
--Estado de la base de datos: conjunto de instancias actuales de todas las tablas de la base.
--CRUCIAL: la evaluación de la condition y la ejecución de la action del trigger puede tener efecto
--sobre el estado de la base de datos anterior a la ocurrencia del triggering event (BEFORE) o sobre 
--el estado de la base posterior (AFTER)

--BEFORE TRIGGER: evalúa su condition y ejecuta su action sobre el estado de la base de datos PREVIO 
    --a la ejecución del triggering event.
--AFTER TRIGGER: lo mismo pero POSTERIOR.

--EJEMPLO POSTGRES:
CREATE TRIGGER trTitles
 AFTER--el trigger hara una evaluación luego de hacer el update
 UPDATE ON Titles

WHEN (date_part('year', now()) = '2015')
 EXECUTE PROCEDURE test200();

--En TSQL todos los triggers son AFTER, por eso la keyword FOR se sustituyo por AFTER.
GO
CREATE TRIGGER trTitles
 ON Titles
 AFTER UPDATE
 AS
 IF (YEAR(CURRENT_TIMESTAMP) = '2015')
 SELECT * INTO auditoria FROM titles 

------------------------------------------------------------------------------------------------
--GRANULARIDAD DEL TRIGGER
--si una sentencia afecto una o mas tuplas 
    --podemeos elegir si el trigger se ejecuta
    --una vez por tupla modificada o una vez que 
    --todas han sido modificadas 
--row-level trigger: se ejecuta una vez por tupla modficada.
--statemente-level trigger: se ejecuta una vez sin importar cuan tuplas
    --se hayan modificado.
--POSTGRES:
CREATE TRIGGER trTitles
 AFTER
 UPDATE ON Titles
 FOR EACH ROW--por cada fila (row-level)
--si no se pone nada es statemente-level
WHEN (date_part('year', now()) = '2015')
 EXECUTE PROCEDURE test200();

--TSQL no soporta row-level triggers

------------------------------------------------------------------------------------------------
--Triggering events de tipo UPDATE (POSTGRES)
--cuando el event es de tipo UPDATE podemos especificar
--una clausula adicional (opcional) para acotar 
--los atributos que deben ser modificados para que 
--el trigger sea activado:

--supongamos que queremos impedir que disminuyan los
--precios de las publicaciones.

CREATE TRIGGER trTitles2
 AFTER UPDATE OF price ON Titles --especificamos que 
 FOR EACH ROW--el update debe ser solo de las columnas
 WHEN (Condition)--listadas luego de OF.
 Action--si se necesita especificar más de una se pone ','.

--TSQL:no soporta la clausula OF, en cambio permite
--que dentro del cuerpo de la Action usemos la funcion
--UPDATE().UPDATE() que permite determinar si una columna
--dada ha sido afecta por un INSERT,DELETE o UPDATE.
--UPDATE(nombre-columna)
--nombre-columna es la columna para la cual se desea
--testear la existencia de modificaciones. La funcion
--devuelve verdadero si la columna ha sido afectada por 
--un INSERT o UPDATE.
--UPDATE() considera que la columna ha sido afectada por 
--un UPDATE cuando la clausula SET afecta a la columna.
--UPDATE() considera que la columna fue afectada por un INSERT
--cuando:
------------------------------------------------------------------------------------------------
--Valores de tuplas anteriores y posteriores
--los triggers permiten que tanto la Condition como la Action
--puedan hacer referencia a viejos y/o nuevos valores de tuplas
--en dependencia de las alteraciones del triggering event.

--POSTGRES: para acceder a estos valores se usa dos variables 
--de tipo RECORD:
--NEW: tiene la misma estructura que una tupla de la tabla asociada
--al trigger y contiene la NUEVA TUPLA para INSERT O UPDATE en 
--row-level triggers. Es NULL para operaciones DELETE.
--OLD: lo mismo pero contiene la tupla antigua. Esta variable 
--es NULL para events de tipo INSERT.
--Estas variables estan solo en row-level triggers

--En la Condition (en row-level triggers) que hagamos referencia
--a columnas nuevas y antiguas con OLD.nombreColumna y 
--NEW.nombreColumna. Por supuesto los INSERT no pueden referenciar
--a OLD y los DELETE a NEW. EJ:

CREATE FUNCTION test()
    RETURNS trigger
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
    BEGIN
        UPDATE Titles
            SET price = OLD.price
            WHERE title_id = NEW.title_id;
        RETURN NULL;
    END
    $$;
--cuando actualicen titles, chequear por tupla que el 
--precio viejo sea mayor al puesto luego de actualizar,
--y la trigger function tambien puede usar
CREATE TRIGGER trTitles3
    AFTER UPDATE OF price ON Titles
    FOR EACH ROW
    WHEN (OLD.price > NEW.price)
        EXECUTE PROCEDURE test();

--TSQL no permite acceso a la tupla antigua y a la nueva, pero
--tampoco tendria sentido porque no soporta row-level triggers
------------------------------------------------------------------------------------------------
--TRIGGERS BEFORE row-level
--en estos la Condition es evaluada sobre el estado de la base
--previo al triggering event, si es verdadera entonces la Action
--se ejecuta sobre ese estado.

--USO DE LOS TRIGGERS BEFORE row-level
--La idea de esto es darle al programador la posibilidad de 
--actuar en última instancia. Podemos distinguir dos maneras de actuar:

--Validación de datos entrantes:
    --en caso de FOR UPDATE o FOR INSERT, los triggers BEFORE 
    --permiten al desarrollador reaizar algun tipo de validación
    --sobre los valores entrantes.
    --En otras palabras, el desarrollador puede corregir o retocar
    --algo de las tuplas que forman parte del INSERT o UPDATE
    --antes de que se plasmen en la base.

--Cancelación lisa y llana de la transacción:
    --En FOR INSERT, FOR UPDATE o FOR DELETE, los triggers BEFORE
    --permiten realizar algun control o evaluación de alguna regla de
    --negocios compleja que no haya podido ser resuelta por constraint
    --En este caso, el trigger puede CANCELAR LA TRANSACCIÓN.

--En postgres se define el curso de accion a traves del valor 
    --retorno de la trigger function:

--A. Aprobar el triggering event sin intervenir
--se deja que el INSERT o UPDATE se lleve a cabo. El valor de retorno 
--de la trigger function debe ser la table row NEW.
--*si se trata de un DELETE y deseamos que el mismo ocurra el valor }
--de retorno de la trigger function no posee relevancia, pero debe 
--ser diferente de NULL. Normalmente se retorna la table row OLD.

--B. Aprobar el triggering event interviniendo
--Se quiere corregir algun aspecto de un INSERT o UPDATE antes
--de que entre en la base. Una vez realizada la intervención el
--valor de retorno de la trigger function puede ser la tupla NEW
--cambiada u otra completamente nueva con la misma estructura. EJ:
--Siempre se pone el valor 15 al insertar una nueva tupla en TITLES
CREATE FUNCTION test()
    RETURNS trigger
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
    BEGIN
        NEW.price:=15;
        RETURN NEW;
    END
    $$;
CREATE TRIGGER trTitles4
    BEFORE INSERT ON Titles
    FOR EACH ROW
    EXECUTE PROCEDURE test();

--EJEMPLO 2: ante la insercion de una nueva editorial, 
--registra fecha y hora de la operación y el usuario:

CREATE TRIGGER tr_Editoriales
    BEFORE
    INSERT
    ON publishers20
    FOR EACH ROW
    EXECUTE PROCEDURE test604();

CREATE OR REPLACE FUNCTION test604()
    RETURNS trigger
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
    --recTitle RECORD;
    BEGIN
        NEW.FechaHoraAlta := (SELECT CURRENT_TIMESTAMP);
        NEW.UsuarioAlta := SESSION_USER;
    RETURN NEW;
    END
    $$;

--C. Cancelar un triggering event
--Si deseamos cancelar el event para la tuppla actual, el valor
--de retorno de la trigger function debe ser NULL. Esto equivale 
--a deshacer la transacción. EJEMPLO:

--Se desea impedir que se den de alta publicaciones que no 
--hayan vendido por as de 2500

CREATE OR REPLACE FUNCTION test7000()
    RETURNS trigger
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
    BEGIN
        IF ((SELECT SUM(price*qty)
            FROM titles20 t INNER JOIN sales s
            ON t.title_id = s.title_id
            WHERE pub_id = NEW.pub_id) <= 2500) THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    END
    $$;

CREATE TRIGGER tr_ejercicio5
    BEFORE
    INSERT
    ON Titles20
    FOR EACH ROW
    EXECUTE PROCEDURE test7000();


--TSQL no permite BEFORE triggers, sin embargo proporciona la 
--posibilidad de cancelar la transacción.

------------------------------------------------------------------------------------------------
--Triggers AFTER
--la idea de estos es que el desarrollador pueda ejecutar alguna
--actividad asociada al event. Esta puede ser, por ejemplo, 
--el registro de la operación.
--El uso de los triggers es como herramienta de regisro o log. EJ:
--EJEMPLO: tenemos una tabla de registro (log):
CREATE TABLE Registro
(
    fecha DATE NULL,
    tabla varchar(100) NULL,
    operacion varchar(30) NULL,
    CantFilasAfectadas Integer NULL
)

--se registra en esta una entrada por cada DELETE que afecte
--más de una tupla
Go
CREATE TRIGGER tr_ejercicio9
    ON Employee
    AFTER
    DELETE
    AS
    DECLARE
    @CantFilas INTEGER;
    BEGIN
        SET @CantFilas = (SELECT COUNT(*) FROM deleted);
        IF (@CantFilas > 1)
            INSERT INTO Registro
            SELECT CURRENT_TIMESTAMP, 'Employee', 'DELETE', @CantFilas;
            --END IF;
    RETURN
END
------------------------------------------------------------------------------------------------
--Triggers after row-level
--El valor de retorno de una trigger function en un AFTER trigger
--row-level es ignorado. Puede ser NULL
--Statemente-level triggers 
--Creamos uno especificando la clausula FOR EACH STATEMENT

--Acceso a los valores de las tuplas anteriores y posteriores
--En postgres no se puede en un statement-level trigger.

--En TSQL se accede al conjunto de tuplas anteriores a traves 
--de una tabla virtual denominada DELETED y a las tuplas posteriores
--a traves de otra llamada INSERTED. Estas tablas son solo de lectura
--Inserted contiene las nuevas tuplas para INSERT o UPDATE.
--Deleted contiene las antiguas tuplas para UPDATE o DELETE.

--Valor de retorno en un statemente-level trigger: el valor de 
--retorno de su trigger function es ignorado. Pueder ser NULL.

------------------------------------------------------------------------------------------------
--Validación de datos entrantes en TSQL
--A. Aprobar el triggering event sin intervenir
--Equivale no hacer nada

--B.Aprobar el triggering event interviniendo
--si solo una tupla ha sido afectada, tendremos una tabla 
--INSERTED o DELETED con una unica tupla
--Sin embargo, TSQL no permite modificar estas tuplas.
--POR LO TANTO, los triggers NO PERMITEN intervenir modificando
--o ajustando algun aspecto de la tupla que esta por ser insertada
--o modificada. Tampoco permiten generar una tupla desde cero.

--C. Cancelar un triggering event
--Se utiliza ROLLBACK TRANSACTION:
GO
CREATE TRIGGER AveragePriceTrigger
    ON Titles
    AFTER UPDATE
    AS
        IF(15 < (SELECT AVG(price) FROM Titles))
        ROLLBACK TRANSACTION
------------------------------------------------------------------------------------------------
--Eliminar triggers
--TSQL: DROP TRIGGER nombreTrigger
--Postgres: DROP TRIGGER nombreTrigger ON TablaAsociada
------------------------------------------------------------------------------------------------
--Información disponible en triggers PL/pgSQL
-- En una trigger function PL/PgSQL disponemos de una variable de tipo text
-- llamada TG_OP. Esta variable posee un valor string “INSERT”, “UPDATE” o
-- “DELETE” indicando cuál fue el triggering event que desencadenó el trigger.
-- Otras variables que pueden resultar útiles son las siguientes:
-- TG_NAME proporciona el nombre del trigger en ejecución.
-- TG_WHEN proporciona el tipo de trigger: BEFORE, AFTER o INSTEAD OF.
-- TG_LEVEL proporciona la granularidad del trigger: ROW o STATEMENT.
-- TG_TABLENAME proporciona el nombre de la tabla a la cual está asociada el
-- trigger.
