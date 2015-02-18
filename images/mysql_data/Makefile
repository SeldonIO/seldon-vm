SELDON_VERSION=0.2
VERSION=1.0
IMAGE=mysql_data

IMAGE_NAME=$(IMAGE)
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

mysql_data:
	@./create-movielens-dbs.sh
	@./setup-local-mysql-data-resource

build_image: mysql_data
	@make build

build:
	docker build --force-rm=true -t ${IMAGE} .

start:
	docker  run -d -v $(CURDIR)/mysql_data:/mysql_data -v $(CURDIR):/workdir --name="${IMAGE}" ${IMAGE} nginx -g 'daemon off;'

login:
	docker exec -it ${IMAGE} bash

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

clean:
	@rm -rfv mysql_data
	@rm -fv backup.tar.gz
	@rm -fv mysql_data_empty.tar.gz
	@rm -rfv mysql_data_empty
	@rm -fv mysql_data.tar.gz
	@./remove-local-mysql-data-resource

