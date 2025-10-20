USE GD2C2025;
GO

-- Crear esquema del grupo
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'INSERT_PROMOCIONADOS')
    EXEC('CREATE SCHEMA INSERT_PROMOCIONADOS');
GO


CREATE TABLE INSERT_PROMOCIONADOS.medio_pago(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  medio  VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.periodo(
  id   BIGINT IDENTITY(1,1) PRIMARY KEY,
  mes  INT  NOT NULL,
  anio INT  NOT NULL,
  CONSTRAINT ck_periodo_mes  CHECK (mes BETWEEN 1 AND 12),
  CONSTRAINT uq_periodo UNIQUE (mes, anio)
);  

CREATE TABLE INSERT_PROMOCIONADOS.dias(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.turno(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  turno  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.categoria(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE INSERT_PROMOCIONADOS.estado_inscripcion(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  estado VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.provincia(
  id            BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre        VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.localidad(
  id            BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre        VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.ubicacion(
  id            BIGINT IDENTITY(1,1) PRIMARY KEY,
  direccion     VARCHAR(255) NOT NULL,
  provincia_id  BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.provincia(id),
  localidad_id  BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.localidad(id)
);

CREATE TABLE INSERT_PROMOCIONADOS.sede(
  id            BIGINT IDENTITY(1,1) PRIMARY KEY,
  razon_social  VARCHAR(255) NOT NULL,
  cuit          VARCHAR(255) NOT NULL,
  nombre        VARCHAR(255) NOT NULL UNIQUE,
  ubicacion_id  BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.ubicacion(id),
  telefono      VARCHAR(255),
  mail          VARCHAR(255)
);


CREATE TABLE INSERT_PROMOCIONADOS.profesor(
  id           BIGINT IDENTITY(1,1) PRIMARY KEY,
  dni          VARCHAR(48)  NOT NULL,
  nombre       VARCHAR(255) NOT NULL,
  apellido     VARCHAR(255) NOT NULL,
  ubicacion_id BIGINT NOT NULL
               REFERENCES INSERT_PROMOCIONADOS.ubicacion(id),
  telefono     VARCHAR(255),
  mail         VARCHAR(255)
);

CREATE TABLE INSERT_PROMOCIONADOS.alumno(
  legajo       BIGINT       PRIMARY KEY,
  dni          BIGINT       NOT NULL,
  nombre       VARCHAR(255) NOT NULL,
  apellido     VARCHAR(255) NOT NULL,
  ubicacion_id BIGINT NOT NULL
               REFERENCES INSERT_PROMOCIONADOS.ubicacion(id),
  telefono     VARCHAR(255),
  mail         VARCHAR(255)
);


CREATE TABLE INSERT_PROMOCIONADOS.curso(
  id              BIGINT IDENTITY(1,1) PRIMARY KEY,
  sede_id         BIGINT NOT NULL
                  REFERENCES INSERT_PROMOCIONADOS.sede(id),
  profesor_id     BIGINT NOT NULL
                  REFERENCES INSERT_PROMOCIONADOS.profesor(id),
  categoria_id    BIGINT NULL
                  REFERENCES INSERT_PROMOCIONADOS.categoria(id),
  descripcion     VARCHAR(480) NOT NULL,
  fecha_inicio    DATE   NOT NULL,
  fecha_fin       DATE   NOT NULL,
  duracion_meses  INT    NOT NULL,
  turno_id        BIGINT NOT NULL
                  REFERENCES INSERT_PROMOCIONADOS.turno(id),
  precio_mensual  DECIMAL(38,2) NOT NULL CHECK (precio_mensual >= 0),
  CONSTRAINT ck_curso_fechas CHECK (fecha_fin >= fecha_inicio)
);



CREATE TABLE INSERT_PROMOCIONADOS.dias_por_curso(
  dia_id    BIGINT NOT NULL
            REFERENCES INSERT_PROMOCIONADOS.dias(id),
  curso_id  BIGINT NOT NULL
            REFERENCES INSERT_PROMOCIONADOS.curso(id),
  CONSTRAINT pk_dias_por_curso PRIMARY KEY (dia_id, curso_id)
);


CREATE TABLE INSERT_PROMOCIONADOS.modulos(
  id        BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre    VARCHAR(255) NOT NULL,
  curso_id  BIGINT NOT NULL
            REFERENCES INSERT_PROMOCIONADOS.curso(id)
);

CREATE TABLE INSERT_PROMOCIONADOS.evaluacion(
  id                BIGINT IDENTITY(1,1) PRIMARY KEY,
  fecha_evaluacion  DATETIME2(6) NOT NULL,
  modulo_id         BIGINT NOT NULL
                    REFERENCES INSERT_PROMOCIONADOS.modulos(id)
);

CREATE TABLE INSERT_PROMOCIONADOS.evaluacion_alumno(
  evaluacion_id BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.evaluacion(id),
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  nota          DECIMAL(5,2) NULL,
  presente      BIT NOT NULL DEFAULT 1,
  instancia     INT NULL,
  CONSTRAINT pk_evaluacion_alumno PRIMARY KEY (evaluacion_id, alumno_legajo)
);

CREATE TABLE INSERT_PROMOCIONADOS.trabajo_practico(
  id               BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id         BIGINT NOT NULL
                   REFERENCES INSERT_PROMOCIONADOS.curso(id),
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  fecha_evaluacion DATE  NOT NULL,
  nota             INT   NULL
);


CREATE TABLE INSERT_PROMOCIONADOS.inscripcion_curso(
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  curso_id              BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.curso(id),
  estado_inscripcion_id BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.estado_inscripcion(id),
  fecha_inscripcion     DATETIME2(6) NOT NULL,
  fecha_respuesta       DATETIME2(6) NULL,
  CONSTRAINT pk_inscripcion_curso PRIMARY KEY (alumno_legajo, curso_id)
);



CREATE TABLE INSERT_PROMOCIONADOS.encuesta_respondida(
  id             BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id       BIGINT NOT NULL
                 REFERENCES INSERT_PROMOCIONADOS.curso(id),
  fecha_registro DATETIME2(6) NOT NULL,
  observaciones  VARCHAR(255) NULL
);

-- Detalle: cada fila es una pregunta con su respuesta
CREATE TABLE INSERT_PROMOCIONADOS.pregunta(
  id                     BIGINT IDENTITY(1,1) PRIMARY KEY,
  encuesta_respondida_id BIGINT NOT NULL
                         REFERENCES INSERT_PROMOCIONADOS.encuesta_respondida(id),
  pregunta               VARCHAR(255) NOT NULL,
  nota                   INT NULL,
  CONSTRAINT ck_pregunta_nota CHECK (nota IS NULL OR nota BETWEEN 0 AND 10)
);

CREATE TABLE INSERT_PROMOCIONADOS.final(
  id               BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id         BIGINT NOT NULL
                   REFERENCES INSERT_PROMOCIONADOS.curso(id),
  fecha_evaluacion DATETIME2(6) NOT NULL,
  hora             TIME NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.inscripcion_final(
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  final_id              BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.final(id),
  fecha_inscripcion DATETIME2(6) NOT NULL,
  CONSTRAINT pk_inscripcion_final PRIMARY KEY (alumno_legajo, final_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.evaluacion_final(
  id                    BIGINT IDENTITY(1,1) PRIMARY KEY,
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  final_id              BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.final(id),
  profesor_id           BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.profesor(id),
  nota                  INT    NULL,
  presente              BIT    NOT NULL DEFAULT 1,
  CONSTRAINT uq_eval_final UNIQUE(alumno_legajo, final_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.factura(
  nro_factura           BIGINT IDENTITY(1,1) PRIMARY KEY,
  fecha                 DATETIME2(6) NOT NULL,
  fecha_vencimiento     DATETIME2(6) NOT NULL,
  alumno_legajo         BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(legajo),
  importe_total         DECIMAL(18,2) NOT NULL CHECK (importe_total >= 0)
);

CREATE TABLE INSERT_PROMOCIONADOS.detalle_factura(
  curso_id     BIGINT NOT NULL
               REFERENCES INSERT_PROMOCIONADOS.curso(id),
  nro_factura  BIGINT NOT NULL
               REFERENCES INSERT_PROMOCIONADOS.factura(nro_factura),
  periodo_id   BIGINT NOT NULL
               REFERENCES INSERT_PROMOCIONADOS.periodo(id),
  importe      DECIMAL(18,2) NOT NULL CHECK (importe >= 0),
  CONSTRAINT pk_detalle_factura PRIMARY KEY (curso_id, nro_factura, periodo_id)
);


CREATE TABLE INSERT_PROMOCIONADOS.pago(
  id            BIGINT IDENTITY(1,1) PRIMARY KEY,
  nro_factura   BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.factura(nro_factura),
  fecha         DATETIME2(6) NOT NULL,
  importe       DECIMAL(18,2) NOT NULL CHECK (importe >= 0),
  medio_pago_id BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.medio_pago(id)
);



/* =====================================================
   DECISIONES
   ===================================================== */
   
-- decidimos que en las tablas de incripcion la pk va a ser la combinacion del alumno con el curso o el final ya que no se puede repetir,
-- lo mismo con la tabla de detalle factura
-- Lo mismo con la tabla de dias por curso 
-- Los campos de institucion decidimos ponerlos en la tabla de sede ya que la instititucion es una sola, no vemos necesario sumar otra tabla
-- Decidimos hacer una tabla ubicacion ya que tanto la sede como el profesor y el alumno tienen domicilio, localidad y provincia
-- Para simplificar el procesamiento del script y ahorrar memoria de la BBDD decidimos no crear la clase Contacto para guardar los mails y telefonos de las sedes, alumnos y profesores
