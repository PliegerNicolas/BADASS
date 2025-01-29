# **************************************************************************** #
# *                              GENERAL INFO                                * #
# **************************************************************************** #

NAME			=	p1-host
PREFIX			=	nplieger-ssar

FOUND_IMAGE		:=	$(shell ! docker image inspect ${PREFIX}/${NAME} > /dev/null 2>&1; echo $$?)
FOUND_CONTAINERS	:=	$(shell docker ps -a --filter "name=${PREFIX}-${HOST}" | wc -l | awk '{print $$1 - 1}')

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

clean:
	@echo "Removing docker image ${PREFIX}/${NAME}."
	@docker rmi ${PREFIX}/${NAME} || true

fclean: clean
	@echo "Pruning dangling docker system files."
	@docker system prune -f

re: fclean all

.PHONY: build clean fclean re
