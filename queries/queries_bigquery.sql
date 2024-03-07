--Creación De Vista en BigQuery
CREATE VIEW `bd-final-alme.pf_github.pruebagit_with_flags` AS
SELECT
   actor_login,
   actor_id,
   comment_id,
   comment,
   repo,
   language,
   author_login,
   author_id,
   pr_id,
   c_id,
   commit_date,
   CASE WHEN LOWER(comment) LIKE '%error%' OR LOWER(comment) LIKE '%fix%' OR LOWER(comment) LIKE '%bug%' THEN TRUE ELSE FALSE END AS contains_error,
   CASE WHEN LOWER(comment) LIKE '%well%' OR LOWER(comment) LIKE '%good%' OR LOWER(comment) LIKE '%great%'OR LOWER(comment) LIKE '%ok%' THEN TRUE ELSE FALSE END AS good_job,
   CASE WHEN LOWER(comment) LIKE '%new%' OR LOWER(comment) LIKE '%feature%' THEN TRUE ELSE FALSE END AS contains_new_feature
FROM
   `bd-final-alme.pf_github.pruebagit`;

--Creación de tabla auxiliar para segmentación de información en BigQuery
CREATE TABLE `bd-final-alme.pf_github.pruebagit-segment`
AS
 SELECT
 actor_login,
 language,
 repo,
 CASE WHEN LOWER(comment) LIKE '%error%' OR LOWER(comment) LIKE '%fix%' OR LOWER(comment) LIKE '%bug%' THEN TRUE ELSE FALSE END AS contains_error,
  CASE WHEN LOWER(comment) LIKE '%well%' OR LOWER(comment) LIKE '%good%' OR LOWER(comment) LIKE '%great%'OR LOWER(comment) LIKE '%ok%' THEN TRUE ELSE FALSE END AS good_job,
 RAND() AS random_number
 FROM `bd-final-alme.pf_github.pruebagit`;

--Generación de tablas de entrenamiento y pruebas
CREATE OR REPLACE TABLE `bd-final-alme.pf_github.tabla_entrenamiento` AS
SELECT *
FROM `bd-final-alme.pf_github.pruebagit-segment`
WHERE random_number < 0.8;


CREATE OR REPLACE TABLE `bd-final-alme.pf_github.tabla_pruebas` AS
SELECT *
FROM `bd-final-alme.pf_github.pruebagit-segment`
WHERE random_number >= 0.8;

--Entrenamiento de Modelo BigQueryML
CREATE OR REPLACE MODEL `bd-final-alme.pf_github.modelo_contains_error`
OPTIONS(model_type='logistic_reg', input_label_cols=['contains_error']) AS
SELECT
 actor_login,
 language,
 IF(contains_error, 1, 0) AS contains_error
FROM
 `bd-final-alme.pf_github.tabla_entrenamiento`;

--Evaluación de Modelo BigQueryML
SELECT
  *
FROM
  ML.EVALUATE(MODEL `bd-final-alme.pf_github.modelo_contains_error`, (
    SELECT 
      actor_login,
      language,
      IF(contains_error, 1, 0) AS contains_error
    FROM
      `bd-final-alme.pf_github.tabla_pruebas`
  ));
