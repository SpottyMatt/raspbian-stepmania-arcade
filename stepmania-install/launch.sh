#!/usr/bin/env bash

STEPMANIA_SETTINGS_DIR=~/.stepmania-5.1

####################
# Default Preferences:
# If there aren't user prefs (first-time startup),
# do a fake startup & then overwrite generated preferences
####################

SHOULD_APPLY_DEFAULTS="false"

if ! [ -e "${STEPMANIA_SETTINGS_DIR}/Save/Preferences.ini" ]; then
	SHOULD_APPLY_DEFAULTS="true"
	echo "First-ever launch; should apply defaults if present."
fi

####################
# If there are named keymaps,
# try to map controllers properly & predictably
####################

SHOULD_LOAD_KEYMAPS="false"

if [ -d "${STEPMANIA_SETTINGS_DIR}/Save/Keymaps" ]; then
	SHOULD_LOAD_KEYMAPS="true"
else
	echo "No named key mappings found in [${STEPMANIA_SETTINGS_DIR}/Save/Keymaps/]."
fi


if [ "${SHOULD_LOAD_KEYMAPS}" == "true" ] || [ "${SHOULD_APPLY_DEFAULTS}" == "true" ]; then

	STARTUP_LOGS="/tmp/sm-launch.log"
	STARTED_UP_PATTERN="Display: "
	CONTROLLER_PATTERN="Theme: "
	GENERATED_KEYMAP=/tmp/sm-keymap.ini
	STARTUP_MAX=30
	KILL_MAX=30

	# "fake" launch to read SM logs to find out the actual ordering of controllers
	/usr/local/stepmania-5.1/stepmania --verbose --debug > ${STARTUP_LOGS} 2>&1 &
	SM_DUMMY_PID=$!

	STARTUP_WAIT=0
	KILL_WAIT=0
	while sleep 1; do
		STARTUP_WAIT=$((STARTUP_WAIT + 1))
		if [ $STARTUP_WAIT -gt $STARTUP_MAX ]; then
			echo "WARNING: StepMania took too long starting up."
			kill -9 ${SM_DUMMY_PID}
			sleep 5
			break
		fi
		if grep -q "${STARTED_UP_PATTERN}" "${STARTUP_LOGS}"; then
			kill ${SM_DUMMY_PID}
			cat <<-'EOF'
 _____ _            ___  ___            _       
