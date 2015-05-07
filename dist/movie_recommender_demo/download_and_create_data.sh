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
YOUR_DATA_DIR=${STARTUP_DIR}/../your_data

mkdir -p raw_data
mkdir -p seldon_data

# download data and transform and combine data sources
docker run --name="movielens_data_transform" -it --rm -v ${STARTUP_DIR}/seldon_data:/movielens/seldon -v ${STARTUP_DIR}/raw_data:/movielens/data movielens_data_transform /movielens/scripts/run.sh

if [ "${CREATE_MOVIELENS_SAMPLE_DATA:-}" == "true" ]; then
    echo "-- Creating Movelens Sample Data --"
    ${STARTUP_DIR}/create_sample_data
fi

clear_actions() {
    echo "-- clearing actions for ${CLIENT} ---"
    ${YOUR_DATA_DIR}/clear_actions.sh ${CLIENT}
}

add_item_attributes() {
    echo "-- adding item attributes for ${CLIENT} --"
    local SCHEMA_FILE=movielens_items.json
    cp -v ${STARTUP_DIR}/seldon_data/${SCHEMA_FILE} ${YOUR_DATA_DIR}/schema/${SCHEMA_FILE}
    ${YOUR_DATA_DIR}/load_schema.sh ${CLIENT} ${SCHEMA_FILE}
}

import_items() {
    echo "-- importing items for ${CLIENT}"
    local ITEMS_FILE=movielens_items.csv
    cp -v ${STARTUP_DIR}/seldon_data/${ITEMS_FILE} ${YOUR_DATA_DIR}/items_data/${ITEMS_FILE}
    ${YOUR_DATA_DIR}/load_items.sh ${CLIENT} ${ITEMS_FILE}
}

import_users() {
    echo "-- importing users for ${CLIENT}"
    local USERS_FILE=movielens_users.csv
    cp -v ${STARTUP_DIR}/seldon_data/${USERS_FILE} ${YOUR_DATA_DIR}/users_data/${USERS_FILE}
    ${YOUR_DATA_DIR}/load_users.sh ${CLIENT} ${USERS_FILE}
}

create_user_actions() {
    echo "-- creating user actions for ${CLIENT}"
    local ACTIONS_FILE=movielens_actions.csv
    cp -v ${STARTUP_DIR}/seldon_data/${ACTIONS_FILE} ${YOUR_DATA_DIR}/actions_data/${ACTIONS_FILE}
    ${YOUR_DATA_DIR}/load_actions.sh ${CLIENT} ${ACTIONS_FILE}
}

clear_actions
add_item_attributes
import_items
import_users
create_user_actions

