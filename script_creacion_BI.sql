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
    cantidad_cursantes           INT    NULL,
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
    total_ingresos    DECIMAL(18,2) NULL
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



INSERT INTO INSERT_PROMOCIONADOS.bi_cursada
    (tiempo_id, categoria_id, sede_id, cantidad_aprobados, cantidad_cursantes, promedio_tiempo_finalizacion)
SELECT
    x.tiempo_id,
    x.categoria_id,
    x.sede_id,
    SUM(x.aprobado)                AS cantidad_aprobados,
    COUNT(*)                       AS cantidad_cursantes,
    CASE 
        WHEN SUM(CASE WHEN x.tiempo_finalizacion IS NOT NULL THEN 1 ELSE 0 END) = 0 
            THEN NULL
        ELSE 
            1.0 * 
            SUM(CASE WHEN x.tiempo_finalizacion IS NOT NULL 
                     THEN x.tiempo_finalizacion 
                     ELSE 0 
                END)
            / SUM(CASE WHEN x.tiempo_finalizacion IS NOT NULL THEN 1 ELSE 0 END)
    END                            AS promedio_tiempo_finalizacion
FROM (
    SELECT
        -- Dim TIEMPO: año/mes de inicio del curso
        t.id   AS tiempo_id,
        bc.id  AS categoria_id,
        bs.id  AS sede_id,

        -- 1 = aprobó cursada, 0 = no
        CASE 
          WHEN
            -- Tiene al menos un módulo
            (SELECT COUNT(*)
             FROM INSERT_PROMOCIONADOS.modulos m
             WHERE m.curso_id = cu.id) > 0
            AND
            -- Todos los módulos del curso tienen al menos una nota >= 4 para ese alumno
            (SELECT COUNT(DISTINCT m2.id)
             FROM INSERT_PROMOCIONADOS.modulos m2
             JOIN INSERT_PROMOCIONADOS.evaluacion ev
                  ON ev.modulo_id = m2.id
             JOIN INSERT_PROMOCIONADOS.evaluacion_alumno ea
                  ON ea.evaluacion_id = ev.id
             WHERE m2.curso_id = cu.id
               AND ea.alumno_legajo = ic.alumno_legajo
               AND ea.nota >= 4
            )
            = (SELECT COUNT(*)
               FROM INSERT_PROMOCIONADOS.modulos m3
               WHERE m3.curso_id = cu.id)
            AND
            -- Tiene TP aprobado (nota >= 4)
            EXISTS (
                SELECT 1
                FROM INSERT_PROMOCIONADOS.trabajo_practico tp
                WHERE tp.curso_id = cu.id
                  AND tp.alumno_legajo = ic.alumno_legajo
                  AND tp.nota >= 4
            )
          THEN 1
          ELSE 0
        END AS aprobado,

        -- Días hasta el PRIMER final aprobado (nota >= 4) de ese curso para ese alumno
        (
            SELECT TOP 1 
                   DATEDIFF(MONTH, cu.fecha_inicio, f3.fecha_evaluacion)
            FROM INSERT_PROMOCIONADOS.final f3
            JOIN INSERT_PROMOCIONADOS.evaluacion_final ef3
              ON ef3.final_id = f3.id
             AND ef3.alumno_legajo = ic.alumno_legajo
            WHERE f3.curso_id = cu.id
              AND ef3.nota >= 4
            ORDER BY f3.fecha_evaluacion
        ) AS tiempo_finalizacion
    FROM INSERT_PROMOCIONADOS.inscripcion_curso ic
    JOIN INSERT_PROMOCIONADOS.curso cu
        ON cu.id = ic.curso_id
    LEFT JOIN INSERT_PROMOCIONADOS.categoria cat
        ON cat.id = cu.categoria_id
    JOIN INSERT_PROMOCIONADOS.sede s
        ON s.id = cu.sede_id

    -- Dimensiones BI
    JOIN INSERT_PROMOCIONADOS.bi_sede bs
        ON bs.nombre = s.nombre
    LEFT JOIN INSERT_PROMOCIONADOS.bi_categorias_curso bc
        ON bc.nombre = cat.nombre
    JOIN INSERT_PROMOCIONADOS.bi_tiempo t
        ON t.anio = YEAR(cu.fecha_inicio)
       AND t.mes  = MONTH(cu.fecha_inicio)
) AS x
GROUP BY
    x.tiempo_id,
    x.categoria_id,
    x.sede_id;



INSERT INTO INSERT_PROMOCIONADOS.bi_pagos
    (tiempo_id, sede_id, categoria_id, medio_de_pago_id,
     cantidad_pagos, cantidad_pagos_fuera_termino,
     facturacion_esperada, total_ingresos)
