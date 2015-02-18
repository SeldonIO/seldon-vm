SELDON_VERSION=0.2
IMAGE_NAME=seldon-models
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

dummy:
	@echo dummy

movielens_demo:
	@bash get-movielens-models.sh ${SELDON_VERSION}
	@./setup-local-models-resource

build_image: movielens_demo
	docker build --force-rm=true -t ${IMAGE_NAME} .

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

clean:
	@rm -rf movielens_demo.tar.gz
	@rm -rfv movielens_demo
	@./remove-local-models-resource

