#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> <model to activate>"
    exit 1
fi

CLIENT=$1
MODEL=$2

echo "Activating ${MODEL}"

set_zk_node() {
    local ZK_NODE_PATH="$1"
    local ZK_NODE_VALUE="$2"

    docker run --rm -i -t --name seldon_tools --link zookeeper_server_container:zk seldon-tools /seldon-tools/scripts/zookeeper/zkcmd.py --zk-hosts zk --cmd set --cmd-args "${ZK_NODE_PATH}" "${ZK_NODE_VALUE}"
}

do_matrix_factorization() {
    set_zk_node '/config/mf' "${CLIENT}"
}

do_item_similarity() {
    docker run --name="activate_item_similarity_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/item-similarity/activate.sh ${CLIENT}"
}

do_semantic_vectors() {
    set_zk_node '/config/svtext' "${CLIENT}"
}

do_word2vec() {
    set_zk_node '/config/word2vec' "${CLIENT}"
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

