# **************************************************************************** #
# *                              GENERAL INFO                                * #
# **************************************************************************** #

NAME=p3-host1
PREFIX=nplieger-ssar

FOUND_IMAGE:=$(shell ! docker image inspect ${PREFIX}/${NAME} > /dev/null 2>&1; echo $$?)
FOUND_CONTAINERS:=$(shell docker ps -a --filter "name=${PREFIX}-${HOST}" | wc -l | awk '{print $$1 - 1}')

# **************************************************************************** #
# *                                  RULES                                   * #
# **************************************************************************** #

all: build

build:
	@if [ "${FOUND_IMAGE}" -eq 0 ]; then \
		echo "Building docker image ${PREFIX}/${NAME}."; \
		docker build -t ${PREFIX}/${NAME} .; \
	else \
		echo "Docker image ${PREFIX}/${NAME} already exists."; \
	fi

run: build
	@if [ "${FOUND_CONTAINERS}" -eq 0 ]; then \
		docker run -d --restart always --name ${PREFIX}-${NAME} ${PREFIX}/${NAME} > /dev/null 2>&1; \
	else \
		echo "Docker container ${PREFIX}-${NAME} already exists. Is it stopped ?"; \
	fi

clean:
	@echo "Stopping docker container ${PREFIX}/${NAME}."
	@docker stop ${PREFIX}-${NAME} || true
	@docker rm ${PREFIX}-${NAME} || true
	@echo "Removing docker image ${PREFIX}/${NAME}."
	@docker rmi ${PREFIX}/${NAME} || true

fclean: clean
	@echo "Pruning dangling docker system files."
	@docker system prune -f

re: fclean all

unicast: all

multicast: all

.PHONY: run build clean fclean re unicast multicast
