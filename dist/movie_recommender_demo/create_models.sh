#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> <models to create>"
    exit 1
fi

CLIENT=$1
MODELS=$2
echo 'Stopping docker containers'
${STARTUP_DIR}/../stop-all

export USE_LOCAL_LOGS_DIR=${USE_LOCAL_LOGS_DIR:-}
export USE_LOCAL_MYSQL_DATA_DIR=${USE_LOCAL_MYSQL_DATA_DIR-true}
export USE_LOCAL_MODELS_DIR=${USE_LOCAL_MODELS_DIR-true}

export REGISTRY_PREFIX=
if [[ ${USE_LOCAL_LOGS_DIR} == "true" ]];then
    ${STARTUP_DIR}/../data-logs/start-data-logs ${STARTUP_DIR}/../local-logs
else
    ${STARTUP_DIR}/../data-logs/start-data-logs
fi

if [[ ${USE_LOCAL_MODELS_DIR} == "true" ]];then
    ${STARTUP_DIR}/../seldon-models/start-seldon-models ${STARTUP_DIR}/../local-models
else
    ${STARTUP_DIR}/../seldon-models/start-seldon-models
fi

if [[ ! ${USE_LOCAL_MYSQL_DATA_DIR} == "true" ]];then
    ${STARTUP_DIR}/../mysql_data/start-mysql-data
fi

${STARTUP_DIR}/../zookeeper/start-zookeeper-server
${STARTUP_DIR}/../consul/start-consul
${STARTUP_DIR}/../mysql/start-mysql-server
${STARTUP_DIR}/../spark/start-spark-offline-server

if [[ $MODELS == *"matrix_factorization"* ]]
then
    docker exec consul curl -s -X PUT -d '{"rank":30, "lambda":0.1, "alpha":1, "iterations":5}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/matrix_factorization"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh ${CLIENT}"
fi

if [[ $MODELS == *"item_similarity"* ]]
then
    docker exec consul curl -s -X PUT -d '{"sample":0.25, "limit":100, "dimsum_threshold":0.5}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/item_similarity"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh ${CLIENT}"
    docker run --name="upload_item_similarity_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/item-similarity/create_sql_and_upload.sh ${CLIENT}"
fi

if [[ $MODELS == *"semantic_vectors"* ]]
then
    docker exec consul curl -X PUT -d '{"attr_names":"top_tags"}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/semantic_vectors"
    docker run --name="create_semantic_vectors" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul semantic_vectors_image bash -c "/scripts/run-training-consul.sh ${CLIENT}"
fi

if [[ $MODELS == *"word2vec"* ]]
then
    docker exec consul curl -s -X PUT -d '{ "min_word_count":50, "vector_size":30 }' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/word2vec"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh ${CLIENT}"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh ${CLIENT}"
    docker run --name="translate_word2vec_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/word2vec/transformToSV.sh ${CLIENT}"
fi

#if [[ $MODELS == *"topic_model"* ]]
#then
#    docker exec consul curl -s -X PUT -d '{"tag_attr":"movielens_tags_full"}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/topic_model"
#    docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-model-session-tags.sh ${CLIENT}"
#    docker run --volumes-from seldon-models vw_image /vw/topic_model/run.sh ${CLIENT}
#fi

${STARTUP_DIR}/../stop-all
${STARTUP_DIR}/../start-all
