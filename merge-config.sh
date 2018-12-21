#!/usr/bin/env bash

# Usage:
#	merge-config.sh <source> <target>
#
# Given a config file full of key=value lines,
# read a source file and add or update lines in a
# target file so that the target file contains the source settings.
#
# This doesn't work for keys that are allowed to be duplicated, e.g. if the following is valid:
#
#	some_thing=value1
#	some_thing=value2
#	some_thing=value3
#
# then this script will probably BREAK the config file if used to set some_thing.


SOURCE_CONFIG=$1
TARGET_CONFIG=$2

if ! [ -e "${SOURCE_CONFIG}" ]; then
	echo "ERROR: [${SOURCE_CONFIG}] does not exist."
	exit 1
fi

if ! [ -e "${TARGET_CONFIG}" ]; then
	echo "WARNING: [${TARGET_CONFIG}] does not exist."
	mkdir -p $(dirname "${TARGET_CONFIG}")
	touch "${TARGET_CONFIG}"
fi

echo -e "Merging configuration:\n\tSource : ${SOURCE_CONFIG}\n\tTarget : ${TARGET_CONFIG}"

while read line; do
	if [ "x" = "x${line}" ]; then
		continue
	fi

	PAIR=$(echo "${line}" | awk '{print $1}' | tr -d '[:space:]' )
	KEY=$(echo "${PAIR}" | awk -F'=' '{print $1}' )
	VALUE=$(echo "${PAIR}" | awk -F'=' '{print $2}' )

	echo "${KEY}=${VALUE}"

	if grep --quiet --regexp="^${KEY} *=" "${TARGET_CONFIG}"; then

		OLDLINE=$(grep --regexp="^${KEY} *=" "${TARGET_CONFIG}" | head -n 1 )
		OLDPAIR=$(echo "${OLDLINE}" | awk '{print $1}' )
		OLDVALUE=$(echo "${OLDPAIR}" | awk -F'=' '{print $2}')

		if [ "${OLDVALUE}" != "${VALUE}" ]; then
			echo -e "\t~ Updated line in ${TARGET_CONFIG}:\n\t\tOld : ${KEY}=${OLDVALUE}\n\t\tNew : ${KEY}=${VALUE}"
			sed -i "s/${KEY} *=.*/${line}/" "${TARGET_CONFIG}"
		else
			echo -e "\to Already set!"
		fi

	else
		echo -e "\t+ Added line to ${TARGET_CONFIG}:\n\t\t${KEY}=${VALUE}"
		echo "${line}" | tee -a "${TARGET_CONFIG}" > /dev/null
	fi
done < "${SOURCE_CONFIG}"

