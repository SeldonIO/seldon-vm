#!/bin/bash

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 1 ]]; then
    echo "Need <client db name>"
    exit 1
fi

CLIENT=$1

#clear actions
docker run --name="your_data_clear_actions" -it --rm --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/clear_actions.sh ${CLIENT}
