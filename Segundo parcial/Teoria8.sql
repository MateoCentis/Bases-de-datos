--Configuracion de transacciones

--Transacciones en SQL

--1. Transaccion implicita
--Toda transaccion tiene un begin transaction y un commit

--2. Transaccion explicita
--se tiene en cuenta ademas el rollback, que tiene en cuenta a todos los problemas que pueden surgir
--entre dos puntos seguros de la base de datos.
--el COMMIT significa que la base de datos vuelve a estar en un estado CONSISTENTE.
--ROLLBACK no necesariamente vuelve a un estado CONSISTENTE.

--3. Atomicidad de una transacción
--Responsabilidad del programador. La serie de pasos dentro de una transaccion se ejecutan todos o 
--no se ejecutan. No pueden ejecutarse algunos y otros no. 

--4. Durabilidad de una transacción
--Le corresponde al motor de base de datos. Significa que las transacciones deben ser permanentes.
--esto lo garantiza con automatic rollback y write-ahead logging.

--5. Consistencia de una transacción
--refiere a que los datos deben ser logicamente correctos segúna las reglas de integridad. Ej: si sale dinero de una
--cuenta bancaria A debe ingresar a otra B.

--6. El problema de la concurrencia
--Dos operaciones simultáneas sobre la misma base de datos.

--6.1 - Inviabilidad de la ejecución serial
--Las trasacciones son ejecutadas solapadas en el tiempo ya que este enfoque es el único viable en cuanto a eficiencia

--6.2 - Isolation
--Cuando una transaccion A y una B se ejecutan de manera concurrente, A no debe ver los cambios incompletos en B y B no debe
--ver los cambios incompletos realizados en A. (una transaccion no debe poder ver los cambios intermedios de otra transaccion).
--ya que si se hace un rollback estariamos tomandos decisiones sobre una mentira.

--6.3 - Situaciones derivadas de la concurrencia

--6.3.1 - Lost updates
--

--6.3.2 - Dirty reads
--es cuando una transaccion puede ver cambios incompletos sobre otra transacciono (leer algo que no se sabe si es cierto aun)

--Un proceso que esta actualizando datos no tiene control sobre otros que pretender leer estos datos aun basura. Pero el que lee
--si puede proteger la lectura.

--6.3.3 - non repeatable reads
--es cuando se hace una lectura, se pueda proteger esta lectura, de forma tal que al mostrar los datos estos no puedan ser modificados 
--(bloquear datos al mostrarlos en un SELECT)

--6.3.4 phantom reads
--Lo mismo pero aparece una más en vez que desaparezca. (BLOQUEAR al mostrar datos)

-- 6.4. Isolation levels ANSI SQL
--va en diferentes niveles de ejecucion en serie

--6.4.1 Isolation level serializable
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--Las transacciones se ejecutan en serie. No admite lost updatess, dirty read ni non-repeatable o phantom read.

--6.4.2 Isolation level read-uncommited
----se permiten los diry reads
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITED;
--6.4.3 - Isolation level repeatable-read
--Mientras se muestra un query A, este no puede ser modificado por otro query.
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- 6.4.4. Isolation level Read Committed
--no admiten diry reads, pero si repeatble-read y phantom reads.
SET TRANSACTION ISOLATION LEVEL READ COMMITED;

---------------------------------------------------------Teoria seguridad-----------------------------------------------------------
--Permisos sobre relaciones 


--Login id vs usuario
CREATE LOGIN curso--login accede al motor de base de datos pero no tiene accesos a ninguna base en especifico
    WITH PASSWORD = 'pass'
    DEFAULT_DATABASE = Alumnado;

CREATE USER curso
    FOR LOGIN curso



