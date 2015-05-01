#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"
DIST_DIR=${STARTUP_DIR}/..
[ -f ${DIST_DIR}/run_settings ] && source ${DIST_DIR}/run_settings

if [[ $# < 1 ]]; then
    echo "Need <client db name>"
    exit 1
fi

CLIENT=$1

mkdir -p raw_data
mkdir -p seldon_data

# download data and transform and combine data sources
docker run --name="movielens_data_transform" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon -v ${STARTUP_DIR}/raw_data:/movielens/data movielens_data_transform /movielens/scripts/run.sh

if [ "${CREATE_MOVIELENS_SAMPLE_DATA:-}" == "true" ]; then
    echo "-- Creating Movelens Sample Data --"
    ${STARTUP_DIR}/create_sample_data
fi

#clear actions
docker run --name="movielens_create_item_attrs" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/clear_actions.sh ${CLIENT}

# import item attributes and data (movies) into database
docker run --name="movielens_create_item_attrs" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_attr_schema.sh ${CLIENT} /movielens/seldon/movielens_items.json

docker run --name="movielens_import_items" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_items.sh ${CLIENT} /movielens/seldon/movielens_items.csv

docker run --name="movielens_import_users" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_users.sh ${CLIENT} /movielens/seldon/movielens_users.csv

# create user actions (movie view history)
docker run --name="movielens_create_actions" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/create_actions_json.sh ${CLIENT} /movielens/seldon/movielens_actions.csv /seldon-models/${CLIENT}/actions/1/actions.json

