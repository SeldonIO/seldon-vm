#!/bin/bash

set -o nounset
set -o errexit

docker exec -it spark_offline_server_container bash -c "/spark-jobs/cluster-users-by-taxomonmy.py -start-day 1 -num-days 1 -client movielens -min-cluster-size 0 -delta 0.1"


