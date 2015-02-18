Not all data to create the images is inside the hg project. Some data needs to be downloaded.

mysql_data:
run mysql_data/get-image-data.sh

api-server_data_logs_image:
run get-movielens-models.sh

api_server_image:
mvn build api-server and then run create-webapps

spark_image:
run copy-jars-to-app-dir



