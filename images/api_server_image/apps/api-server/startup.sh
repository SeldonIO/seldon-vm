#!/bin/sh

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

mkdir -p /data-logs/seldon-server
ln -snv /data-logs/seldon-server /apps/tomcat7/logs/

/apps/tomcat7/bin/catalina.sh run

