USE GD2C2025;
GO

SELECT DISTINCT Sede_Nombre , COUNT(*) FROM gd_esquema.Maestra GROUP BY Sede_Nombre

-- Crear esquema del grupo
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'INSERT_PROMOCIONADOS')
    EXEC('CREATE SCHEMA INSERT_PROMOCIONADOS');
GO


/* =====================================================
   1) Catálogos / Tablas maestras
   ===================================================== */

CREATE TABLE INSERT_PROMOCIONADOS.categoria(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE INSERT_PROMOCIONADOS.sede(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL UNIQUE,
  provincia VARCHAR(255),
  Localidad VARCHAR(255)
);

CREATE TABLE INSERT_PROMOCIONADOS.turno(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  turno  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.dias(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.medio_pago(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  medio  VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.estado_inscripcion(
  id     BIGINT IDENTITY(1,1) PRIMARY KEY,
  estado VARCHAR(255) NOT NULL 
);

CREATE TABLE INSERT_PROMOCIONADOS.periodo(
  id   BIGINT IDENTITY(1,1) PRIMARY KEY,
  mes  INT  NOT NULL,
  anio INT  NOT NULL,
  CONSTRAINT ck_periodo_mes  CHECK (mes BETWEEN 1 AND 12),
  CONSTRAINT ck_periodo_anio,
  CONSTRAINT uq_periodo 
);


/* =====================================================
   2) Personas
   ===================================================== */

CREATE TABLE INSERT_PROMOCIONADOS.profesor(
  id         BIGINT IDENTITY(1,1) PRIMARY KEY,
  dni        VARCHAR(48)  NOT NULL,
  nombre     VARCHAR(255) NOT NULL,
  apellido   VARCHAR(255) NOT NULL,
  domicilio  VARCHAR(255) NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.alumno(
  id         BIGINT IDENTITY(1,1) PRIMARY KEY,
  legajo     BIGINT       NOT NULL,
  dni        BIGINT       NOT NULL,
  nombre     VARCHAR(255) NOT NULL,
  apellido   VARCHAR(255) NOT NULL,
  domicilio  VARCHAR(255) NULL
);


/* =====================================================
   3) Cursos y estructura
   ===================================================== */

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
  alumno_id     BIGINT NOT NULL
                REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  legajo        BIGINT NULL,
  nota          DECIMAL(5,2) NULL,
  presente      BIT NOT NULL DEFAULT 1,
  instancia     INT NULL,
  CONSTRAINT pk_evaluacion_alumno PRIMARY KEY (evaluacion_id, alumno_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.trabajo_practico(
  id               BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id         BIGINT NOT NULL
                   REFERENCES INSERT_PROMOCIONADOS.curso(id),
  alumno_id        BIGINT NOT NULL
                   REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  fecha_evaluacion DATE  NOT NULL,
  nota             INT   NULL
);


/* =====================================================
   4) Inscripciones y encuestas
   ===================================================== */

CREATE TABLE INSERT_PROMOCIONADOS.inscripcion_curso(
  alumno_id             BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  curso_id              BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.curso(id),
  estado_inscripcion_id BIGINT NOT NULL
                        REFERENCES INSERT_PROMOCIONADOS.estado_inscripcion(id),
  fecha_inscripcion     DATETIME2(6) NOT NULL,
  fecha_respuesta       DATETIME2(6) NULL,
  completo_encuesta     BIT NOT NULL DEFAULT 0,
  CONSTRAINT pk_inscripcion_curso PRIMARY KEY (alumno_id, curso_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.encuesta(
  id      BIGINT IDENTITY(1,1) PRIMARY KEY,
  nombre  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE INSERT_PROMOCIONADOS.pregunta(
  id          BIGINT IDENTITY(1,1) PRIMARY KEY,
  encuesta_id BIGINT NOT NULL
              REFERENCES INSERT_PROMOCIONADOS.encuesta(id),
  pregunta    VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.encuesta_respondida(
  id             BIGINT IDENTITY(1,1) PRIMARY KEY,
  encuesta_id    BIGINT NOT NULL
                 REFERENCES INSERT_PROMOCIONADOS.encuesta(id),
  curso_id       BIGINT NOT NULL
                 REFERENCES INSERT_PROMOCIONADOS.curso(id),
  alumno_id      BIGINT NOT NULL
                 REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  fecha_registro DATETIME2(6) NOT NULL,
  observaciones  VARCHAR(255) NULL,
  CONSTRAINT uq_encuesta_alumno UNIQUE(encuesta_id, curso_id, alumno_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.respuesta(
  id                     BIGINT IDENTITY(1,1) PRIMARY KEY,
  pregunta_id            BIGINT NOT NULL
                         REFERENCES INSERT_PROMOCIONADOS.pregunta(id),
  encuesta_respondida_id BIGINT NOT NULL
                         REFERENCES INSERT_PROMOCIONADOS.encuesta_respondida(id),
  respuesta              VARCHAR(1000) NULL
);


/* =====================================================
   5) Finales
   ===================================================== */

CREATE TABLE INSERT_PROMOCIONADOS.final(
  id               BIGINT IDENTITY(1,1) PRIMARY KEY,
  curso_id         BIGINT NOT NULL
                   REFERENCES INSERT_PROMOCIONADOS.curso(id),
  fecha_evaluacion DATETIME2(6) NOT NULL,
  hora             TIME NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.inscripcion_final(
  alumno_id         BIGINT NOT NULL
                    REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  final_id          BIGINT NOT NULL
                    REFERENCES INSERT_PROMOCIONADOS.final(id),
  fecha_inscripcion DATETIME2(6) NOT NULL,
  pk_id             BIGINT NOT NULL,
  CONSTRAINT pk_inscripcion_final PRIMARY KEY (alumno_id, final_id)
);

CREATE TABLE INSERT_PROMOCIONADOS.evaluacion_final(
  id          BIGINT IDENTITY(1,1) PRIMARY KEY,
  alumno_id   BIGINT NOT NULL
              REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  final_id    BIGINT NOT NULL
              REFERENCES INSERT_PROMOCIONADOS.final(id),
  profesor_id BIGINT NOT NULL
              REFERENCES INSERT_PROMOCIONADOS.profesor(id),
  nota        INT    NULL,
  presente    BIT    NOT NULL DEFAULT 1,
  CONSTRAINT uq_eval_final UNIQUE(alumno_id, final_id)
);


/* =====================================================
   6) Facturación y pagos
   ===================================================== */

CREATE TABLE INSERT_PROMOCIONADOS.factura(
  nro_factura       BIGINT IDENTITY(1,1) PRIMARY KEY,
  fecha             DATETIME2(6) NOT NULL,
  fecha_vencimiento DATETIME2(6) NOT NULL,
  alumno_id         BIGINT NOT NULL
                    REFERENCES INSERT_PROMOCIONADOS.alumno(id),
  importe_total     DECIMAL(12,2) NOT NULL CHECK (importe_total >= 0)
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