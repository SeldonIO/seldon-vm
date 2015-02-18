#!/bin/bash

set -o nounset
set -o errexit

if [[ $# < 2 ]]; then
    echo "Need <client/db> <input_file>"
    exit 1
fi

CLIENT=$1
IN=$2

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/db_write?raw`
echo "${JSON}"
DB_HOST=`echo "${JSON}" | jq -r ".host"`
DB_USER=`echo "${JSON}" | jq -r ".username"`
DB_PASS=`echo "${JSON}" | jq -r ".password"`

if [[ -z "${DB_HOST}" || -z "${DB_USER}" || -z "${DB_PASS}" ]]; then
    echo "Can't get keys for db settings. Stopping."
    exit -1
fi

python /seldon-tools/scripts/import/add_users.py -users ${IN} -db-host ${DB_HOST} -db-user ${DB_USER} -db-pass ${DB_PASS} -client ${CLIENT}


