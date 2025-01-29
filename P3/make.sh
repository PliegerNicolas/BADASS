#! /bin/sh

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"
CYAN="\033[36m"
NC="\033[0m"

if [ -z "$1" ]; then
	echo "${CYAN}[i] Running Makefiles with default rule: all.${NC}"
else
	echo "${CYAN}[i] Running makefiles with rule: $1.${NC}"
fi

DIRS_TO_MAKE="route-reflector leaf host"

for DIR in $DIRS_TO_MAKE; do
	if [ -f "${CURR_FILE_PATH}/${DIR}/Makefile" ]; then
		echo "${CYAN}Running Makefile in directory: ${DIR}.${NC}"
		make -C $DIR $1
	fi
done
