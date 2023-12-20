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
