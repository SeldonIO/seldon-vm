#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> and <users data file>"
    exit 1
fi

CLIENT=$1
USERS_FILE=$2

docker run --name="your_data_load_users" -it --rm -v ${STARTUP_DIR}/users_data:/your_data/users_data --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_users.sh ${CLIENT} /your_data/users_data/${USERS_FILE}

