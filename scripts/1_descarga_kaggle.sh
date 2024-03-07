#PRECONDICIONES: Haber levantado una máquina virtual en Compute engine con la capacidad suficiente 
#                Haber configurado el entorno de Kaggle en tu VM

#Creación Bucket
gsutil mb gs://up-pf-ghtorrent-2024-alme

#Descarga de información a través del API de Kaggle
gcloud compute scp Downloads/kaggle.json vm-pf-kaggle-alme:~


#Transferencia de indormación de VM a Bucket
gsutil -m cp -r temp_zip_extract gs://up-pf-ghtorrent-2024-alme
