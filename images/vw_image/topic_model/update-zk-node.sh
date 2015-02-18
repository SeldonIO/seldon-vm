#!/bin/bash

set -o nounset
set -o errexit

WORK_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [[ $# < 1 ]]; then
    echo "Need <client name>"
    exit 1
fi

# test admin zk node
ZK_NODE=zookeeper_server
CLIENT=$1
YESTERDAY=`echo $(($(date --date='1 days ago' +%s) / 86400))`

zk-shell --run-once "set /${CLIENT}/topics seldon-data/${CLIENT}/topics/${YESTERDAY}" ${ZK_NODE}



 


