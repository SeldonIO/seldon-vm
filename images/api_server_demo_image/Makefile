IMAGE=api_server_demo_image
SELDON_VERSION=0.2
EMBEDLY_KEY=

IMAGE_NAME=$(IMAGE)
PROJ_DIR=../..
-include $(PROJ_DIR)/build_settings

#MOVIE_DEMO_FRONTEND_TAG=tags/v1.2
MOVIE_DEMO_FRONTEND_TAG=

dummy:
	@echo dummy

swagger-codegen:
	git clone https://github.com/swagger-api/swagger-codegen
	cd swagger-codegen ; git checkout tags/2.0.17 ; npm install js-yaml ; cd ..

webapps/api-spec/seldon.json:swagger-codegen
	mkdir -p webapps/api-spec
	node swagger-codegen/bin/yml2swagger.js api-spec/seldon webapps/api-spec

webapps/movie-demo:
	git clone https://github.com/SeldonIO/movie-demo-frontend
	cd movie-demo-frontend ; git checkout $(MOVIE_DEMO_FRONTEND_TAG) ; npm install ; bower install ; cd ..
	cd movie-demo-frontend ; grunt build ; cd ..
	mkdir -p webapps/movie-demo
	cp -R movie-demo-frontend/dist/* webapps/movie-demo

webapps/swagger:
	mkdir -p webapps
	cp -R swagger/ webapps/swagger

webapps: webapps/swagger webapps/movie-demo webapps/api-spec/seldon.json

build_image: webapps
	docker build --force-rm=true -t ${IMAGE} .

push_to_registry:
	docker login -u $(PRIVATE_REGISTRY_USER) -p $(PRIVATE_REGISTRY_PASSWORD) -e "$(PRIVATE_REGISTRY_EMAIL)" https://$(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT) && \
		docker tag $(IMAGE_NAME) $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME) && \
		docker push $(PRIVATE_REGISTRY_HOST):$(PRIVATE_REGISTRY_PORT)/$(IMAGE_NAME)

clean:
	@rm -rf webapps
	@rm -rf swagger-codegen
	@rm -rf movie-demo-frontend
