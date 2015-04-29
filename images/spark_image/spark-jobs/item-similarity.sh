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

DATA_FOLDER=/seldon-models
START_DAY=1
MEM="2g"

rm -rf ${DATA_FOLDER}/${CLIENT}/item-similarity/${START_DAY}

JAR_FILE=`ls /app`
JAR_FILE=`basename ${JAR_FILE}`
JAR_FILE_PATH=/app/${JAR_FILE}
SPARK_HOME=/opt/spark

echo "jar = ${JAR_FILE_PATH}"
echo "Running with executor-memory ${MEM}"

${SPARK_HOME}/bin/spark-submit \
    --class "io.seldon.spark.mllib.SimilarItems" \
    --master "local" \
    --executor-memory ${MEM} \
    --driver-memory ${MEM} \
    ${JAR_FILE_PATH} \
        --client ${CLIENT} \
        --zookeeper zookeeper_server \
        --startDay ${START_DAY}

