IMAGE_NAME=mysql_image
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

dummy:
	@echo dummy

build_image:
	docker build --force-rm=true -t $(IMAGE_NAME) .

start:
	docker run --name mysql_server_container --volumes-from mysql_data -e MYSQL_ROOT_PASSWORD=mypass -d mysql_image 

attach:
	docker exec -it mysql_server_container bash

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

clean:
	@rm -rfv mysql-data
	@rm -fv backup.tar.gz

