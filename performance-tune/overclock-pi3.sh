#!/usr/bin/env bash

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
##########################################################
#                                                        #
#   OVERCLOCK WARNING                                    #
#                                                        #
#   1. Overclocking can break your Pi                    #
#   2. Selecting the WRONG overclock can break your pi   #
#                                                        #
#   Are you sure you want to continue?                   #
#                                                        #
##########################################################

EOF

if ! confirm "Continue with overclocking?"; then
	exit 0
fi

while true; do
	echo -e "Which Raspbery Pi is this running on?\n\t0: 3B\n\t1: 3B+"

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
	esac
done

cat << EOF
##########################################################
#                                                        #
#   OVERCLOCK WARNING                                    #
#                                                        #
#   Selecting the WRONG overclock can break your pi      #
#                                                        #
##########################################################

EOF

if ! confirm "Is this really a Raspberry Pi ${WHICHPI}?"; then
	exit 0
fi


./merge-config.sh ./raspi-${WHICHPI}-oc.config

