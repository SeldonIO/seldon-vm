#!/bin/bash

set -o nounset
set -o errexit

########################
# Movielens algorithms #
########################

# clustering of users by taxonomy
docker exec consul curl -s -X PUT -d '{"min_cluster_size":0, "delta":0.01 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/cluster_by_taxonomy'
# matrix factorization
docker exec consul curl -s -X PUT -d '{"rank":30, "lambda":0.1, "alpha":1, "iterations":5 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/matrix_factorization'
# item similarity
docker exec consul curl -s -X PUT -d '{"min_users_per_item":0, "min_items_per_user":0, "max_users_per_item":100000, "threshold":0.01, "dimsum_threshold":0.1 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/item_similarity'
# semantic vectors
docker exec consul curl -s -X PUT -d '{"item_limit":"30000","attr_names":"description","base_output_folder":"/seldon-models/movielens/svtext/1"}' 'http://localhost:8500/v1/kv/seldon/testclient/algs/semantic_vectors'
#word2vec
docker exec consul curl -s -X PUT -d '{"min_actions_per_user":0, "max_actions_per_user":30000, "max_session_gap":-1 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/session_items'
docker exec consul curl -s -X PUT -d '{"min_word_count":50, "vector_size":30 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/word2vec'
#topic models
docker exec consul curl -s -X PUT -d '{"tag_attr":"description" }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/topic_model_session_tags'





