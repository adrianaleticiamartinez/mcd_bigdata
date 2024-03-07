--PRECONDICIÓN: Haber desacargado y descomprimido el archivo a un Bucket de Google Cloud Storage
--              Estar dentro de tu entorno de Cloud Compiting y estar conrriendo HIVE
--Creación de Tabla externa HIVE
CREATE EXTERNAL TABLE IF NOT EXISTS github_pull_requests (
  actor_login STRING,
  actor_id INT,
  comment_id INT,
  comment STRING,
  repo STRING,
  language STRING,
  author_login STRING,
  author_id INT,
  pr_id INT,
  c_id INT,
  commit_date STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'gs://up-pf-ghtorrent-2024-alme/temp_zip_extract';

--Creación de tabla Auxiliar
CREATE TABLE github_pull_requests_clean AS
SELECT actor_login, actor_id, comment_id, comment, repo, language, author_login, author_id, pr_id, c_id, commit_date
FROM github_pull_requests
WHERE repo IS NOT NULL
AND language IS NOT NULL
AND comment IS NOT NULL
AND TRIM(comment) <> ''
AND comment NOT LIKE '%NULL%'
AND commit_date IS NOT NULL
AND LENGTH(commit_date) = 23;

--Exportación de información de HIVE a Bucket
INSERT OVERWRITE DIRECTORY 'gs://up-pf-ghtorrent-2024-alme/temp_for_bigquery_load/'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT * FROM github_pull_requests_clean;
