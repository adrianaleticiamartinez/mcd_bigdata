#Exportación de modelo
bq extract -m pf_github.modelo_contains_error gs://up-pf-ghtorrent-2024-alme/pred_model

#Descarga los archivos del modelo exportado en un directorio temporal
mkdir tmp_dir
gsutil cp -r gs://up-pf-ghtorrent-2024-alme/pred_model tmp_dir

#Creación de un subdirectorio de la versión
mkdir -p serving_dir/pred_model/1
cp -r tmp_dir/pred_model/* serving_dir/pred_model/1
rm -r tmp_dir

#Extracción de la imagen de Docker
docker pull tensorflow/serving
Ejecución del contenedor de Docker
docker run -p 8500:8500 --network="host" --mount type=bind,source=`pwd`/serving_dir/pred_model,target=/models/pred_model -e MODEL_NAME=pred_model -t tensorflow/serving &

#Ejecución del API de predicción
curl -d '{"instances": [{"actor_login": "caalador", "language": "PHP"}]}' -X POST http://localhost:8501/v1/models/pred_model:predict
