#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client db name> and <schema file>"
    exit 1
fi

CLIENT=$1
SCHEMA_FILE=$2

# import item attributes into database
docker run --name="your_data_create_item_attrs" -it --rm -v ${STARTUP_DIR}/schema:/your_data/schema --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/add_attr_schema.sh ${CLIENT} /your_data/schema/${SCHEMA_FILE} 

