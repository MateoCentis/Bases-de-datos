/*hacer scripts ddl para la creacion de tablas correspondientes*/
create table Actuacion
(
  idActuacion smallint not null,
  nroactua smallint not null,
  anioactua smallint not null,
  glose_idActuacion smallint null,
  fechactua date not null,
  constraint PK_actuacion primary key (idActuacion),
  constraint UK_actuacion unique (nroactua,anioactua),
  constraint FK_actuacion foreign key (glose_idActuacion) references Actuacion(idActuacion)
);

create table Oficina
(
  idofi smallint not null,
  idnivel smallint not null,
  idemple smallint not null,
  idOfiDepende smallint null,
  nomofi char(40) not null,
  constraint PK_oficina primary key (idofi),
  constraint FK_nivel foreign key (idnivel) references Nivel(idnivel),
  constraint UK_nivel unique (idnivel),
  constraint FK_empleado foreign key (idemple) references Empleado(idemple),
  constraint idOfiDepende foreign key (idOfiDepende) references Oficina(idofi)
);


create table Movimiento
(
  idMovimiento smallint not null,
  nromov smallint not null,
  idofi smallint not null,
  idActuacion smallint not null,
  feingreso date not null,
  prioridad char(2) not null,
  oberv varchar(255) null,
  fesalida date null,
  constraint PK_movimiento primary key (idMovimiento),
  constraint UK_movimiento unique (nromov),
  constraint FK_oficina foreign key (idofi) references Oficina(idofi),
  constraint FK_actuacion foreign key (idActuacion) references Actuacion(idActuacion),
  constraint CKC_prioridad check (prioridad in ('AL','ME','BA'))
);

create table Persona
(
  idPersona smallint not null,
  tipodocu char(1) not null,
  nrodocu smallint not null,
  idLoca smallint not null,
  apenom char(40) not null,
  domiper char(40) not null,
  constraint PK_persona primary key (idPersona),
  constraint UK_persona unique (tipodocu,nrodocu),
  constraint FK_localidad foreign key (idLoca) references Localidad(idLoca),
  constraint CKC_tipoDocumento check (tipodocu in ('1','2','3','4','5','6'))
);
/*3 codificar las operaciones con DML */
alter table Persona
  add column idLocalidadNacio smallint not null;

alter table Persona
  add constraint FK_localidadNacio foreign key (idLocalidadNacio) references Localidad(idLoca);

update Persona 
  set idLocalidadNacio = idLoca;

/*4 es con DML*/
/*5*/
create table persona(
  tipo_documento smallint constraint chk_tipo_documento check tipo
(tipo between 1 and 3),
  numero_documento integer,
  constraint pk_persona primary key
(tipo_documento,numero_documento)
);

create table profesor
(
  nro_legajo integer,
  tipo_documento smallint not null,
  numero_documento integer not null,
  constraint pk_profesor primary key (nro_legajo),
  constraint fk_profesor_persona foreign key (tipo_documento,numero_documento) 
    references persona(tipo_documento,numero_documento)
)

alter table persona
  drop constraint chk_tipo_documento;

update persona
  set tipo_documento = 'DNI'
    where tipo_documento = '1';

update persona
  set tipo_documento = 'LE'
    where tipo_documento = '2';

update persona
  set tipo_documento = 'LC'
    where tipo_documento = '3';

update profesor
  set tipo_documento = 'DNI'
    where tipo_documento = '1';

update profesor
  set tipo_documento = 'LE'
    where tipo_documento = '2';

update profesor
  set tipo_documento = 'LC'
    where tipo_documento = '3';

alter table persona
  add constraint CKC_tipodocumento check (tipo_documento in ('DNI','LE','LC'))

