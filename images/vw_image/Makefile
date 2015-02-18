VERSION=1.0
IMAGE=vw_image

IMAGE_NAME=$(IMAGE)
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

build_image:
	docker build -t ${IMAGE} .

tag:
	docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME):$(VERSION)

push:
	docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME):$(VERSION)

test_movielens_consul_noval:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/'
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker run --link consul:consul --volumes-from seldon-models ${IMAGE} /vw/topic_model/run.sh movielens  

test_movielens_consul_empty:
	docker exec consul curl -s -X DELETE 'http://localhost:8500/v1/kv/seldon/movielens/algs/'
	docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
	docker run --link consul:consul --volumes-from seldon-models ${IMAGE} /vw/topic_model/run.sh movielens  

test_movielens:
	docker run --link consul:consul --volumes-from seldon-models ${IMAGE} /vw/topic_model/run.sh movielens  


clean:
