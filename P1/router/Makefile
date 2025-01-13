# **************************************************************************** #
# *                              GENERAL INFO                                * #
# **************************************************************************** #

NAME=router
PREFIX=nplieger-ssar

# **************************************************************************** #
# *                                  RULES                                   * #
# **************************************************************************** #

all: build

build:
	@echo "Building docker image ${PREFIX}/${NAME}."
	@docker build -t ${PREFIX}/${NAME} .

clean:
	@echo "Removing docker image ${PREFIX}/${NAME}."
	@docker rmi ${PREFIX}/${NAME} || true

fclean: clean
	@echo "Pruning dangling docker system files."
	@docker system prune -f

re: fclean all

.PHONY: build clean fclean re
