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