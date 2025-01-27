# **************************************************************************** #
# *                              GENERAL INFO                                * #
# **************************************************************************** #

NAME			=	leaf2
PREFIX			=	nplieger-ssar
CAPS			=	--cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_ADMIN

FOUND_IMAGE		:=	$(shell ! docker image inspect ${PREFIX}/${NAME} > /dev/null 2>&1; echo $$?)
FOUND_CONTAINERS	:=	$(shell docker ps -a --filter "name=${PREFIX}-${HOST}" | wc -l | awk '{print $$1 - 1}')

#* *************************************************************************** *#
#* *                             RULE FILTERS                                * *#
#* *************************************************************************** *#

ifeq (unicast, $(filter unicast,$(MAKECMDGOALS)))
	ENTRYPOINT_ARGS	:=	unicast
endif

ifeq (multicast, $(filter multicast,$(MAKECMDGOALS)))
	ENTRYPOINT_ARGS	:=	multicast
endif

ENTRYPOINT_ARGS		?=	unicast

# **************************************************************************** #
# *                                  RULES                                   * #
# **************************************************************************** #

all: build

build:
	@if [ "${FOUND_IMAGE}" -eq 0 ]; then \
		echo "Building docker image ${PREFIX}/${NAME}."; \
		docker build --build-arg ENTRYPOINT_ARGS="${ENTRYPOINT_ARGS}" -t ${PREFIX}/${NAME} .; \
	else \
		echo "Docker image ${PREFIX}/${NAME} already exists."; \
	fi

run: build
	@if [ "${FOUND_CONTAINERS}" -eq 0 ]; then \
		docker run -d ${CAPS} --name ${PREFIX}-${NAME} ${PREFIX}/${NAME} > /dev/null 2>&1; \
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
