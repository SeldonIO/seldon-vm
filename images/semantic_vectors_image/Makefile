IMAGE=semantic_vectors_image
VERSION=1.2
SELDON_VERSION=0.2

IMAGE_NAME=$(IMAGE)
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

semantic-vectors-lucene-tools:
	git clone https://github.com/SeldonIO/semantic-vectors-lucene-tools

semantic-vectors-lucene-tools/target/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar:semantic-vectors-lucene-tools
	cd semantic-vectors-lucene-tools ; git checkout tags/v${VERSION} ; mvn -DskipTests=true clean package ; cd ..

scripts/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar:semantic-vectors-lucene-tools/target/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar
	cp semantic-vectors-lucene-tools/target/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar scripts
	cd scripts ; ln -s semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar semvec-lucene-tools.jar ; cd ..

build_image: scripts/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar
	docker build -t ${IMAGE} .


run-shell:
	docker run --name="testing_semvec" -t -i --rm --volumes-from general_logs --volumes-from seldon_data --link mysql:mysql --link consul:consul --link zookeeper:zookeeper -e "ZOOKEEPER_HOST=zookeeper" ${IMAGE} bash

tag:
	docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME):$(VERSION)

push:
	docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME):$(VERSION)



### tests



test_explicit:
	docker run --name="testing_semvec" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul ${IMAGE} bash -c "/scripts/run-training.sh movielens 30000 description /seldon-models/movielens/svtext/2 'jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass'"
#mysql_server root mypass"

test_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/semantic_vectors'
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker run --name="testing_semvec" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul ${IMAGE} bash -c "/scripts/run-training-consul.sh movielens"

test_consul_empty:
	docker exec consul curl -s -X PUT -d '{}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/semantic_vectors'
	docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker run --name="testing_semvec" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul ${IMAGE} bash -c "/scripts/run-training-consul.sh movielens"

test_consul:
	docker exec consul curl -s -X PUT -d '{"day":1,"item_limit":"30000","attr_names":"description","base_output_folder":"/seldon-models"}' 'http://localhost:8500/v1/kv/seldon/movielens/algs/semantic_vectors'
	docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker run --name="testing_semvec" --rm --volumes-from seldon-models --link mysql_server_container:mysql_server --link consul:consul ${IMAGE} bash -c "/scripts/run-training-consul.sh movielens"

clean:
	@rm -f scripts/semvec-lucene-tools-${VERSION}-jar-with-dependencies.jar
	@rm -f scripts/semvec-lucene-tools.jar
	@rm -rf semantic-vectors-lucene-tools/
