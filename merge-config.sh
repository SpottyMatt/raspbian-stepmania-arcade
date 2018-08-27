#!/usr/bin/env bash

SOURCE_CONFIG=$1
TARGET_CONFIG=$2

if ! [ -e "${SOURCE_CONFIG}" ]; then
	echo "ERROR: [${SOURCE_CONFIG}] does not exist."
	exit 1
fi

if ! [ -e "${TARGET_CONFIG}" ]; then
	echo "ERROR: [${TARGET_CONFIG}] does not exist."
	exit 1
fi

while read line; do
	if [ "x" = "x${line}" ]; then
		continue
	fi

	PAIR=$(echo "${line}" | awk '{print $1}' | tr -d '[:space:]' )
	KEY=$(echo "${PAIR}" | awk -F'=' '{print $1}' )
	VALUE=$(echo "${PAIR}" | awk -F'=' '{print $2}' )

	echo "Merging [${KEY}=${VALUE}] into ${TARGET_CONFIG}..."

	if grep --quiet --regexp="^${KEY} *=" "${TARGET_CONFIG}"; then

		OLDLINE=$(grep --regexp="^${KEY} *=" "${TARGET_CONFIG}" | head -n 1 )
		OLDPAIR=$(echo "${OLDLINE}" | awk '{print $1}' )
		OLDVALUE=$(echo "${OLDPAIR}" | awk -F'=' '{print $2}')

		if [ "${OLDVALUE}" != "${VALUE}" ]; then
			echo -e "\t~ Updated line in ${TARGET_CONFIG}:\n\t\tOld : ${KEY}=${OLDVALUE}\n\t\tNew : ${KEY}=${VALUE}"
			sudo sed -i "s/${KEY} *=.*/${line}/" "${TARGET_CONFIG}"
		else
			echo -e "\to Already set!"
		fi

	else
		echo -e "\t+ Added line to ${TARGET_CONFIG}:\n\t\t${KEY}=${VALUE}"
		echo "${line}" | sudo tee -a "${TARGET_CONFIG}" > /dev/null
	fi
done < "${SOURCE_CONFIG}"

