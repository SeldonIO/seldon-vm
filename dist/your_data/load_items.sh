#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> and <items file>"
    exit 1
fi

CLIENT=$1
ITEMS_FILE=$2
docker run --name="your_data_load_items" -it --rm -v ${STARTUP_DIR}/items_data:/your_data/items_data --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_items.sh ${CLIENT} /your_data/items_data/${ITEMS_FILE}

