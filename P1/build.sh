# !/bin/sh

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"
DOCKER_IMAGE_NAME_PREFIX="nplieger-ssar"

DOCKER_IMAGE_NAME="host_nplieger_ssar"
echo "[i] Building ${DOCKER_IMAGE_NAME_PREFIX}/${DOCKER_IMAGE_NAME}"
docker build -t \
	${DOCKER_IMAGE_NAME_PREFIX}/${DOCKER_IMAGE_NAME} \
	${CURR_FILE_PATH}/host

DOCKER_IMAGE_NAME="router_nplieger_ssar"
echo "[i] Building ${DOCKER_IMAGE_NAME_PREFIX}/${DOCKER_IMAGE_NAME}"
docker build -t \
	${DOCKER_IMAGE_NAME_PREFIX}/${DOCKER_IMAGE_NAME} \
	${CURR_FILE_PATH}/router
