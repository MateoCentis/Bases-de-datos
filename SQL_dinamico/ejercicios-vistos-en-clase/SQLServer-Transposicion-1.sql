-- Ejemplo de transposici�n
-- Salida en formato convencional
SELECT t.title AS Titulo, YEAR(s.ord_date) as ANIO, MONTH(s.ord_date) AS MES, SUM(s.qty) AS Cantidad
FROM sales s inner join titles t ON t.title_id = s.title_id
GROUP BY t.title,YEAR(s.ord_date),month(s.ord_date)
ORDER BY 1,2,3

-- Carga de datos de prueba
select * from titles where title like '%You Can%'
select * from sales where title_id ='BU2075'

set dateformat ymd
insert into sales values (6380,678001,'2021-11-01',6,'Contado','BU1032')
insert into sales values (6380,678002,'2021-11-07',7,'Contado','BU1032')
insert into sales values (6380,678003,'2021-11-08',8,'Contado','BU1032')

insert into sales values (6380,678004,'2021-11-10',5,'Contado','BU2075')
insert into sales values (6380,678005,'2021-03-08',4,'Contado','BU2075')
insert into sales values (6380,678006,'2021-06-08',3,'Contado','BU2075')
--

-- Limitado a una cantidad fija de columnas
-- En este caso limitamos por año
SELECT t.title  AS Titulo,
 sum(CASE WHEN month(ord_date) = 1 THEN qty ELSE 0 END) AS Ene,
 sum(CASE WHEN month(ord_date) = 2 THEN qty ELSE 0 END) AS Feb,
 sum(CASE WHEN month(ord_date) = 3 THEN qty ELSE 0 END) AS Mar,
 sum(CASE WHEN month(ord_date) = 4 THEN qty ELSE 0 END) AS Abr,
 sum(CASE WHEN month(ord_date) = 5 THEN qty ELSE 0 END) AS May,
 sum(CASE WHEN month(ord_date) = 6 THEN qty ELSE 0 END) AS Jun,
 sum(CASE WHEN month(ord_date) = 7 THEN qty ELSE 0 END) AS Jul,
 sum(CASE WHEN month(ord_date) = 8 THEN qty ELSE 0 END) AS Ago,
 sum(CASE WHEN month(ord_date) = 9 THEN qty ELSE 0 END) AS Sep,
 sum(CASE WHEN month(ord_date) = 10 THEN qty ELSE 0 END) AS Oct,
 sum(CASE WHEN month(ord_date) = 11 THEN qty ELSE 0 END) AS Nov,
 sum(CASE WHEN month(ord_date) = 12 THEN qty ELSE 0 END) AS Dic
FROM sales s inner join titles t on t.title_id = s.title_id
WHERE YEAR(ord_date)=2021
GROUP BY t.title 
ORDER BY t.title