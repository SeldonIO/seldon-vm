#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/db_read?raw`
echo "${JSON}"
if [[ ! -z "${JSON}" ]]; then
    JDBC=`echo "${JSON}" | jq -r ".jdbc // empty"`
    if [[ -z "${JDBC}" ]]; then
	JDBC="jdbc:mysql://mysql_server:3306/${CLIENT}?characterEncoding=utf8&user=root&password=mypass"
    fi
else
    JDBC="jdbc:mysql://mysql_server:3306/${CLIENT}?characterEncoding=utf8&user=root&password=mypass"
fi

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/semantic_vectors?raw`
echo "${JSON}"
if [[ ! -z "${JSON}" ]]; then
    START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
    if [ "${START_DAY}" = 'yesterday' ]; then
	START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
    fi
    if [[ -z "${START_DAY}" ]]; then
	START_DAY=1
    fi
    ATTR_NAMES=`echo "${JSON}" | jq -r ".attr_names // empty"`
    if [[ -z "${ATTR_NAMES}" ]]; then
	ATTR_NAMES="tags"
    fi
    ITEM_LIMIT=`echo "${JSON}" | jq -r ".item_limit // empty"`
    if [[ -z "${ITEM_LIMIT}" ]]; then
	ITEM_LIMIT=500000
    fi
    DATA_FOLDER=`echo "${JSON}" | jq -r ".data_folder // empty"`
    if [[ -z "${DATA_FOLDER}" ]]; then
	DATA_FOLDER="/seldon-models"
    fi
else
    START_DAY=1
    ATTR_NAMES="tags"
    ITEM_LIMIT=500000
    DATA_FOLDER="/seldon-models"
fi

rm -rf ${DATA_FOLDER}/${CLIENT}/svtext/${START_DAY}
${WORK_DIR}/run-training.sh ${CLIENT} ${ITEM_LIMIT} ${ATTR_NAMES} ${DATA_FOLDER}/${CLIENT}/svtext/${START_DAY} ${JDBC}


