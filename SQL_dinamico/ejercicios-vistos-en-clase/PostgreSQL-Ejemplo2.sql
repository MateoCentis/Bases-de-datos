-- Ejemplo 2: Mostrar en PostgreSQL una columna de una tabla, ambos variables

select * from authors

drop function columnaDeTabla(varchar,varchar)
CREATE OR REPLACE FUNCTION columnaDeTabla(varchar,varchar) RETURNS SETOF varchar
as
$BODY$
DECLARE
v_cadena VARCHAR(100);
v_nomTabla VARCHAR(30) := $1;
v_nomColumna VARCHAR(30) := $2;
BEGIN
v_cadena := 'SELECT ' || v_nomColumna;
v_cadena = v_cadena || ' FROM ' || v_nomTabla;
RAISE NOTICE 'v_cadena: %', v_cadena;
RETURN QUERY EXECUTE v_cadena;
END;
$BODY$
language plpgsql;

select columnaDeTabla('authors','address')

-- Mostrar limitaciones de esta versión de función
