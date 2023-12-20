--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ejercicio 1-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--creacion de base de datos (a)

--CREATE DATABASE grupo8;

--creacion de tablas  b)

--niveles: 
    --1: departamento, tarjeta, area
    --2: persona, dispositivo
    --3: huella, habilitacion, evento

--TABLA area (1).                           
CREATE TABLE area(
   idArea               INT8                 NOT NULL,
   codigoarea           INT4                 NOT NULL,
   nombrearea           VARCHAR(40)          NOT NULL,
   idareanivelsuperior  INT8                 NULL,
   CONSTRAINT pk_area PRIMARY KEY (idArea),
   CONSTRAINT uk_area UNIQUE (codigoarea),
   CONSTRAINT fk_area_area FOREIGN KEY (idareanivelsuperior)
      REFERENCES area (idArea)
);

--TABLA departamento (1).
CREATE TABLE departamento (
   idDepartamento       INT8                 NOT NULL,
   iddeptonivelsuperior INT8                 NULL,
   codigodepto          INT4                 NOT NULL,
   nombredepto          VARCHAR(40)          NOT NULL,
   CONSTRAINT pk_departamento PRIMARY KEY (idDepartamento),
   CONSTRAINT uk_departamento UNIQUE (codigodepto),
   CONSTRAINT fk_departamento_departamento FOREIGN KEY (iddeptonivelsuperior)
      REFERENCES departamento (idDepartamento)
);


--TABLA tarjeta (1).                                               
CREATE TABLE tarjeta (
   idTarjeta            INT8                 NOT NULL,
   numerotarjeta        INT8                 NOT NULL,
   tipodispositivo      VARCHAR(15)          NOT NULL,
   fechabaja            DATE                 NULL,
   CONSTRAINT pk_tarjeta PRIMARY KEY (idTarjeta),
   CONSTRAINT ak_key_2_tarjeta UNIQUE (numerotarjeta)
);


--TABLA dispositivo (2).
CREATE TABLE dispositivo (
   idDispositivo        INT8                 NOT NULL,
   nombrepuerta         VARCHAR(20)          NOT NULL,
   numeroserie          VARCHAR(20)          NOT NULL,
   ip                   VARCHAR(15)          NOT NULL,
   puerto               INT4                 NOT NULL,
   status               INT4                 NULL,
   id_area              INT8                 NOT NULL,
   modelo               VARCHAR(20)          NULL DEFAULT 'Desconocido',
   versionfirmware      VARCHAR(20)          NOT NULL,
   fechainstalac        DATE                 NULL DEFAULT '2022/01/01',
   fechabaja            DATE                 NULL,
   CONSTRAINT pk_dispositivo PRIMARY KEY (idDispositivo),
   CONSTRAINT uk_dispositivo UNIQUE (nombrepuerta),
   CONSTRAINT uk_numserie_dispositivo UNIQUE (numeroserie),
   CONSTRAINT uk_ip_dispositivo UNIQUE (ip),
   CONSTRAINT fk_dispositivo_area FOREIGN KEY (id_area)
      REFERENCES area (idArea)
);


--TABLA persona (2).                                          
CREATE TABLE persona (
   idDepartamento       INT8                 NOT NULL,
   documento            INT8                 NOT NULL,
   id_tarjeta           INT8                 NOT NULL,
   apellidonombre       VARCHAR(100)         NOT NULL,
   fechabaja            DATE                 NULL,
   telefono             VARCHAR(20)          NULL,
   telefonomovil        VARCHAR(20)          NULL,
   fechanacimiento      DATE                 NULL,
   correoelectronico    VARCHAR(60)          NULL,
   genero               CHAR(1)              NULL,
   observaciones        VARCHAR(256)         NULL,
   CONSTRAINT pk_persona PRIMARY KEY (idDepartamento),
   CONSTRAINT fk_persona_departamento FOREIGN KEY (idDepartamento)
      REFERENCES departamento (idDepartamento),
   CONSTRAINT uk_card_persona UNIQUE (id_tarjeta),
   CONSTRAINT fk_persona_tarjeta FOREIGN KEY (id_tarjeta)
      REFERENCES tarjeta (idTarjeta),
   CONSTRAINT uk_pin_persona UNIQUE (documento)
);



