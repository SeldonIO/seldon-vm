#!/bin/bash

set -o nounset
set -o errexit

mkdir -p /mnt/labs/api/logs

/apps/api-server/add_js_embedly_prefix.sh

/apps/tomcat7/bin/catalina.sh run

