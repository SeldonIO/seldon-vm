#!/bin/bash

set -o nounset
set -o errexit

docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-modeling-create-session-tags.py -client movielens -start-day 1 -num-days 1 -tag-attr-id 20 -table text"
docker run --volumes-from seldon-models ${REGISTRY_PREFIX}vw_topic_model /scripts/run.sh movielens local /seldon-models/movielens/user_tag_count/1 /seldon-models/movielens/topics/1

