USE GD2C2025;
GO

CREATE TABLE INSERT_PROMOCIONADOS.bi_tiempo(
    id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    anio      INT      NOT NULL,
    semestre  INT      NOT NULL,
    mes       INT      NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_categorias_curso(
    id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    nombre  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_turnos_curso(
    id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    turno  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_sede(
    id      BIGINT IDENTITY(1,1) PRIMARY KEY,
    nombre  VARCHAR(255) NOT NULL
);


CREATE TABLE INSERT_PROMOCIONADOS.bi_rango_edad_alumnos(
    id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    rango  VARCHAR(255) NOT NULL
);


CREATE TABLE INSERT_PROMOCIONADOS.bi_rango_edad_profesores(
    id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    rango  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_medio_de_pago(
    id     BIGINT IDENTITY(1,1) PRIMARY KEY,
    medio  VARCHAR(255) NOT NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_bloque_de_satisfaccion(
    id                 BIGINT IDENTITY(1,1) PRIMARY KEY,
    nivel_satisfaccion VARCHAR(255) NOT NULL
);

/* =========================================================
   Hechos
   ========================================================= */

CREATE TABLE INSERT_PROMOCIONADOS.bi_cursada(
    id                           BIGINT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id                    BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_tiempo(id),
    categoria_id                 BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_categorias_curso(id),
    sede_id                      BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_sede(id),
    cantidad_aprobados           INT    NULL,
    cantidad_ausencias           INT    NULL,
    promedio_tiempo_finalizacion DECIMAL(18,2) NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_inscripcion(
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id           BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_tiempo(id),
    turno_id            BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_turnos_curso(id),
    categoria_id        BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_categorias_curso(id),
    sede_id             BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_sede(id),
    cantidad_inscriptos INT   NOT NULL,
    cantidad_rechazos   INT   NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_final(
    id                   BIGINT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id            BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_tiempo(id),
    sede_id              BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_sede(id),
    categoria_id         BIGINT NULL  REFERENCES INSERT_PROMOCIONADOS.bi_categorias_curso(id),
    rango_alumnos_id     BIGINT NULL  REFERENCES INSERT_PROMOCIONADOS.bi_rango_edad_alumnos(id),
    cantidad_inscriptos  INT    NULL,
    cantidad_ausencias   INT    NULL,
    cantidad_notas       INT    NULL,
    sumatoria_notas      DECIMAL(18,2) NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_encuesta(
    id                          BIGINT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id                   BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_tiempo(id),
    sede_id                     BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_sede(id),
    rango_edad_profesores_id    BIGINT NULL REFERENCES INSERT_PROMOCIONADOS.bi_rango_edad_profesores(id),
    bloque_de_satisfaccion_id   BIGINT NULL REFERENCES INSERT_PROMOCIONADOS.bi_bloque_de_satisfaccion(id),
    cantidad_respuestas         INT    NULL
);

CREATE TABLE INSERT_PROMOCIONADOS.bi_pagos(
    id                           BIGINT IDENTITY(1,1) PRIMARY KEY,
    tiempo_id                    BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_tiempo(id),
    sede_id                      BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_sede(id),
    categoria_id                 BIGINT NULL  REFERENCES INSERT_PROMOCIONADOS.bi_categorias_curso(id),
    medio_de_pago_id             BIGINT NOT NULL REFERENCES INSERT_PROMOCIONADOS.bi_medio_de_pago(id),
    cantidad_pagos               INT    NULL,
    cantidad_pagos_fuera_termino INT    NULL,
    facturacion_esperada         DECIMAL(18,2) NULL,
    total_ingresos               DECIMAL(18,2) NULL
);

-- Creates funcionales


-- Desde fecha de inicio de cursos
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(c.fecha_inicio)                                       AS anio,
    CASE WHEN MONTH(c.fecha_inicio) BETWEEN 1 AND 6 THEN 1 ELSE 2 END AS semestre,
    MONTH(c.fecha_inicio)                                      AS mes
FROM INSERT_PROMOCIONADOS.curso c
WHERE c.fecha_inicio IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(c.fecha_inicio)
          AND t.mes  = MONTH(c.fecha_inicio)
  );

INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(c.fecha_fin),
    CASE WHEN MONTH(c.fecha_fin) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(c.fecha_fin)
FROM INSERT_PROMOCIONADOS.curso c
WHERE c.fecha_fin IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(c.fecha_fin)
          AND t.mes  = MONTH(c.fecha_fin)
  );

-- Desde inscripciones a cursos
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(ic.fecha_inscripcion),
    CASE WHEN MONTH(ic.fecha_inscripcion) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(ic.fecha_inscripcion)
FROM INSERT_PROMOCIONADOS.inscripcion_curso ic
WHERE ic.fecha_inscripcion IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(ic.fecha_inscripcion)
          AND t.mes  = MONTH(ic.fecha_inscripcion)
  );

INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(ic.fecha_respuesta),
    CASE WHEN MONTH(ic.fecha_respuesta) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(ic.fecha_respuesta)
FROM INSERT_PROMOCIONADOS.inscripcion_curso ic
WHERE ic.fecha_respuesta IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(ic.fecha_respuesta)
          AND t.mes  = MONTH(ic.fecha_respuesta)
  );


-- Desde finales
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(f.fecha_evaluacion),
    CASE WHEN MONTH(f.fecha_evaluacion) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(f.fecha_evaluacion)
FROM INSERT_PROMOCIONADOS.final f
WHERE f.fecha_evaluacion IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(f.fecha_evaluacion)
          AND t.mes  = MONTH(f.fecha_evaluacion)
  );

-- Desde pagos
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(p.fecha),
    CASE WHEN MONTH(p.fecha) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(p.fecha)
FROM INSERT_PROMOCIONADOS.pago p
WHERE p.fecha IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(p.fecha)
          AND t.mes  = MONTH(p.fecha)
  );

-- Desde período facturado (mes/año de la tabla periodo)
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    per.anio,
    CASE WHEN per.mes BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    per.mes
FROM INSERT_PROMOCIONADOS.periodo per
WHERE NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = per.anio
          AND t.mes  = per.mes
);

-- Desde encuestas
INSERT INTO INSERT_PROMOCIONADOS.bi_tiempo (anio, semestre, mes)
SELECT DISTINCT
    YEAR(er.fecha_registro),
    CASE WHEN MONTH(er.fecha_registro) BETWEEN 1 AND 6 THEN 1 ELSE 2 END,
    MONTH(er.fecha_registro)
FROM INSERT_PROMOCIONADOS.encuesta_respondida er
WHERE er.fecha_registro IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM INSERT_PROMOCIONADOS.bi_tiempo t
        WHERE t.anio = YEAR(er.fecha_registro)
          AND t.mes  = MONTH(er.fecha_registro)
  );


