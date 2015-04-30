#!/bin/bash

set -o nounset
set -o errexit

mkdir -p /data-logs/seldon-server
ln -snv /data-logs/seldon-server /apps/tomcat7/logs/

/apps/api-server/add_js_embedly_prefix.sh

/apps/tomcat7/bin/catalina.sh run

