#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/item_similarity?raw`
echo "${JSON}"
if [[ ! -z "${JSON}" ]]; then
    START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
    if [ "${START_DAY}" = 'yesterday' ]; then
	START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
    fi
    if [[ -z "${START_DAY}" ]]; then
	START_DAY=1
    fi
else
    START_DAY=1
fi

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/db_write?raw`
echo "${JSON}"
DB_HOST=`echo "${JSON}" | jq -r ".host"`
DB_USER=`echo "${JSON}" | jq -r ".username"`
DB_PASS=`echo "${JSON}" | jq -r ".password"`

if [[ -z "${DB_HOST}" || -z "${DB_USER}" || -z "${DB_PASS}" ]]; then
    echo "Can't get keys for db settings. Stopping."
    exit -1
fi

echo "create sql for item similarity upload"
cat /seldon-models/${CLIENT}/item-similarity/${START_DAY}/part* | python /seldon-tools/scripts/models/item-similarity/createItemSimilaritySql.py > /seldon-models/${CLIENT}/item-similarity/${START_DAY}/upload.sql
echo "uploading item similarity sql to client ${CLIENT}"
mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} ${CLIENT} < /seldon-models/${CLIENT}/item-similarity/${START_DAY}/upload.sql

