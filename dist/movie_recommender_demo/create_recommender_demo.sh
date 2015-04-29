#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "restarting all containers to get clean state..."
${STARTUP_DIR}/../stop-all
${STARTUP_DIR}/start-all-for-models

CLIENT=movielens

MODELS=( "matrix_factorization" "semantic_vectors" "word2vec" "item_similarity")

### TODO put back in download_and_create_data.sh
###${STARTUP_DIR}/download_and_create_data.sh $CLIENT
for model in "${MODELS[@]}"
do
    echo "Creating model $model for client $CLIENT"
    ${STARTUP_DIR}/create_models.sh ${CLIENT} ${model}
    ### TODO put back in the activate_models.sh
    ###${STARTUP_DIR}/activate_models.sh ${CLIENT} ${model}
done

${STARTUP_DIR}/../start-all

