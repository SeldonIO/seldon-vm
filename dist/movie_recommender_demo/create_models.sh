#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

CLIENT=movielens
MODEL=matrix_factorization
MODEL=item_similarity

do_matrix_factorization() {
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args /all_clients/movielens/offline/matrix-factorization '{"activate":true,"alpha":1,"days":1,"inputPath":"/seldon-models","iterations":5,"lambda":0.1,"local":true,"outputPath":"/seldon-models","rank":30,"startDay":1}'

    docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh ${CLIENT}"
}

do_item_similarity() {
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args \
        /all_clients/movielens/offline/similar-items '{"inputPath":"/seldon-models","outputPath":"/seldon-models","days":1,"sample":0.25,"limit":100,"dimsum_threshold":0.5}'

    docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh ${CLIENT}"

    docker run --name="upload_item_similarity_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/item-similarity/create_sql_and_upload.sh ${CLIENT}"
}

case $MODEL in
    matrix_factorization)
        do_matrix_factorization
        ;;
    item_similarity)
        do_item_similarity
        ;;
    *)
        echo "ignoring unkown model[$MODEL]"
        ;;
esac