/  ___| |           |  \/  |           (_)      
\ `--.| |_ ___ _ __ | .  . | __ _ _ __  _  __ _ 
 `--. \ __/ _ \ '_ \| |\/| |/ _` | '_ \| |/ _` |
/\__/ / ||  __/ |_) | |  | | (_| | | | | | (_| |
\____/ \__\___| .__/\_|  |_/\__,_|_| |_|_|\__,_|
              | |                               
              |_|                               
 _                                              
(_)                                             
 _ ___                                          
| / __|                                         
| \__ \                                         
|_|___/                                         
 _____ _             _   _                      
/  ___| |           | | (_)                     
\ `--.| |_ __ _ _ __| |_ _ _ __   __ _          
 `--. \ __/ _` | '__| __| | '_ \ / _` |         
/\__/ / || (_| | |  | |_| | | | | (_| |_ _ _    
\____/ \__\__,_|_|   \__|_|_| |_|\__, (_|_|_)   
                                  __/ |         
                                 |___/          
EOF

			while sleep 1; do
				KILL_WAIT=$((KILL_WAIT + 1))
				if [ $KILL_WAIT -gt $KILL_MAX ]; then
					echo "WARNING: StepMania took too long shutting down."
					kill -9 ${SM_DUMMY_PID}
					sleep 5
					break 2
				fi

				if grep -q "${CONTROLLER_PATTERN}" "${STARTUP_LOGS}"; then
					break 2
				fi
			done # waiting for input devices to be printed
		fi
	done # with fake startup to get input device order

fi

sleep 2

# Load Keymaps if necessary

if [ "${SHOULD_LOAD_KEYMAPS}" == "true" ]; then

	rm -f ${GENERATED_KEYMAP}
	echo "[dance]" > ${GENERATED_KEYMAP}

	PLAYER_INDEX=1

	for keymap in $(find ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps -type f -exec basename {} \; | sort ); do

		KEYMAP_NAME=${keymap##*-}
		KEYMAP_NAME=${KEYMAP_NAME%%.ini}
		echo -e "\n==========\n${KEYMAP_NAME} connected?"

		JOY_INDEX=10
		for device in $(awk -F'[ :]' '/Input device: /{print $4}' ${STARTUP_LOGS}); do

			DEVICE_SERIAL=$(udevadm info ${device} | awk -F'=' '/ID_SERIAL=(.*)/{print $2}')

			if [ "${KEYMAP_NAME}" == "${DEVICE_SERIAL}" ]; then

				printf "  Yes: at Joy${JOY_INDEX}. "

				if [ $PLAYER_INDEX -le 2 ]; then
					# It is one of the two primary controllers.

					cat ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps/${keymap} | sed "s/1_/${PLAYER_INDEX}_/" | sed "s/Joy10/Joy${JOY_INDEX}/" >> ${GENERATED_KEYMAP}
					echo "Will be P${PLAYER_INDEX}."
				elif [ $PLAYER_INDEX -le 4 ]; then
					# It's controller 3 or 4; will be a secondary controller.

					SECONDARY_INDEX=$((PLAYER_INDEX - 2))

					while read -r named_map_line; do

						if [[ -z "${named_map_line// }" ]]; then
							# skip blank lines
							continue
						fi

						# do we need to add a line for the secondary mapping (e.g. if primary has no entry)
						# or do we need to update a line for the secondary mapping (if primary DOES)?

						# e.g. 1_Start=Joy10_B18 -> 2_Start=Joy10_B18
						PLAYER_MAPPED_LINE=$(echo "${named_map_line}" | sed "s/1_/${SECONDARY_INDEX}_/")

						# eg 2_Start
						PLAYER_MAPPED_LINE_PATTERN=${PLAYER_MAPPED_LINE%=*}

						EXISTING_MAPPING=$(grep "${PLAYER_MAPPED_LINE_PATTERN}" "${GENERATED_KEYMAP}")
						MAPPING_EXISTS=$?
						if [ $MAPPING_EXISTS == 0 ]; then
							# there is a primary mapping for this controller.
							# need to update the line, e.g.
							# 2_Start=Joy11_B21 -> 2_Start=Joy11_B21:Joy14_B3

							# drop existing secondary mapping, if exists

							# from generated keymap:
							# 2_Start=Joy10_B18:KeyA -> 2_Start=Joy10_B18
							PRIMARY_MAPPING=${EXISTING_MAPPING%:*}

							# from named keymap:
							# 1_Start=Joy10_B3 -> Joy10_B3
							SECONDARY_MAPPING=${named_map_line#*=}
							# controller is already secondary; only take its primary mapping.
							SECONDARY_MAPPING=${SECONDARY_MAPPING%:*}
							# Joy10_B3 -> Joy14_B3
							SECONDARY_MAPPING=$(echo "${SECONDARY_MAPPING}" | sed "s/Joy10/Joy${JOY_INDEX}/")

							FULL_MAPPING=${PRIMARY_MAPPING}:${SECONDARY_MAPPING}
							sed -i "s/${EXISTING_MAPPING}/${FULL_MAPPING}/" "${GENERATED_KEYMAP}"
						else
							# there is no primary mapping for this key.
							# need to add a line.
							# 2_Start=:Joy14_B3
							echo "${PLAYER_MAPPED_LINE}" | sed "s/1_/${SECONDARY_INDEX}_/" | sed "s/=Joy10/=:Joy${JOY_INDEX}/" >> ${GENERATED_KEYMAP}
						fi
					done < "${STEPMANIA_SETTINGS_DIR}/Save/Keymaps/${keymap}"

					echo "Will be P${SECONDARY_INDEX} secondary."
				else
					# It's controller 5 or more.
					# Can't map that automatically.

					echo "But 4 controllers were already mapped so it will be ignored."
				fi
				PLAYER_INDEX=$((PLAYER_INDEX + 1))
				break
			fi

			JOY_INDEX=$((JOY_INDEX + 1))

		done # with SM devices
	done # with keymaps

	if [ $PLAYER_INDEX -gt 1 ]; then
		# at least one mapping was added
		cp -f ${GENERATED_KEYMAP} ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps.ini
	fi
fi

sleep 1

####################
# Apply Defaults
####################

if [ "${SHOULD_APPLY_DEFAULTS}" == "true" ]; then
	cp ${STEPMANIA_SETTINGS_DIR}/Save/Preferences.ini ${STEPMANIA_SETTINGS_DIR}/Save/Preferences.ini.orig
	${STEPMANIA_SETTINGS_DIR}/Save/merge-ini.sh ${STEPMANIA_SETTINGS_DIR}/Save/Default-Preferences.ini ${STEPMANIA_SETTINGS_DIR}/Save/Preferences.ini Options
fi

####################
# Launch StepMania
####################

# hide the cursor
unclutter -display :0 -noevents -grab &

# start StepMania
/usr/local/stepmania-5.1/stepmania

# kill the thing that's hiding the cursor
pkill unclutter
