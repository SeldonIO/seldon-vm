IMAGE_NAME=movielens_data_transform
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

DIR := ${CURDIR}
dummy:
	@echo dummy

freebase_data/freebase.json:
	mkdir -p freebase_data
	cd freebase_data ; wget http://s3-eu-west-1.amazonaws.com/static.seldon.io/datasets/freebase-movies/freebase.json ; cd .. 

build_image: freebase_data/freebase.json
	docker build -t ${IMAGE_NAME} .

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

test_out:
	mkdir -p ${DIR}/test_out

test_create_csv:test_out
	mkdir -p test_out
	mkdir -p raw_data
	docker run --name="movielens_data_transform" -it --rm -v ${DIR}/test_out:/movielens/seldon -v ${DIR}/raw_data:/movielens/data ${IMAGE_NAME} /movielens/scripts/run.sh 

test_create_actions:
	docker run --name="movielens_create_actions" -it --rm -v ${DIR}/test_out:/movielens/seldon --volumes-from seldon-models --link mysql_server_container:mysql_server  --link consul:consul seldon-tools /seldon-tools/scripts/import/create_actions_json.sh movielens /movielens/seldon/movielens_actions.csv /movielens/seldon/actions.json 

clean:
	@rm -fv freebase_data/freebase.json

