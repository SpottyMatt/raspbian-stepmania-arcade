#!/usr/bin/env bash

# Asks you which Raspberry Pi you have,
# and applies probably-safe overclock settings.
#
# Warns you repeatedly that you WILL void your warranty and
# MAY break your Pi.

function confirm {

	while true; do
		read -r -p "$1 [Y/n] " INPUT

		case "${INPUT}" in
			[yY])
				return 0
				;;
			[nN])
				return 1
				;;
			*)
				echo "Not sure what you meant. Please answer with 'Y' or 'n'."
				;;
		esac
	done
}

cat << EOF
###########################################################
#                                                         #
#   OVERCLOCK WARNING                                     #
#                                                         #
#   1. Overclocking can break your Pi.                    #
#   2. This overclock WILL void your warranty.            #
#   3. Selecting the WRONG overclock can break your pi.   #
#                                                         #
#   Are you sure you want to continue?                    #
#                                                         #
###########################################################

EOF

if ! confirm "Continue with overclocking?"; then
	exit 0
fi

USER_WHICHPI=$1

if [ -z $USER_WHICHPI ] ; then
	while true; do
		echo -e "Which Raspbery Pi is this running on?\n\t0: 3B\n\t1: 3B+\n\t2: 4B"

		read -p ": " USER_WHICHPI

		case "${USER_WHICHPI}" in
			0)
				WHICHPI="3b"
				break
			;;
			1)
				WHICHPI="3b+"
				break
			;;
			2)
				WHICHPI="4b"
				break
			;;
		esac
	done
else
	WHICHPI=${USER_WHICHPI}
fi

cat << EOF
###########################################################
#                                                         #
#   OVERCLOCK WARNING                                     #
#                                                         #
#   1. This overclock WILL void your warranty.            #
#   2. Selecting the WRONG overclock can break your pi.   #
#                                                         #
###########################################################

EOF

if ! confirm "Is this really a Raspberry Pi ${WHICHPI}?"; then
	exit 0
fi


sudo ./merge-config.sh ./performance-tune/raspi-${WHICHPI}-oc.config /boot/config.txt

