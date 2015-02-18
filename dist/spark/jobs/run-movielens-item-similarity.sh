#!/bin/bash

set -o nounset
set -o errexit

docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.py -start-day 1 -num-days 1 -client movielens -min-users-per-item 0 -min-items-per-user 0 -threshold 0.001"


