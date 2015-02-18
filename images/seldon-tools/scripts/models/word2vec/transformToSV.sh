#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/word2vec?raw`
echo "${JSON}"
if [[ ! -z "${JSON}" ]]; then
    START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
    if [ "${START_DAY}" = 'yesterday' ]; then
	START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
    fi
    if [[ -z "${START_DAY}" ]]; then
	START_DAY=1
    fi
    VECTOR_SIZE=`echo "${JSON}" | jq -r ".vector_size // empty"`
    if [[ -z "${VECTOR_SIZE}" ]]; then
	VECTOR_SIZE=30
    fi
else
    START_DAY=1
    VECTOR_SIZE=30
fi


cat /seldon-models/${CLIENT}/word2vec/${START_DAY}/part-* | python word2vecToSV.py -d ${VECTOR_SIZE} > /seldon-models/${CLIENT}/word2vec/${START_DAY}/docvectors.txt
echo "-vectortype REAL -dimension ${VECTOR_SIZE}" > /seldon-models/${CLIENT}/word2vec/${START_DAY}/termvectors.txt


