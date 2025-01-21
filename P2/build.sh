# !/bin/sh

CURR_FILE_PATH="$(dirname "$(realpath "$0")")"

for dir in ${CURR_FILE_PATH}/*/; do
	if [ -f "$dir/Makefile" ]; then
		echo "Running Makefile in directory: ${dir}"
		make -C $dir
	fi
done
