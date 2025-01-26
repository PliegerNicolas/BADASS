#! /bin/sh

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"
CYAN="\033[36m"
NC="\033[0m"

if [ -z "$1" ]; then
	echo "${CYAN}[i] Running Makefiles with default rule: all.${NC}"
else
	echo "${CYAN}[i] Running makefiles with rule: $1.${NC}"
fi

for dir in ${CURR_FILE_PATH}/routers/*/; do
	if [ -f "$dir/Makefile" ]; then
		echo "${CYAN}Running Makefile in directory: ${dir}.${NC}"
		make -C $dir $1
	fi
done

for dir in ${CURR_FILE_PATH}/hosts/*/; do
	if [ -f "$dir/Makefile" ]; then
		echo "${CYAN}Running Makefile in directory: ${dir}.${NC}"
		make -C $dir $1
	fi
done
