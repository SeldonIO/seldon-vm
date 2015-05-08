#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

CLIENT=movielens
MODELS=( "matrix_factorization" "semantic_vectors" "word2vec" "item_similarity")
YOUR_DATA_DIR=${STARTUP_DIR}/../your_data

echo "restarting all containers to get clean state..."
${STARTUP_DIR}/../stop-all
${STARTUP_DIR}/start-all-for-models

${STARTUP_DIR}/download_and_create_data.sh $CLIENT

for model in "${MODELS[@]}"
do
    echo "Creating model $model for client $CLIENT"
    ${YOUR_DATA_DIR}/create_models.sh ${CLIENT} ${model}
    ${YOUR_DATA_DIR}/activate_models.sh ${CLIENT} ${model}
done

${STARTUP_DIR}/../start-all

