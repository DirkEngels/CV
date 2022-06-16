#.RECIPEPREFIX +=
.DEFAULT_GOAL := help
.PHONY: $(filter-out install,$(MAKECMDGOALS))

all: start

VOLUMES	  = -v /var/run/docker.sock=/var/run/docker.sock

APP_NAME = dirkengels-cv
APP_PORT = 8081
DOCKER_SWARM_ENABLED = $(shell docker info --format '{{.Swarm.ControlAvailable}}' )

#include .env


### CLI COLORS
COLOR_RESET=\e[0m
COLOR_RED=\e[31m
COLOR_GREEN=\e[32m
COLOR_ORANGE=\e[33m
COLOR_BLUE=\e[34m

# Detect current status (and uptime)
UPTIME := $(shell docker compose --env-file .env ps | grep $(APP_NAME) | awk -F' {2,}' '{ print $$5 }' | wc -l )



###
# Help: Show a basic help message and list all public available commands.
###
help:																		   # Show Help
	@echo "$(COLOR_ORANGE)Usage:$(COLOR_RESET)\n  make [target] [arg="val"...]"
	@echo "";
	@echo "$(COLOR_ORANGE)Targets:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)start$(COLOR_RESET)		 Start docker container"
	@echo "  $(COLOR_GREEN)stop$(COLOR_RESET)		 Stop docker container"
	@echo "  $(COLOR_GREEN)status$(COLOR_RESET)         View the docker container status"
	@echo "  $(COLOR_GREEN)deploy$(COLOR_RESET)	 Deploy (docker swarm cluster)"
	@echo "  $(COLOR_GREEN)log$(COLOR_RESET)		 Tail the docker container logs"
	@echo "  $(COLOR_GREEN)clean$(COLOR_RESET)		 Remove resources from the build process"
	@echo "";
	@echo "$(COLOR_ORANGE)Variables:$(COLOR_RESET)\n"
	@echo "  $(COLOR_GREEN)APP_NAME$(COLOR_RESET)		 Name of the stack (default: dirkengels-cv)"
	@echo "  $(COLOR_GREEN)APP_PORT$(COLOR_RESET)		 Port to use (default: 8081)"
	@echo "";


###
# Clean: Remove any resources created during the build/start process.
###
clean: stop											## Remove resources from the build process
	@echo "  Status:\t\t$(COLOR_BLUE)CLEANING$(COLOR_RESET)";
	-@docker rmi $(APP_NAME)


###
# Start: Starts the docker container image
#"GF_SECURITY_ADMIN_PASSWORD=${SECURITY_ADMIN_PASSWORD}" \
###
start:												## Starts the docker container image
ifeq ($(UPTIME),0)
	@echo "  Status:\t\t$(COLOR_BLUE)STARTING$(COLOR_RESET)";
ifeq ($(DOCKER_SWARM_ENABLED),true)
	bash -c "set -a && source .env && docker stack deploy -c docker-compose.yml $(APP_NAME)"
else
	docker compose -f docker-compose.yml --env-file=.env up -d --remove-orphans
endif
	@echo "  Status:\t\t$(COLOR_GREEN)STARTED$(COLOR_RESET)";
endif
ifneq ($(UPTIME),0)
	@echo "  Status:\t\t$(COLOR_GREEN)RUNNING$(COLOR_RESET) (${UPTIME})"
endif
	@echo "";


###
# Stop: Stops the docker container image
###
stop:												   ## Stops the docker container image
ifneq ($(UPTIME),0)
ifeq ($(DOCKER_SWARM_ENABLED),true)
    bash -c "set -a && source .env && docker stack rm $(APP_NAME)"
else
	docker compose -f docker-compose.yml --env-file=.env down
endif
endif
	@echo "  Status:\t\t$(COLOR_RED)STOPPED$(COLOR_RESET)"


###
# Status: Show the status if the container is running
###
status:												   ## Stops the docker container image
#	 @echo "$(COLOR_ORANGE)$(DOCKER_OWNER)-$(APP_NAME)$(COLOR_RESET)"
	@echo "APP: $(DOCKER_OWNER)-$(APP_NAME)"
ifeq ($(UPTIME),0)
	@echo "  Status:\t\t$(COLOR_RED)STOPPED$(COLOR_RESET)"
endif
ifneq ($(UPTIME),0)
	@echo "  Status:\t\t$(COLOR_GREEN)RUNNING$(COLOR_RESET) (${UPTIME})"
endif
	@echo "";
	

###
# Remove: Removed the docker container
###
remove:												 ## Removes the docker container
	docker rm $(DOCKER_OWNER)-$(APP_NAME)



###
# Log: Show the docker container log
###
log:													## Tail the docker container logs
ifneq ($(UPTIME),0)
	docker compose --env-file .env logs -f -t
endif
ifeq ($(UPTIME),0)
	@echo "  Status:\t\t$(COLOR_RED)STOPPED$(COLOR_RESET)"
endif


###
# Deploy: Deploy the image to a docker swarm cluster (on the current host).
###
deploy:												   ## Deploys to a docker swarm cluster 
	@echo "APP: $(DOCKER_OWNER)-$(APP_NAME)"
	@make stop
	@make start
