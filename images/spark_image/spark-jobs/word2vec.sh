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
    MIN_WORD_COUNT=`echo "${JSON}" | jq -r ".min_word_count // empty"`
    if [[ ! -z "${NUM_DAYS}" ]]; then
	ARGS="${MIN_WORD_COUNT} --min-word-count ${MIN_WORD_COUNT}"
    fi
    VECTOR_SIZE=`echo "${JSON}" | jq -r ".vector_size // empty"`
    if [[ ! -z "${VECTOR_SIZE}" ]]; then
	ARGS="${ARGS} --vector-size ${VECTOR_SIZE}"
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

rm -rf ${DATA_FOLDER}/${CLIENT}/word2vec/${START_DAY}
/opt/spark/bin/spark-submit \
	--class io.seldon.spark.features.Word2VecJob \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
	/app/${JAR_FILE} \
	--client $CLIENT \
	--local \
        ${ARGS}