INSERT INTO INSERT_PROMOCIONADOS.bi_categorias_curso (nombre)
SELECT DISTINCT c.nombre
FROM INSERT_PROMOCIONADOS.categoria c
WHERE c.nombre IS NOT NULL;

INSERT INTO INSERT_PROMOCIONADOS.bi_turnos_curso (turno)
SELECT DISTINCT t.turno
FROM INSERT_PROMOCIONADOS.turno t
WHERE t.turno IS NOT NULL;

INSERT INTO INSERT_PROMOCIONADOS.bi_sede (nombre)
SELECT DISTINCT s.nombre
FROM INSERT_PROMOCIONADOS.sede s
WHERE s.nombre IS NOT NULL;

INSERT INTO INSERT_PROMOCIONADOS.bi_medio_de_pago (medio)
SELECT DISTINCT mp.medio
FROM INSERT_PROMOCIONADOS.medio_pago mp
WHERE mp.medio IS NOT NULL;

-- RANGOS

INSERT INTO INSERT_PROMOCIONADOS.bi_rango_edad_alumnos (rango)
VALUES ('<25'), ('25-35'), ('35-50'), ('>50');

INSERT INTO INSERT_PROMOCIONADOS.bi_rango_edad_profesores (rango)
VALUES ('25-35'), ('35-50'), ('>50');


INSERT INTO INSERT_PROMOCIONADOS.bi_bloque_de_satisfaccion (nivel_satisfaccion)
VALUES ('Satisfechos'), ('Neutrales'), ('Insatisfechos');


INSERT INTO INSERT_PROMOCIONADOS.bi_inscripcion
    (tiempo_id, turno_id, categoria_id, sede_id,cantidad_inscriptos, cantidad_rechazos)
SELECT
    t.id      AS tiempo_id,
    bt.id     AS turno_id,
    bc.id     AS categoria_id,
    bs.id     AS sede_id,

    COUNT(*)  AS cantidad_inscriptos,

    SUM(
    CASE 
        WHEN UPPER(ei.estado) = 'RECHAZADA' 
             THEN 1 
        ELSE 0 
    END
  )         AS cantidad_rechazos
