--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------ejercicio 1-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--creacion de base de datos (a)

CREATE DATABASE grupo8;

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

