#!/bin/bash

set -o nounset
set -o errexit

#setup database settings
docker exec consul curl -s -X PUT -d '{"executor_memory":"2g"}' 'http://localhost:8500/v1/kv/seldon/spark'
