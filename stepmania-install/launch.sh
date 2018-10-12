#!/usr/bin/env bash

STEPMANIA_SETTINGS_DIR=~/.stepmania-5.0

if [ -d ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps ]; then

	STARTUP_LOGS="/tmp/sm-launch.log"
	STARTED_UP_PATTERN="Display: "
	CONTROLLER_PATTERN="Theme: "
	GENERATED_KEYMAP=/tmp/sm-keymap.ini
	STARTUP_MAX=30
	KILL_MAX=30

	/usr/local/stepmania-5.2/stepmania --verbose --debug > ${STARTUP_LOGS} 2>&1 &
	SM_DUMMY_PID=$!

	STARTUP_WAIT=0
	KILL_WAIT=0
	while sleep 1; do
		STARTUP_WAIT=$((STARTUP_WAIT + 1))
		if [ $STARTUP_WAIT -gt $STARTUP_MAX ]; then
			echo "WARNING: StepMania took too long starting up. Will not be able to map controller input."
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
					echo "WARNING: StepMania took too long shutting down. Will not be able to map controller input."
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

	sleep 2


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
				echo "       Yes: at Joy${JOY_INDEX}. Will be P${PLAYER_INDEX}."
				cat ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps/${keymap} | sed "s/1_/${PLAYER_INDEX}_/" | sed "s/Joy10/Joy${JOY_INDEX}/" >> ${GENERATED_KEYMAP}
				PLAYER_INDEX=$((PLAYER_INDEX + 1))
			fi

		JOY_INDEX=$((JOY_INDEX + 1))

		done # with SM devices
	done # with keymaps

	if [ $PLAYER_INDEX -gt 1 ]; then
		# at least one mapping was added
		cp -f ${GENERATED_KEYMAP} ${STEPMANIA_SETTINGS_DIR}/Save/Keymaps.ini
	fi
else
	echo "No named key mappings found in [${STEPMANIA_SETTINGS_DIR}/Save/Keymaps/]."
fi

sleep 1

# hide the cursor
unclutter -display :0 -noevents -grab &

# start StepMania
/usr/local/stepmania-5.2/stepmania

# kill the thing that's hiding the cursor
pkill unclutter

