#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/matrix_factorization?raw`
echo "${JSON}"
ARGS=""
if [[ -z "${JSON}" ]]; then
    JSON="{}"
fi

START_DAY=`echo "${JSON}" | jq -r ".start_day // empty"`
if [ "${START_DAY}" = 'yesterday' ]; then
    START_DAY=$(($(perl -e 'use POSIX;print strftime "%s",localtime time-86400;')/86400))
fi
if [[ ! -z "${START_DAY}" ]]; then
    ARGS="${ARGS} ${START_DAY}"
else
    START_DAY=1
    ARGS="${ARGS} 1"
fi
NUM_DAYS=`echo "${JSON}" | jq -r ".num_days // empty"`
if [[ ! -z "${NUM_DAYS}" ]]; then
    ARGS="${ARGS} ${NUM_DAYS}"
else
    ARGS="${ARGS} 1"
fi
RANK=`echo "${JSON}" | jq -r ".rank //empty"`
if [[ ! -z "${RANK}" ]]; then
    ARGS="${ARGS} ${RANK}"
else
    ARGS="${ARGS} 30"
fi
LAMBDA=`echo "${JSON}" | jq -r ".lambda // empty"`
if [[ ! -z "${LAMBDA}" ]]; then
    ARGS="${ARGS} ${LAMBDA}"
else
    ARGS="${ARGS} 0.1"
fi
ALPHA=`echo "${JSON}" | jq -r ".alpha // empty"`
if [[ ! -z "${ALPHA}" ]]; then
    ARGS="${ARGS} ${ALPHA}"
else
    ARGS="${ARGS} 1"
fi
ITERATIONS=`echo "${JSON}" | jq -r ".iterations // empty"`
if [[ ! -z "${ITERATIONS}" ]]; then
    ARGS="${ARGS} ${ITERATIONS}"
else
    ARGS="${ARGS} 6"
fi
ARGS="${ARGS} zookeeper_server"
DATA_FOLDER=`echo "${JSON}" | jq -r ".data_folder // empty"`
if [[ ! -z "${DATA_FOLDER}" ]]; then
    ARGS="${ARGS} ${DATA_FOLDER}/${CLIENT}/actions/ ${DATA_FOLDER}/${CLIENT}/matrix-factorization/"
else
    ARGS="${ARGS} local://seldon-models/${CLIENT}/actions/ local://seldon-models/${CLIENT}/matrix-factorization/"
    DATA_FOLDER="/seldon-models"
fi


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

rm -rf ${DATA_FOLDER}/${CLIENT}/matrix-factorization/${START_DAY}
/opt/spark/bin/spark-submit \
        --class io.seldon.spark.mllib.MfModelCreation \
        --master local \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
        /app/${JAR_FILE} \
        ${CLIENT} ${ARGS} \
        awskey assecret


