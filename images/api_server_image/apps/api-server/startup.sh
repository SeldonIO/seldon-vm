#!/bin/sh

set -o nounset
set -o errexit

STARTUP_DIR="$( cd "$( dirname "$0" )" && pwd )"

mkdir -p /mnt/labs/api/logs

/apps/tomcat7/bin/catalina.sh run

