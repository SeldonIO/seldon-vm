#!/bin/bash

set -o nounset
set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 2 ]]; then
    echo "Need <client name> <num topics>"
    exit 1
fi


CLIENT=$1
TOPICS=$2

mkdir -p ${WORK_DIR}/${CLIENT}
cp ${WORK_DIR}/Makefile ${WORK_DIR}/${CLIENT}
cd ${WORK_DIR}/${CLIENT}
make CLIENT=${CLIENT} LDA_TOPICS=${TOPICS} clean uploaded

