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

ARGS=""
if [[ ! -z "${JSON}" ]]; then
    JDBC=`echo "${JSON}" | jq -r ".jdbc // empty"`

    if [[ -z "${JDBC}" ]]; then
	ARGS=" --jdbc jdbc:mysql://mysql_server:3306/${CLIENT}?characterEncoding=utf8&user=root&password=mypass"
    else
	ARGS=" --jdbc ${JDBC}"
    fi
else
    ARGS=" --jdbc jdbc:mysql://mysql_server:3306/${CLIENT}?characterEncoding=utf8&user=root&password=mypass"
fi

JSON=`curl -s http://consul:8500/v1/kv/seldon/${CLIENT}/algs/cluster_by_taxonomy?raw`
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
    MIN_CLUSTER_SIZE=`echo "${JSON}" | jq -r ".min_cluster_size // empty"`
    if [[ ! -z "${MIN_CLUSTER_SIZE}" ]]; then
	ARGS="${ARGS} --minClusterSize ${MIN_CLUSTER_SIZE}"
    fi
    CLUSTER_DELTA=`echo "${JSON}" | jq -r ".delta // empty"`
    if [[ ! -z "${CLUSTER_DELTA}" ]]; then
	ARGS="${ARGS} --delta ${CLUSTER_DELTA}"
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

rm -rf ${DATA_FOLDER}/${CLIENT}/cluster/${START_DAY}
/opt/spark/bin/spark-submit \
	--class io.seldon.spark.cluster.ClusterUsersByDimension \
        --executor-memory ${MEM} \
	--driver-memory ${MEM} \
	/app/${JAR_FILE} \
	--client $CLIENT \
	--local \
        ${ARGS} 


