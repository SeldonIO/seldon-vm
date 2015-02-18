#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> <models to activate>"
    exit 1
fi

CLIENT=$1
MODELS=$2

# day is hardwired to 1 for demo as historical data all placed into this day

if [[ $MODELS == *"matrix_factorization"* ]]
then
    echo "Activating matrix_factorization"
    pushd ${STARTUP_DIR}/../zookeeper
    echo "set,/${CLIENT}/mf,local://seldon-models/${CLIENT}/matrix-factorization/1" >> zoo.cfg
    echo "append,/clients/mf,${CLIENT}" >> zoo.cfg
    tail -2 zoo.cfg | xargs -r -I {} docker exec zookeeper_server_container bash -c "python /zookeeper/scripts/update_zk.py < <(echo {})"
    popd
fi

if [[ $MODELS == *"item_similarity"* ]]
then
    echo "Activating item_similarity"
    docker run --name="activate_item_similarity_model" -it --rm --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools bash -c "/seldon-tools/scripts/models/item-similarity/activate.sh ${CLIENT}"
fi

if [[ $MODELS == *"semantic_vectors"* ]]
then
    echo "Activating semantic_vectors"
    pushd ${STARTUP_DIR}/../zookeeper
    echo "set,/${CLIENT}/svtext,local://seldon-models/${CLIENT}/svtext/1" >> zoo.cfg
    echo "append,/clients/svtext,${CLIENT}" >> zoo.cfg
    tail -2 zoo.cfg | xargs -r -I {} docker exec zookeeper_server_container bash -c "python /zookeeper/scripts/update_zk.py < <(echo {})"
    popd
fi

if [[ $MODELS == *"word2vec"* ]]
then
    echo "Activating word2vec"
    pushd ${STARTUP_DIR}/../zookeeper
    echo "set,/${CLIENT}/word2vec,local://seldon-models/${CLIENT}/word2vec/1" >> zoo.cfg
    echo "append,/clients/word2vec,${CLIENT}" >> zoo.cfg
    tail -2 zoo.cfg | xargs -r -I {} docker exec zookeeper_server_container bash -c "python /zookeeper/scripts/update_zk.py < <(echo {})"
    popd
fi

#if [[ $MODELS == *"topic_model"* ]]
#then
#    pushd ${STARTUP_DIR}/../zookeeper
#    echo "set,/${CLIENT}/topics,local://seldon-models/${CLIENT}/topics/1" >> zoo.cfg
#    echo "append,/clients/topics,${CLIENT}" >> zoo.cfg
#    tail -2 zoo.cfg | xargs -r -I {} docker exec zookeeper_server_container bash -c "python /zookeeper/scripts/update_zk.py < <(echo {})"
#    popd
#fi