--TABLA evento (3).
CREATE TABLE evento (
   id                   INT8                 NOT NULL,
   id_evento            INT8                 NOT NULL,
   id_dispositivo       INT8                 NOT NULL,
   momento              TIMESTAMP            NOT NULL,
   tipoevento           VARCHAR(20)          NOT NULL,
   observaciones        VARCHAR(200)         NULL,
   id_persona           INT8                 NULL,
   CONSTRAINT pk_evento PRIMARY KEY (id),
   CONSTRAINT uk_evento_evento UNIQUE (id_evento),
   CONSTRAINT fk_evento_dispositivo FOREIGN KEY (id_dispositivo)
      REFERENCES dispositivo (idDispositivo),
   CONSTRAINT fk_evento_persona FOREIGN KEY (id_persona)
      REFERENCES persona (idDepartamento)
);


--TABLA habilitacion (3).
CREATE TABLE habilitacion (
   idHabilitacion       INT8                 NOT NULL,
   id_persona           INT8                 NOT NULL,
   id_dispositivo       INT8                 NOT NULL,
   tipoacceso           VARCHAR(20)          NOT NULL,
   fechadesde           DATE                 NOT NULL,
   fechahasta           DATE                 NULL,
   CONSTRAINT pk_habilitacion PRIMARY KEY (idHabilitacion),
   CONSTRAINT uk_habilitacion UNIQUE (id_persona, id_dispositivo),
   CONSTRAINT fk_habilitacion_persona FOREIGN KEY (id_persona)
      REFERENCES persona (idDepartamento),
   CONSTRAINT fk_habilitacion_dispositivo FOREIGN KEY (id_dispositivo)
      REFERENCES dispositivo (idDispositivo),
   CONSTRAINT ckc_tipoacceso_habilita CHECK (tipoacceso in ('Temporario','Permanente'))
);

--TABLA huella.
CREATE TABLE huella (
   idHuella             INT8                 NOT NULL,
   id_persona           INT8                 NOT NULL,
   numerodedo           INT2                 NOT NULL,
   huella               text                 NOT NULL,
   CONSTRAINT pk_huella PRIMARY KEY (idHuella),
   CONSTRAINT fk_huella_persona FOREIGN KEY (id_persona)
      REFERENCES persona (idDepartamento),
   CONSTRAINT uk_huella UNIQUE (id_persona, numerodedo)
);

--creacion de indices necesarias para cada tabla
CREATE INDEX idx_AreaNivelSuperior ON area(idareanivelsuperior);
CREATE INDEX idx_DeptoNivelSuperior ON departamento(iddeptonivelsuperior);
CREATE INDEX idx_Dispositivo_Area ON dispositivo(id_area);
CREATE INDEX idx_Evento_Dispositivo ON evento(id_dispositivo);
CREATE INDEX idx_Evento_Persona ON evento(id_persona);


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

--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ejercicio 3-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------


-- DROPEO LAS FOREIGN KEY
ALTER TABLE departamento DROP CONSTRAINT fk_departamento_departamento;
ALTER TABLE persona DROP CONSTRAINT fk_persona_departamento;
ALTER TABLE area DROP CONSTRAINT fk_area_area;
ALTER TABLE dispositivo DROP CONSTRAINT fk_dispositivo_area;

ALTER TABLE huella DROP CONSTRAINT fk_huella_persona;
ALTER TABLE evento DROP CONSTRAINT fk_evento_persona;
ALTER TABLE habilitacion DROP CONSTRAINT fk_habilitacion_persona;


-- DROPEO LOS ÍNDICES QUE REFERENCIAN LAS FOREIGN KEY
DROP INDEX idx_DeptoNivelSuperior;
DROP INDEX idx_AreaNivelSuperior;
DROP INDEX idx_Dispositivo_Area;

DROP INDEX idx_Evento_Persona;

-- DROP DE LAS PRIMARY KEYS DE ID
ALTER TABLE departamento DROP CONSTRAINT pk_departamento;
ALTER TABLE area DROP CONSTRAINT pk_area;

ALTER TABLE persona DROP CONSTRAINT pk_persona;

-- DROPEO LAS UK CONSTRAINT
ALTER TABLE departamento DROP CONSTRAINT uk_departamento;
ALTER TABLE area DROP CONSTRAINT uk_area;

ALTER TABLE huella DROP CONSTRAINT uk_huella;
ALTER TABLE habilitacion DROP CONSTRAINT uk_habilitacion;

-- AGREGO LAS COLUMNAS DE FK COMO CN
ALTER TABLE departamento
  ADD COLUMN codigoDeptoNivelSuperior int4 null;
ALTER TABLE persona
  ADD COLUMN codigoDepto int4 not null;
ALTER TABLE area
  ADD COLUMN codigoAreaNivelSuperior int4 null;
ALTER TABLE dispositivo
  ADD COLUMN codigoArea int4 not null DEFAULT 0; 

ALTER TABLE huella
  ADD COLUMN codigoDepto int4 not null;
