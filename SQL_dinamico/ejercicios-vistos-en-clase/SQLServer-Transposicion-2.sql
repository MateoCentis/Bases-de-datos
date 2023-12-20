-- Ejemplo de transposici�n
-- Salida variable

-- PARTE 1:
-- DROP TABLE titulos_por_mes
set dateformat ymd;
declare 
@fechaInicio datetime = '1992-03-01',
@fechaFin datetime = '2021-12-01',
@fecha datetime,
@col varchar(30),
@sqldin varchar(300),
@sqldin_mes varchar(500);

create table titulos_por_mes
(titulo varchar(80), title_id varchar(6))

insert into titulos_por_mes
select distinct t.title,t.title_id 
from sales s inner join titles t ON t.title_id = s.title_id
where s.ord_date between @fechaInicio and @fechaFin
order by t.title

set @sqldin = 'alter table titulos_por_mes add '
select @fecha = @fechaInicio;
while (@fecha <= @fechaFin)
begin
   set @col = convert(varchar(4),YEAR(@fecha)) + '-' + convert(varchar(2),MONTH(@fecha));
   set @fecha = DATEADD(month,1,@fecha)
   set @sqldin_mes = ''
   set @sqldin_mes = @sqldin + '"' + @col + '" smallint '
   print @sqldin_mes
   exec(@sqldin_mes) 
end
-- Mostrar resultados obtenidos
select * from titulos_por_mes

---
-- PARTE 2:
set dateformat ymd;
declare 
@fechaInicio datetime = '1992-03-01',
@fechaFin datetime = '2021-12-01',
@titulo varchar(80),
@title_id varchar(6),
@mes varchar(30),
@cant smallint,
@sqldin2 varchar(300),
@sqldin_cant varchar(500);

declare cur_titulos cursor for
select t.title, t.title_id,convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date)), SUM(qty)
from sales s inner join titles t ON t.title_id = s.title_id
where s.ord_date between @fechaInicio and @fechaFin
group by t.title, t.title_id,convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date)) 
order by  t.title,t.title_id,convert(varchar(4),YEAR(ord_date)) + '-' + convert(varchar(2),MONTH(ord_date))  
open cur_titulos
set @sqldin2 = 'update titulos_por_mes set '
FETCH NEXT FROM cur_titulos INTO @titulo,@title_id,@mes,@cant 
WHILE @@fetch_status = 0
BEGIN
    set @sqldin_cant =@sqldin2 + '"' + @mes + '"' + ' = ' + convert(varchar(5),@cant) + ' where title_id = ' + CHAR(39) + @title_id + char(39);
    print @sqldin_cant;
    exec(@sqldin_cant);
    FETCH NEXT FROM cur_titulos INTO @titulo,@title_id,@mes,@cant ;
END
CLOSE cur_titulos
deallocate cur_titulos

-- Mostrar resultados obtenidos
select * from titulos_por_mes
