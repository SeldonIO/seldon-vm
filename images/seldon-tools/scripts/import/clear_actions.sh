#!/bin/bash

set -o nounset
set -o errexit

if [[ $# < 1 ]]; then
    echo "Need <client/db>"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/db_write?raw`
echo "${JSON}"
DB_HOST=`echo "${JSON}" | jq -r ".host"`
DB_USER=`echo "${JSON}" | jq -r ".username"`
DB_PASS=`echo "${JSON}" | jq -r ".password"`

if [[ -z "${DB_HOST}" || -z "${DB_USER}" || -z "${DB_PASS}" ]]; then
    echo "Can't get keys for db settings. Stopping."
    exit -1
fi

echo "truncate actions" |  mysql -h ${DB_HOST} -u${DB_USER} -p${DB_PASS} ${CLIENT}


