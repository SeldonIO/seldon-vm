#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
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

echo "rename table item_similarity to item_similarity_old,item_similarity_new to item_similarity,item_similarity_old to item_similarity_new;" | mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} ${CLIENT}

