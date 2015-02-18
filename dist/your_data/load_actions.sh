#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> and <actions csv>"
    exit 1
fi

CLIENT=$1
ACTIONS_FILE=$2

# create user actions (movie view history)
docker run --name="your_data_load_actions" -it --rm -v ${STARTUP_DIR}/actions_data:/your_data/actions_data --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/create_actions_json.sh ${CLIENT} /your_data/actions_data/${ACTIONS_FILE} /seldon-models/${CLIENT}/actions/1/actions.json 