FROM INSERT_PROMOCIONADOS.inscripcion_curso ic
JOIN INSERT_PROMOCIONADOS.curso cu ON cu.id = ic.curso_id
JOIN INSERT_PROMOCIONADOS.estado_inscripcion ei ON ei.id = ic.estado_inscripcion_id
JOIN INSERT_PROMOCIONADOS.turno tu ON tu.id = cu.turno_id
JOIN INSERT_PROMOCIONADOS.categoria cat ON cat.id = cu.categoria_id
JOIN INSERT_PROMOCIONADOS.sede s ON s.id = cu.sede_id

-- Dimensiones BI
JOIN INSERT_PROMOCIONADOS.bi_turnos_curso bt ON bt.turno = tu.turno
JOIN INSERT_PROMOCIONADOS.bi_categorias_curso bc ON bc.nombre = cat.nombre
JOIN INSERT_PROMOCIONADOS.bi_sede bs ON bs.nombre = s.nombre
JOIN INSERT_PROMOCIONADOS.bi_tiempo t ON t.anio = YEAR(ic.fecha_inscripcion) AND t.mes  = MONTH(ic.fecha_inscripcion)

WHERE ic.fecha_inscripcion IS NOT NULL
GROUP BY t.id, bt.id,bc.id, bs.id;


INSERT INTO INSERT_PROMOCIONADOS.bi_final
    (tiempo_id, sede_id, categoria_id, rango_alumnos_id,
     cantidad_inscriptos, cantidad_ausencias, cantidad_notas, sumatoria_notas)
SELECT
    t.id    AS tiempo_id,
    bs.id   AS sede_id,
    bc.id   AS categoria_id,
    bra.id  AS rango_alumnos_id,

    COUNT(*) AS cantidad_inscriptos,

    SUM(
        CASE 
            WHEN ef.id IS NULL THEN 1        -- no tiene evaluación registrada
            WHEN ef.presente = 0 THEN 1      -- tiene evaluación pero no se presentó
            ELSE 0
        END
    ) AS cantidad_ausencias,

    SUM(
        CASE 
            WHEN ef.nota IS NOT NULL 
             AND ef.presente = 1 THEN 1
            ELSE 0
        END
    ) AS cantidad_notas,

    SUM(
        CASE 
            WHEN ef.nota IS NOT NULL 
             AND ef.presente = 1 
                 THEN CAST(ef.nota AS DECIMAL(18,2))
            ELSE 0
        END
    ) AS sumatoria_notas
FROM INSERT_PROMOCIONADOS.inscripcion_final inf
JOIN INSERT_PROMOCIONADOS.final f
    ON f.id = inf.final_id
JOIN INSERT_PROMOCIONADOS.curso cu
    ON cu.id = f.curso_id
JOIN INSERT_PROMOCIONADOS.sede s
    ON s.id = cu.sede_id
LEFT JOIN INSERT_PROMOCIONADOS.categoria cat
    ON cat.id = cu.categoria_id
LEFT JOIN INSERT_PROMOCIONADOS.evaluacion_final ef
    ON ef.final_id      = inf.final_id
   AND ef.alumno_legajo = inf.alumno_legajo
JOIN INSERT_PROMOCIONADOS.alumno a
    ON a.legajo = inf.alumno_legajo

-- Dim Sede BI
JOIN INSERT_PROMOCIONADOS.bi_sede bs
    ON bs.nombre = s.nombre

-- Dim Categoría BI (puede ser NULL)
LEFT JOIN INSERT_PROMOCIONADOS.bi_categorias_curso bc
    ON bc.nombre = cat.nombre

-- Dim Tiempo BI (mes/año del final)
JOIN INSERT_PROMOCIONADOS.bi_tiempo t
    ON t.anio = YEAR(f.fecha_evaluacion)
   AND t.mes  = MONTH(f.fecha_evaluacion)

-- Dim Rango Etario Alumnos BI (usamos edad al momento del final)
JOIN INSERT_PROMOCIONADOS.bi_rango_edad_alumnos bra
    ON bra.rango =
       CASE 
         WHEN a.fecha_nacimiento IS NULL THEN '<25'  -- default si falta dato
         ELSE
           CASE 
             WHEN DATEDIFF(YEAR, a.fecha_nacimiento, f.fecha_evaluacion) < 25
               THEN '<25'
             WHEN DATEDIFF(YEAR, a.fecha_nacimiento, f.fecha_evaluacion) BETWEEN 25 AND 35
               THEN '25-35'
             WHEN DATEDIFF(YEAR, a.fecha_nacimiento, f.fecha_evaluacion) BETWEEN 36 AND 50
               THEN '35-50'
             ELSE '>50'
           END
       END
GROUP BY
    t.id,
    bs.id,
    bc.id,
    bra.id;
