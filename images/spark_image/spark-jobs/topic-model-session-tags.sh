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
JDBC=`echo "${JSON}" | jq -r ".jdbc"`

if [[ -z "${JDBC}" ]]; then
    echo "Can't get JDBC from consul for client ${CLIENT}"
    exit -1
fi

ARGS=" --jdbc ${JDBC}"

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/topic_model?raw`
echo "${JSON}"

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
    TAG_ATTR=`echo "${JSON}" | jq -r ".tag_attr // empty"`
    if [[ ! -z "${TAG_ATTR}" ]]; then
	ARGS="${ARGS} --tagAttr ${TAG_ATTR} "
    else
	echo "You must specify tag_attr in JSON config"
	exit -1
    fi
else
	echo "You must specify tag_attr in JSON config"
	exit -1
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

rm -rf ${DATA_FOLDER}/${CLIENT}/sessiontags/${START_DAY}
/opt/spark/bin/spark-submit \
	--class io.seldon.spark.topics.createVWTopicTraining \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
	/app/${JAR_FILE} \
	--client $CLIENT \
	--local \
        ${ARGS}




