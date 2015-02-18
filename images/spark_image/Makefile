SELDON_VERSION=0.2
VERSION=1.0.1

IMAGE_NAME=spark_image
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

dummy:
	@echo dummy

seldon-spark:
	git clone https://github.com/SeldonIO/seldon-spark


seldon-spark/target/seldon-spark-${VERSION}-jar-with-dependencies.jar:seldon-spark
	cd seldon-spark ; git checkout tags/v${VERSION} ; mvn -DskipTests=true clean package ; cd ..

app/seldon-spark-${VERSION}-jar-with-dependencies.jar:seldon-spark/target/seldon-spark-${VERSION}-jar-with-dependencies.jar
	mkdir -p app
	cp seldon-spark/target/seldon-spark-${VERSION}-jar-with-dependencies.jar app

build_image: app/seldon-spark-${VERSION}-jar-with-dependencies.jar
	docker build --force-rm=true -t spark_image .

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)


clean:
	@rm -rfv ./app
	@rm -rf seldon-spark


#
# Tests
#


# Clustering tests
test_cluster_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/cluster_by_taxonomy'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/cluster-users-by-taxonomy.sh movielens"
test_cluster_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/cluster_by_taxonomy'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/cluster-users-by-taxonomy.sh movielens"
test_cluster_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker exec consul curl -s -X PUT -d '{"min_cluster_size":0, "delta":0.01 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/cluster_by_taxonomy'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/cluster-users-by-taxonomy.sh movielens"

# item similarity tests
test_item_similarity_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/item_similarity'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh movielens"

test_item_similarity_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/item_similarity'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh movielens"

test_item_similarity_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"min_users_per_item":0, "min_items_per_user":0, "max_users_per_item":100000, "threshold":0.01, "dimsum_threshold":0.1 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/item_similarity'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/item-similarity.sh movielens"

#topic model tests
test_topic_modelling_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/topic_model'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-model-session-tags.sh movielens"

test_topic_modelling_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/topic_model'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-model-session-tags.sh movielens"

test_topic_modelling_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"tag_attr":"description" }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/topic_model'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/topic-model-session-tags.sh movielens"
#word2vec
test_word2vec_sessionitems_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/session_items'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh movielens"

test_word2vec_sessionitems_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/session_items'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh movielens"

test_word2vec_sessionitems_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"min_actions_per_user":0, "max_actions_per_user":30000, "max_session_gap":-1 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/session_items'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/session-items.sh movielens"

test_word2vec_create_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/word2vec'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh movielens"

test_word2vec_create_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/word2vec'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh movielens"

test_word2vec_create_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"min_word_count":50, "vector_size":30 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/word2vec'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/word2vec.sh movielens"
#matrix factorization
test_mf_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/matrix_factorization'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh movielens"

test_mf_movielens_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/matrix_factorization'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh movielens"

test_mf_movielens_consul:
	docker exec consul curl -s -X PUT -d '{"rank":30, "lambda":0.1, "alpha":1, "iterations":5 }' 'http://localhost:8500/v1/kv/seldon/movielens/algs/matrix_factorization'
	docker exec -it spark_offline_server_container bash -c "/spark-jobs/matrix-factorization.sh movielens"


#
# explicit tests
#

test_cluster_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
	--class com.rummblelabs.cluster.ClusterUsersByDimension \
	/app/spark-1.0-jar-with-dependencies.jar \
	--client movielens \
	--input-path /seldon-models \
	--output-path /seldon-models \
	--local \
	--jdbc 'jdbc:mysql://mysql_server:3306/movielens?user=root&password=mypass&characterEncoding=utf8' \
	--start-day 1 \
	--numdays 1 \
	--minClusterSize 0 \
	--delta 0.1"

test_mf_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
        --class com.seldon.mf.MfModelCreation \
        --master local \
	--driver-memory 13g \
        /app/SeldonMF-assembly-1.0.jar \
        movielens 1 1 30 0.1 1 5 zookeeper_server \
	local://seldon-models/movielens/actions/ \
	local://seldon-models/movielens/matrix-factorization/ \
	awskey assecret"


test_item_similarity_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
	--class com.rummblelabs.mllib.SimilarItems \
	--driver-memory 13g \
	/app/spark-1.0-jar-with-dependencies.jar \
	--client movielens \
	--input-path /seldon-models \
	--output-path /seldon-models \
	--local \
	--start-day 1 \
	--numdays 1 \
	--minUsersPerItem 1 \
	--minItemsPerUser 1 \
	--maxUsersPerItem 100000 \
        --threshold 0.001 \
        --dimsum-threshold 0.1 "

test_topic_modelling_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
	--class com.rummblelabs.topics.createVWTopicTraining \
	--driver-memory 13g \
	/app/spark-1.0-jar-with-dependencies.jar \
	--client movielens \
	--input-path /seldon-models \
	--output-path /seldon-models \
	--local \
	--start-day 1 \
	--numdays 1 \
	--jdbc 'jdbc:mysql://mysql_server:3306/movielens?user=root&password=mypass&characterEncoding=utf8' \
	--tagAttr description "


test_word2vec_sessionitems_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
	--class com.rummblelabs.topics.SessionItems \
	--driver-memory 13g \
	--executor-memory 13g \
	/app/spark-1.0-jar-with-dependencies.jar \
	--client movielens \
	--input-path /seldon-models \
	--output-path /seldon-models \
	--local \
	--start-day 1 \
	--numdays 1 \
	--minActionsPerUser 1 \
	--maxActionsPerUser 10000 \
	--maxSessionGap -1 "


test_word2vec_create_movielens_explicit:
	docker exec -it spark_offline_server_container bash -c "/opt/spark/bin/spark-submit \
	--class com.rummblelabs.features.Word2VecJob \
	--driver-memory 13g \
	--executor-memory 13g \
	/app/spark-1.0-jar-with-dependencies.jar \
	--client movielens \
	--input-path /seldon-models \
	--output-path /seldon-models \
	--local \
	--start-day 1 \
	--numdays 1 \
	--min-word-count 50 \
	--vector-size 30 "





