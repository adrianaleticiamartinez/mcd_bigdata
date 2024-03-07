#Carga de Información filtrada de Bucket a BigQuery
bq load --source_format=CSV --autodetect \
pf_github.pull_requests_clean \
gs://up-pf-ghtorrent-2024-alme/temp_for_bigquery_load/*
