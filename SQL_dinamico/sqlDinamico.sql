---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------primera parte-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--DECLARE
@fechaInicio datetime = '1992-03-01',
@fechaFin datetime = '1993-06-01',
@fecha datetime,
@col varchar(30),
@sqldin varchar(300),
@sqldin_mes varchar(500),
@tituloini varchar(80),
@sqldin_c varchar(500);
-- Creación de tabla
CREATE TABLE titulos_por_mes 
(
    titulo varchar(80)
)
-- Cursor para cargar títulos
DECLARE cur_carga_titulos CURSOR FOR
SELECT distinct t.title
FROM sales s inner join titles t ON t.title_id = s.title_id
WHERE s.ord_date between @fechaInicio and @fechaFin
ORDER BY t.title

set @sqldin = 'insert into titulos_por_mes values ('
OPEN cur_carga_titulos
FETCH NEXT FROM cur_carga_titulos INTO @tituloini

WHILE @@fetch_status = 0
BEGIN
    set @sqldin_c = @sqldin + CHAR(39) + @tituloini + CHAR(39) + ')'
    exec(@sqldin_c)
    FETCH NEXT FROM cur_carga_titulos INTO @tituloini
END
CLOSE cur_carga_titulos

-- While para agregar columnas
SET @sqldin = 'alter table titulos_por_mes add '
SELECT @fecha = @fechaInicio;

WHILE (@fecha <= @fechaFin)
BEGIN
    set @col = convert(varchar(4),YEAR(@fecha)) + '-' + convert(varchar(2),MONTH(@fecha));
    set @fecha = DATEADD(month,1,@fecha)
    set @sqldin_mes = ''
    set @sqldin_mes = @sqldin + '"' + @col + '" smallint'
    exec(@sqldin_mes)
END

SELECT * FROM titulos_por_mes

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------segunda parte-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
DECLARE
    @titulo varchar(80),
    @mes varchar(30),
    @cant smallint,
    @sqldin2 varchar(300),
    @sqldin_cant varchar(500);

DECLARE cur_titulos CURSOR FOR
    SELECT t.title, convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date)), SUM(qty)
    FROM sales s INNER JOIN titles t ON t.title_id = s.title_id
    WHERE s.ord_date BETWEEN @fechaInicio and @fechaFin
    GROUP BY t.title, convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date))
    ORDER BY t.title,convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date))

OPEN cur_titulos
SET @sqldin2 = 'update titulos_por_mes set '
FETCH NEXT FROM cur_titulos INTO @titulo,@mes,@cant
WHILE @@fetch_status = 0
BEGIN
    SET @sqldin_cant =@sqldin2 + '"' + @mes + '"' + ' = ' + convert(varchar(5),@cant) + 
    ' where titulo = ' + CHAR(39) + @titulo + char(39)--char(39) es igual a poner una comilla simple '
    exec(@sqldin_cant)
    FETCH NEXT FROM cur_titulos INTO @titulo,@mes,@cant
END

CLOSE cur_titulos
DEALLOCATE cur_titulos
SELECT * FROM titulos_por_mes