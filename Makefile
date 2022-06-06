# run commands via docker-compose


### ENV VARS ###

# defaults
# use old docker-compose which uses v1 protocol - needed for podman 3.4 to run `docker-compose build`
DOCKER_COMPOSE=docker-compose

# expose UID/GID as Makefile vars
GID := $(shell id -g)
UID := $(shell id -u)

# override with .env
ifneq (,$(wildcard ./.env))
	include .env
	export
endif


### DEFAULT RULE ###

.DEFAULT_GOAL := help
# list all make targets
help:
	@echo "Use one of these make targets:"
	@make -rpn | sed -n -e '/^$$/ { n ; /^[^ .#][^ ]*:/p ; }' | sed -e 's/:$$//' | egrep --color '^[^ ]*'


### COMMANDS ###

# docker-compose down
docker-compose-down:
	$(DOCKER_COMPOSE) down


### HELPER COMMANDS ###

# shell
shell:
	$(DOCKER_COMPOSE) run --rm debian-backport bash
