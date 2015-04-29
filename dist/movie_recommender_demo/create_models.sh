#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

CLIENT=movielens
MODEL=matrix_factorization
MODEL=item_similarity
MODEL=semantic_vectors
MODEL=word2vec

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

do_semantic_vectors() {
    MYSQL_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' 'mysql_server_container')
    MYSQL_ROOT_PASSWORD=mypass
    JOB_CONFIG='{"inputPath":"/seldon-models","outputPath":"/seldon-models","startDay":1,"days":1,"activate":true,"itemType":1,"itemLimit":10000,"tagAttrs":"movielens_tags_full","jdbc":"jdbc:mysql://'${MYSQL_HOST}':3306/movielens?user=root&password='${MYSQL_ROOT_PASSWORD}'&characterEncoding=utf8"}'
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args \
    /all_clients/movielens/offline/semvec "${JOB_CONFIG}"

    docker run --rm -i -t \
    --volumes-from seldon-models \
    --link zookeeper_server_container:zk \
    seldonio/semantic-vectors-for-seldon bash -c './semvec/semantic-vectors.py --client movielens --zookeeper zk:2181'
}

do_word2vec() {
    JOB_PATH=/all_clients/movielens/offline/sessionitems
    JOB_CONFIG='{"inputPath":"/seldon-models","outputPath":"/seldon-models","startDay":1,"days":1,"maxIntraSessionGapSecs":-1,"minActionsPerUser":0,"maxActionsPerUser":100000}'
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args "${JOB_CONFIG}" "${JOB_PATH}"

    docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh ${CLIENT}"

    ZK_JOB_PATH=/all_clients/movielens/offline/word2vec
    ZK_JOB_CONFIG='{"inputPath":"/seldon-models","outputPath":"/seldon-models","activate":true,"startDay":1,"days":1,"activate":true,"minWordCount":50,"vectorSize":200}'
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args "${ZK_JOB_PATH}" "${ZK_JOB_CONFIG}"

    docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh ${CLIENT}"
}

case $MODEL in
    matrix_factorization)
        do_matrix_factorization
        ;;
    item_similarity)
        do_item_similarity
        ;;
    semantic_vectors)
        do_semantic_vectors
        ;;
    word2vec)
        do_word2vec
        ;;
    *)
        echo "ignoring unkown model[$MODEL]"
        ;;
esac

