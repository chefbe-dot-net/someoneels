DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

image:
	docker build -t chefbe/someoneels .

image.push:
	docker push chefbe/someoneels

up:
	docker run --rm -p 3000:3000 chefbe/someoneels

tests:
	bundle exec rake test