SELECT
    t.id       AS tiempo_id,
    bs.id      AS sede_id,
    bc.id      AS categoria_id,
    bmp.id     AS medio_de_pago_id,

    COUNT(*)   AS cantidad_pagos,

    SUM(
        CASE 
          WHEN p.fecha > f.fecha_vencimiento THEN 1
          ELSE 0
        END
    )          AS cantidad_pagos_fuera_termino,

    SUM(f.importe_total)    AS facturacion_esperada,   -- lo que se debía pagar ese mes

    SUM(
        CASE 
          WHEN p.fecha <= f.fecha_vencimiento THEN p.importe
          ELSE 0
        END
    )          AS total_ingresos        -- lo que se pago ese mes en termino 
FROM INSERT_PROMOCIONADOS.pago p
JOIN INSERT_PROMOCIONADOS.factura f
      ON f.nro_factura = p.nro_factura
JOIN INSERT_PROMOCIONADOS.detalle_factura df
      ON df.nro_factura = f.nro_factura
JOIN INSERT_PROMOCIONADOS.periodo per
      ON per.id = df.periodo_id
JOIN INSERT_PROMOCIONADOS.curso cu
      ON cu.id = df.curso_id
JOIN INSERT_PROMOCIONADOS.sede s
      ON s.id = cu.sede_id
LEFT JOIN INSERT_PROMOCIONADOS.categoria cat
      ON cat.id = cu.categoria_id
JOIN INSERT_PROMOCIONADOS.medio_pago mp
      ON mp.id = p.medio_pago_id

-- Dimensiones BI
JOIN INSERT_PROMOCIONADOS.bi_tiempo t
      ON t.anio = per.anio
     AND t.mes  = per.mes
JOIN INSERT_PROMOCIONADOS.bi_sede bs
      ON bs.nombre = s.nombre
LEFT JOIN INSERT_PROMOCIONADOS.bi_categorias_curso bc
      ON bc.nombre = cat.nombre
JOIN INSERT_PROMOCIONADOS.bi_medio_de_pago bmp
      ON bmp.medio = mp.medio

GROUP BY
    t.id, bs.id, bc.id, bmp.id;




INSERT INTO INSERT_PROMOCIONADOS.bi_encuesta
    (tiempo_id, sede_id, rango_edad_profesores_id, bloque_de_satisfaccion_id, cantidad_respuestas)
SELECT
    t.id AS tiempo_id,
    bs.id AS sede_id,
    brp.id AS rango_edad_profesores_id,
    bds.id AS bloque_de_satisfaccion_id,
    COUNT(*) AS cantidad_respuestas
FROM INSERT_PROMOCIONADOS.encuesta_respondida er
JOIN INSERT_PROMOCIONADOS.curso cu 
    ON cu.id = er.curso_id
JOIN INSERT_PROMOCIONADOS.profesor p
    ON p.id = cu.profesor_id
JOIN INSERT_PROMOCIONADOS.sede s
    ON s.id = cu.sede_id
JOIN INSERT_PROMOCIONADOS.pregunta pr
    ON pr.encuesta_id = er.id    -- O la tabla que tenga la nota numérica

-- === Dimensiones BI ===

-- Tiempo por fecha_registro
JOIN INSERT_PROMOCIONADOS.bi_tiempo t
    ON t.anio = YEAR(er.fecha_registro)
   AND t.mes  = MONTH(er.fecha_registro)

-- Sede
JOIN INSERT_PROMOCIONADOS.bi_sede bs
    ON bs.nombre = s.nombre

-- Rango Etario Profesores
JOIN INSERT_PROMOCIONADOS.bi_rango_edad_profesores brp
    ON brp.rango =
       CASE 
           WHEN DATEDIFF(YEAR, p.fecha_nacimiento, er.fecha_registro) BETWEEN 25 AND 35 THEN '25-35'
           WHEN DATEDIFF(YEAR, p.fecha_nacimiento, er.fecha_registro) BETWEEN 36 AND 50 THEN '35-50'
           ELSE '>50'
       END

-- Bloque de satisfacción según nota 1..10
JOIN INSERT_PROMOCIONADOS.bi_bloque_de_satisfaccion bds
    ON bds.nivel_satisfaccion =
       CASE 
           WHEN pr.nota BETWEEN 7 AND 10 THEN 'Satisfechos'
           WHEN pr.nota BETWEEN 5 AND 6  THEN 'Neutrales'
           ELSE 'Insatisfechos'
       END

GROUP BY
    t.id, bs.id, brp.id, bds.id;