ALTER TABLE evento
  ADD COLUMN codigoDepto int4 not null;
ALTER TABLE habilitacion
  ADD COLUMN codigoDepto int4 not null;

-- AGREGO LAS PRIMARY KEYS CON CN
ALTER TABLE departamento
  ADD CONSTRAINT pk_departamento PRIMARY KEY (codigodepto);
ALTER TABLE area
  ADD CONSTRAINT pk_area PRIMARY KEY (codigoarea);

ALTER TABLE persona
  ADD CONSTRAINT pk_persona PRIMARY KEY (codigoDepto);




-- FUNCION QUE TRANSFORMA LOS DATOS DE FK
UPDATE dispositivo
SET codigoarea = area.codigoarea
FROM area
WHERE dispositivo.id_area = area.idarea;

UPDATE area
SET codigoareanivelsuperior = a.codigoarea
FROM area a
WHERE area.idareanivelsuperior = a.idarea;

UPDATE departamento
SET codigodeptonivelsuperior = d.codigodepto
FROM departamento d
WHERE departamento.iddeptonivelsuperior = d.iddepartamento;

UPDATE persona
SET codigodepto = departamento.codigodepto
FROM departamento
WHERE persona.iddepartamento = departamento.iddepartamento;


-- DROPEO LAS ID QUE ESTABAN COMO FK 
ALTER TABLE departamento
  DROP COLUMN iddeptonivelsuperior;
ALTER TABLE persona
  DROP COLUMN idDepartamento;
ALTER TABLE area
  DROP COLUMN idareanivelsuperior;
ALTER TABLE dispositivo
  DROP COLUMN id_area;
ALTER TABLE departamento
  DROP COLUMN idDepartamento;
ALTER TABLE area
  DROP COLUMN idArea;

ALTER TABLE huella
  DROP COLUMN id_persona;
ALTER TABLE evento
  DROP COLUMN id_persona;
ALTER TABLE habilitacion
  DROP COLUMN id_persona;

-- AGREGO LAS CN COMO FK
ALTER TABLE departamento
  ADD CONSTRAINT fk_departamento_departamento FOREIGN KEY (codigodeptonivelsuperior)
    REFERENCES departamento (codigodepto);
ALTER TABLE persona
  ADD CONSTRAINT fk_persona_departamento FOREIGN KEY (codigoDepto)
    REFERENCES departamento (codigodepto);
ALTER TABLE area
  ADD CONSTRAINT fk_area_area FOREIGN KEY (codigoAreaNivelSuperior)
    REFERENCES area(codigoArea);
ALTER TABLE dispositivo
  ADD CONSTRAINT fk_dispositivo_area FOREIGN KEY (codigoArea)
    REFERENCES  Area(codigoArea);

ALTER TABLE huella
  ADD CONSTRAINT fk_huella_persona FOREIGN KEY (codigoDepto)
    REFERENCES persona (codigodepto);

ALTER TABLE evento
  ADD CONSTRAINT fk_evento_persona FOREIGN KEY (codigoDepto)
    REFERENCES persona (codigodepto);

ALTER TABLE habilitacion
  ADD CONSTRAINT fk_habilitacion_persona FOREIGN KEY (codigoDepto)
    REFERENCES persona (codigodepto);

-- DROPEO LAS COLUMNAS CON ID


-- AGREGO LOS UK
ALTER TABLE huella
  ADD CONSTRAINT uk_huella UNIQUE (codigodepto,numeroDedo);
ALTER TABLE habilitacion
  ADD CONSTRAINT uk_habilitacion UNIQUE (codigodepto,id_dispositivo);

-- AGREGO INDICES QUE BORRÉ ANTES PERO AHORA CON CN
CREATE INDEX idx_departamento_departamento ON departamento (codigoDeptoNivelSuperior);
CREATE INDEX idx_area_area ON area (codigoAreaNivelSuperior);
CREATE INDEX idx_dispositivo_area ON dispositivo (codigoArea);
CREATE INDEX idx_evento_persona ON evento (codigoDepto);

--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ejercicio 4-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE asignacion (
   id_tarjeta           INT8                 NOT NULL,
   id_persona           INT8                 NOT NULL,
   fechaAsignacion      DATE                 NOT NULL,
   fechaBaja            DATE                 NULL,
   CONSTRAINT pk_asignacion PRIMARY KEY (id_tarjeta,id_persona),
   CONSTRAINT fk_asignacion_tarjeta FOREIGN KEY (id_tarjeta)
      REFERENCES tarjeta (idTarjeta ),
   CONSTRAINT fk_asignacion_persona FOREIGN KEY (id_persona)
      REFERENCES persona (codigodepto)
);
