SELDON_VERSION=0.2

IMAGE_NAME=api_server_image
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

dummy:
	@echo dummy

API_SERVER_VERSION=$(shell cat ./__API_SERVER_VERSION__)

check_version:
	@echo "API_SERVER_VERSION[$(API_SERVER_VERSION)]"

webapps:
	@./create-webapps-from-github ${API_SERVER_VERSION}

build_image: webapps
	docker build --force-rm=true -t api_server_image .
	docker tag -f api_server_image api_server_image:$(API_SERVER_VERSION)

clean:
	@rm -rfv ./webapps
	@rm -rfv ./*.war

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

