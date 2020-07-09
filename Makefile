.DEFAULT_GOAL := ls

.PHONY := build start rm rmi shell volume create ls

NAME := unifi-network-controller

VOLUME := /opt/unifi-network-controller
LIB := var/lib
LOG := var/log
UNIFI_LIB := $(VOLUME)/$(LIB)/unifi:/$(LIB)/unifi
UNIFI_LOG := $(VOLUME)/$(LOG)/unifi:/$(LOG)/unifi
MONGO_LIB := $(VOLUME)/$(LIB)/mongodb:/$(LIB)/mongodb
MONGO_LOG := $(VOLUME)/$(LOG)/mongodb:/$(LOG)/mongodb

volume:
	mkdir -p $(VOLUME)/$(LIB)/unifi  # /var/lib/unifi
	mkdir -p $(VOLUME)/$(LOG)/unifi  # /var/log/unifi
	mkdir -p $(VOLUME)/$(LIB)/mongodb  # /var/lib/mongodb
	mkdir -p $(VOLUME)/$(LOG)/mongodb  # /var/log/mongodb

build:
	docker build --no-cache=true --tag $(NAME) .

ls:
	docker container ls --filter 'name=$(NAME)' -a

create:
	docker create --name $(NAME) --init --volume $(UNIFI_LIB) --volume $(UNIFI_LOG) --volume $(MONGO_LIB) --volume $(MONGO_LOG) --privileged --network=host -e TZ='America/Pacific' $(NAME):latest

shell:
	docker run --init -ti --volume $(UNIFI_LIB) --volume $(UNIFI_LOG) --volume $(MONGO_LIB) --volume $(MONGO_LOG) --privileged --network=host -e TZ='America/Pacific' $(NAME):latest /bin/bash

start:
	docker start $(NAME)

rm:
	-docker rm $(NAME)

rmi:
	-docker rmi $(NAME)
