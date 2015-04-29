#!/bin/bash

set -o nounset
set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 1 ]]; then
    echo "Need client"
    exit 1
fi

CLIENT=$1

JOB_OUTPUT_FOLDLER_NAME=sessionitems
JOB_CLASS="io.seldon.spark.topics.SessionItems"
MEM="2g"

DATA_FOLDER=/seldon-models
START_DAY=1
JAR_FILE=`ls /app`
JAR_FILE=`basename ${JAR_FILE}`
JAR_FILE_PATH=/app/${JAR_FILE}
SPARK_HOME=/opt/spark
OUTPUT_FPATH=${DATA_FOLDER}/${CLIENT}/${JOB_OUTPUT_FOLDLER_NAME}/${START_DAY}

echo "jar = ${JAR_FILE_PATH}"
echo "job_class[${JOB_CLASS}]"
echo "Running with executor-memory ${MEM}"

rm -rf ${OUTPUT_FPATH} && echo "removed $OUTPUT_FPATH"

${SPARK_HOME}/bin/spark-submit \
	--class ${JOB_CLASS} \
    --master "local" \
    --executor-memory ${MEM} \
    --driver-memory ${MEM} \
    ${JAR_FILE_PATH} \
        --client ${CLIENT} \
        --zookeeper zookeeper_server \
        --startDay ${START_DAY}

