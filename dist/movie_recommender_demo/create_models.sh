#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

CLIENT=movielens
MODEL=matrix_factorization

do_matrix_factorization() {
    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args /all_clients/movielens/offline/matrix-factorization '{"activate":true,"alpha":1,"days":1,"inputPath":"/seldon-models","iterations":5,"lambda":0.1,"local":true,"outputPath":"/seldon-models","rank":30,"startDay":1}'

    docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh ${CLIENT}"
}

case $MODEL in
    matrix_factorization)
        do_matrix_factorization
        ;;
    *)
        echo "ignoring unkown model[$MODEL]"
        ;;
esac

