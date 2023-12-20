
--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ejercicio 2-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE area2(
   idArea               INT8                 NOT NULL,
   codigoarea           INT4                 NOT NULL,
   desuso               char(1)              NULL,
   nombrearea           VARCHAR(40)          NOT NULL,
   idareanivelsuperior  INT8                 NULL
);

COPY area2(idArea,codigoarea,desuso,nombrearea,idareanivelsuperior) FROM 'C:\TP1-V2007\areaB.csv' DELIMITER '	' CSV HEADER;

INSERT INTO area (SELECT idArea,codigoarea,nombrearea,idareanivelsuperior FROM area2);  

DROP TABLE area2;

--datos para departamento
CREATE TABLE departamento2(
   idDepartamento       INT8                 NOT NULL,
   iddeptonivelsuperior INT8                 NULL,
   desuso               INT                  NULL,
   codigodepto          INT4                 NOT NULL,
   nombredepto          VARCHAR(40)          NOT NULL
);

COPY departamento2(idDepartamento,iddeptonivelsuperior,desuso,codigodepto,nombredepto) FROM 'C:\TP1-V2007\departamentoB.csv' DELIMITER '	' CSV HEADER;


INSERT INTO departamento (SELECT idDepartamento,iddeptonivelsuperior,codigodepto,nombredepto FROM departamento2);  

DROP TABLE departamento2;

CREATE TABLE dispositivoB(
   idDispositivo        INT8                 NOT NULL,
   nombrepuerta         VARCHAR(20)          NOT NULL,
   numeroserie          VARCHAR(20)          NOT NULL,
   ip                   VARCHAR(15)          NOT NULL,
   puerto               INT4                 NOT NULL,
   status               INT4                 NULL,
   id_area              INT8                 NOT NULL,
   modelo               VARCHAR(20)          NULL,
   versionfirmware      VARCHAR(20)          NOT NULL,
   reservado            CHAR(1)              NULL,
   fechainstalac        DATE                 NULL,
   fechabaja            DATE                 NULL   
);

COPY dispositivoB(idDispositivo,nombrepuerta,numeroserie,ip,puerto,status,id_area,modelo,versionfirmware,reservado,fechainstalac,fechabaja)
 FROM 'C:\TP1-V2007\dispositivoB.csv' DELIMITER '	' CSV HEADER;

INSERT INTO dispositivo(idDispositivo,nombrepuerta,numeroserie,ip,puerto,status,id_area,versionfirmware,fechabaja)
	(SELECT idDispositivo,nombrepuerta,numeroserie,ip,puerto,status,id_area,versionfirmware,fechabaja FROM dispositivob);  

DROP TABLE dispositivoB;
