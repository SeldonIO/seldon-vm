#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/session_items?raw`
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
    MIN_ACTIONS_PER_USER=`echo "${JSON}" | jq -r ".min_actions_per_user // empty"`
    if [[ ! -z "${MIN_ACTIONS_PER_USER}" ]]; then
	ARGS="${ARGS} --minActionsPerUser ${MIN_ACTIONS_PER_USER}"
    fi
    MAX_ACTIONS_PER_USER=`echo "${JSON}" | jq -r ".max_actions_per_user // empty"`
    if [[ ! -z "${MAX_ACTIONS_PER_USER}" ]]; then
	ARGS="${ARGS} --maxActionsPerUser ${MAX_ACTIONS_PER_USER}"
    fi
    MAX_SESSION_GAP=`echo "${JSON}" | jq -r ".max_session_gap // empty"`
    if [[ ! -z "${MAX_SESSION_GAP}" ]]; then
	ARGS="${ARGS} --maxSessionGap ${MAX_SESSION_GAP}"
    fi
else
    DATA_FOLDER=/seldon-models
    START_DAY=1
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

rm -rf ${DATA_FOLDER}/${CLIENT}/sessionitems/${START_DAY}
/opt/spark/bin/spark-submit \
	--class io.seldon.spark.topics.SessionItems \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
	/app/${JAR_FILE} \
	--client $CLIENT \
	--local \
        ${ARGS}



