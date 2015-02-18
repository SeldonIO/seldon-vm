#!/bin/bash

set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

cd ${WORK_DIR}

if [[ $# < 5 ]]; then
    echo "Need client num-items attr_names (comma separated) output-folder jdbc-url"
    exit 1
fi

CLIENT=$1
ITEM_LIMIT=$2
ATTR_NAMES=$3
DATA_FOLDER=$4
JDBC=$5

PREFIX=svtext
JAR_FILE=semvec-lucene-tools.jar
SV_PARAMS="-raw-ids -use-item-attrs -attr-names ${ATTR_NAMES} -recreate -debug -item-limit ${ITEM_LIMIT}"

java -cp ${JAR_FILE} io.seldon.semvec.CreateLuceneIndexFromDb -l index  -jdbc ${JDBC} -itemType 1 ${SV_PARAMS}

java -cp ${JAR_FILE} pitt.search.semanticvectors.BuildIndex -trainingcycles 1 -maxnonalphabetchars -1 -minfrequency 0 -maxfrequency 1000000 -luceneindexpath index -indexfileformat text

mkdir -p ${DATA_FOLDER}

echo "copy dbs to folder ${DATA_FOLDER}"
cp termvectors.txt ${DATA_FOLDER}/termvectors.txt
cp docvectors.txt ${DATA_FOLDER}/docvectors.txt

if [ -n "$AWS_UPLOAD" ]; then
aws s3 cp --region eu-west-1 termvectors.txt s3:/${DATA_FOLDER}/termvectors.txt
aws s3 cp --region eu-west-1 docvectors.txt s3:/${DATA_FOLDER}/docvectors.txt
fi

if [ -n "$ZOOKEEPER_HOST" ]; then
/usr/share/zookeeper/bin/zkCli.sh -server ${ZOOKEEPER_HOST} set /${CLIENT}/${PREFIX} ${DATA_FOLDER}
fi


