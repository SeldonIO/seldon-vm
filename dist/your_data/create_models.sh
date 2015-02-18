#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <db name> <model to create> optional <tag_field_names>"
    echo "<db name> is test1, test2, test3, test4 or test5"
    echo "<model to create> one of : matrix_factorization, item_similarity, semantic_vectors, word2vec. See http://docs.seldon.io"
    echo "<tag_field_names> comma separated list of attribute names"
    exit 1
fi

CLIENT=$1
MODELS=$2
TAGS=${3:-top_tags}
if [[ $MODELS == *"matrix_factorization"* ]]
then
    # update json settings for your data
    docker exec consul curl -s -X PUT -d '{"rank":30, "lambda":0.1, "alpha":1, "iterations":5}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/matrix_factorization"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh ${CLIENT}"
    ${STARTUP_DIR}/activate_models.sh ${CLIENT} matrix_factorization
fi

if [[ $MODELS == *"item_similarity"* ]]
then
    # update json settings for your data
    docker exec consul curl -s -X PUT -d '{"limit":100, "dimsum_threshold":0.1}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/item_similarity"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh ${CLIENT}"
    docker run --name="upload_item_similarity_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/item-similarity/create_sql_and_upload.sh ${CLIENT}"
    ${STARTUP_DIR}/activate_models.sh ${CLIENT} item_similarity
fi

if [[ $MODELS == *"semantic_vectors"* ]]
then
    # update json settings for your data 
    docker exec consul curl -X PUT -d "{\"attr_names\":\"${TAGS}\"}" "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/semantic_vectors"
    docker run --name="create_semantic_vectors" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul semantic_vectors_image bash -c "/scripts/run-training-consul.sh ${CLIENT}"
    ${STARTUP_DIR}/activate_models.sh ${CLIENT} semantic_vectors
fi

if [[ $MODELS == *"word2vec"* ]]
then
    # update json settings for your data
    docker exec consul curl -s -X PUT -d '{ "min_word_count":50, "vector_size":30 }' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/word2vec"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh ${CLIENT}"
    docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh ${CLIENT}"
    docker run --name="translate_word2vec_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/word2vec/transformToSV.sh ${CLIENT}"
    ${STARTUP_DIR}/activate_models.sh ${CLIENT} word2vec
fi

#if [[ $MODELS == *"topic_model"* ]]
#then
#    docker exec consul curl -s -X PUT -d '{"tag_attr":"movielens_tags_full"}' "http://localhost:8500/v1/kv/seldon/${CLIENT}/algs/topic_model"
#    docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-model-session-tags.sh ${CLIENT}"
#    docker run --volumes-from seldon-models vw_image /vw/topic_model/run.sh ${CLIENT}
#    ${STARTUP_DIR}/activate_models.sh ${CLIENT} topic_model
#fi


