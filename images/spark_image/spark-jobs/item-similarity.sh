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
ARGS=""
if [[ ! -z "${JSON}" ]]; then
    START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
    if [ "${START_DAY}" = 'yesterday' ]; then
	START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
    fi
    if [[ ! -z "${START_DAY}" ]]; then
	ARGS="${ARGS} --start-day ${START_DAY}"
    else
	START_DAY=1
    fi
    NUM_DAYS=`echo "${JSON}" | jq -r ".num_days // empty"`
    if [[ ! -z "${NUM_DAYS}" ]]; then
	ARGS="${ARGS} --numdays ${NUM_DAYS}"
    fi
    DATA_FOLDER=`echo "${JSON}" | jq -r ".data_folder // empty"`
    if [[ ! -z "${DATA_FOLDER}" ]]; then
	ARGS="${ARGS} --input-path ${DATA_FOLDER} --output-path ${DATA_FOLDER}"
    else
	DATA_FOLDER=/seldon-models
    fi
    # alg specific args
    MIN_USERS_PER_ITEM=`echo "${JSON}" | jq -r ".min_users_per_item // empty"`
    if [[ ! -z "${MIN_USERS_PER_ITEM}" ]]; then
	ARGS="${ARGS} --minUsersPerItem ${MIN_USERS_PER_ITEM}"
    fi
    MIN_ITEMS_PER_USER=`echo "${JSON}" | jq -r ".min_items_per_user // empty"`
    if [[ ! -z "${MIN_ITEMS_PER_USER}" ]]; then
	ARGS="${ARGS} --minItemsPerUser ${MIN_ITEMS_PER_USER}"
    fi
    MAX_USERS_PER_ITEM=`echo "${JSON}" | jq -r ".max_users_per_item // empty"`
    if [[ ! -z "${MAX_USERS_PER_ITEM}" ]]; then
	ARGS="${ARGS} --maxUsersPerItem ${MAX_USERS_PER_ITEM}"
    fi
    THRESHOLD=`echo "${JSON}" | jq -r ".threshold // empty"`
    if [[ ! -z "${THRESHOLD}" ]]; then
	ARGS="${ARGS} --threshold ${THRESHOLD}"
    fi
    DIMSUM_THRESHOLD=`echo "${JSON}" | jq -r ".dimsum_threshold //empty"`
    if [[ ! -z "${DIMSUM_THRESHOLD}" ]]; then
	ARGS="${ARGS} --dimsum-threshold ${DIMSUM_THRESHOLD}"
    fi
    SAMPLE=`echo "${JSON}" | jq -r ".sample //empty"`
    if [[ ! -z "${SAMPLE}" ]]; then
	ARGS="${ARGS} --sample ${SAMPLE}"
    fi
else
    START_DAY=1
    DATA_FOLDER=/seldon-models
fi
echo "ARGS are ${ARGS}"

JSON=`curl -s http://consul:8500/v1/kv/seldon/spark?raw`
echo "${JSON}"
if [[ -z "${JSON}" ]]; then
    JSON="{}"
fi
MEM=`echo "${JSON}" | jq -r ".executor_memory // empty"`
if [[ -z "${MEM}" ]]; then
    MEM="5g"
fi
echo "Running with executor-memory ${MEM}"

JAR_FILE=`ls /app`
JAR_FILE=`basename ${JAR_FILE}`
echo "jar = ${JAR_FILE}"

rm -rf ${DATA_FOLDER}/${CLIENT}/item-similarity/${START_DAY}
/opt/spark/bin/spark-submit \
	--class io.seldon.spark.mllib.SimilarItems \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
	/app/${JAR_FILE} \
	--client $CLIENT \
	--local \
        ${ARGS}



