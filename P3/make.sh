#! /bin/sh

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"
CYAN="\033[36m"
NC="\033[0m"

if [ -z "$1" ]; then
	echo "${CYAN}[i] Running Makefiles with default rule: all.${NC}"
else
	echo "${CYAN}[i] Running makefiles with rule: $1.${NC}"
fi

if [ -f "${CURR_FILE_PATH}/RR/Makefile" ]; then
	echo "${CYAN}Running Makefile in directory: ${CURR_FILE_PATH}/RR.${NC}"
	make -C ${CURR_FILE_PATH}/RR $1
fi

for dir in ${CURR_FILE_PATH}/leafs/*/; do
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
