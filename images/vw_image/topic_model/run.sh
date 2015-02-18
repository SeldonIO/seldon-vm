#!/bin/bash

set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${STARTUP_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/topic_model?raw`
echo "${JSON}"
if [[ ! -z "${JSON}" ]]; then
    START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
    if [ "${START_DAY}" = 'yesterday' ]; then
	START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
    fi
    if [[ -z "${START_DAY}" ]]; then
	START_DAY=1
    fi
    DATA_FOLDER=`echo "${JSON}" | jq -r ".data_folder // empty"`
    if [[ -z "${DATA_FOLDER}" ]]; then
	DATA_FOLDER="/seldon-models"
    fi
else
    START_DAY=1
    DATA_FOLDER="/seldon-models"
fi



mkdir -p ${STARTUP_DIR}/${CLIENT}
cp ${STARTUP_DIR}/Makefile ${STARTUP_DIR}/${CLIENT}
cd ${STARTUP_DIR}/${CLIENT}

INPUT=${DATA_FOLDER}/${CLIENT}/user_tag_count/${START_DAY}
OUTPUT=${DATA_FOLDER}/${CLIENT}/topics/${START_DAY}

make CLIENT=${CLIENT} uploaded.local INPUT=${INPUT} OUTPUT=${OUTPUT}




