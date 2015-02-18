#!/bin/bash

set -o nounset
set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"
PROJDIR=${WORK_DIR}/../..

rm -fr ${WORK_DIR}/mysql_data
mkdir -p ${WORK_DIR}/mysql_data
make build
make start
pushd ../mysql_image/; make start; popd
echo "Sleeping to allow mysql to start"
sleep 25


${WORK_DIR}/movielens-db-setup
${PROJDIR}/dist/mysql/stop-mysql-server
#rm -f ${WORK_DIR}/backup.tar.gz
#${WORK_DIR}/backup-mysql-data
docker run --rm --volumes-from mysql_data ubuntu:trusty /bin/bash -c 'chmod -R a+rwx /mysql_data'
${PROJDIR}/dist/mysql_data/stop-mysql-data
#${WORK_DIR}/extract-data ${WORK_DIR}/backup.tar.gz
echo "Success - ./mysql_data created"

