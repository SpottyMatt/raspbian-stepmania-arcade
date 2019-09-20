DISTRO=$(shell dpkg --status tzdata|grep Provides|cut -f2 -d'-')

RPI_MODEL = $(shell ./rpi-hw-info/rpi-hw-info.py 2>/dev/null | awk -F ':' '{print $$1}' | tr '[:upper:]' '[:lower:]' )
SM_RPI_MODEL=$(RPI_MODEL)

ifeq ($(RPI_MODEL),3b+)
# RPI 3B and 3B+ are the same hardware architecture and targets
# So we don't need to generate separate packages for them.
# Prefer the base model "3B" for labelling when we're on a 3B+
SM_RPI_MODEL=3b
endif

SM_CONFIG_DIR=$(HOME)/.stepmania-5.1
SM_INSTALL_DIR=$(shell dirname $$(readlink -f $$(which stepmania)) 2>/dev/null)

SM_BINARY_VERSION=5.1.0-b2
SM_BINARY_URL=https://github.com/SpottyMatt/raspbian-stepmania-deb/releases/download/v$(SM_BINARY_VERSION)/stepmania-$(SM_RPI_MODEL)_$(SM_BINARY_VERSION)_$(DISTRO).deb

.PHONY: all

ifeq ($(wildcard ./rpi-hw-info/rpi-hw-info.py),)

all: submodules
	$(MAKE) all

submodules:
	git submodule init rpi-hw-info
	git submodule update rpi-hw-info
	@ if ! [ -e ./rpi-hw-info/rpi-hw-info.py ]; then echo "Couldn't retrieve the RPi HW Info Detector's git submodule. Figure out why or run 'make RPI_MODEL=<your_model>'"; exit 1; fi

%: submodules
	$(MAKE) $@

else

all:
	$(MAKE) system-prep
	$(MAKE) stepmania-install
	$(MAKE) arcade-setup

.PHONY: system-prep
system-prep:
	chmod a+x ./merge-config.sh
	sudo ./merge-config.sh ./performance-tune/raspi-$(RPI_MODEL)-tune.config /boot/config.txt
	sudo cp -fv ./system-prep/usb-audio-by-default.conf /etc/modprobe.d/.
	[ -e "$(HOME)/.asoundrc" ] && rm "$(HOME)/.asoundrc" || true
	sudo apt-get update
	sudo apt-get install -y \
		unclutter
	sudo apt-get autoremove -y

.PHONY: stepmania-install
stepmania-install:
ifeq ($(SM_INSTALL_DIR),)
	curl --location --fail "$(SM_BINARY_URL)" > /tmp/stepmania.deb
	sudo dpkg --install /tmp/stepmania.deb
	sudo apt-get install --fix-broken -y
else
	echo "stepmania is already on the PATH at $(SM_INSTALL_DIR)"
endif

.PHONY: arcade-setup
arcade-setup:
	mkdir -p "$(SM_CONFIG_DIR)"
	cp -rfv ./arcade-setup/user-settings/. "$(SM_CONFIG_DIR)/"
	sed -i 's>SM_CONFIG_DIR=.*>SM_CONFIG_DIR=$(SM_CONFIG_DIR)>g' "$(SM_CONFIG_DIR)/launch.sh"
	chmod a+x "$(SM_CONFIG_DIR)/Save/merge-ini.sh"
	"$(SM_CONFIG_DIR)"/Save/merge-ini.sh "$(SM_CONFIG_DIR)"/Save/Default-Preferences.ini "$(SM_CONFIG_DIR)"/Save/Preferences.ini
	chmod a+x "$(SM_CONFIG_DIR)/launch.sh"
	sudo cp -rfv ./arcade-setup/global-settings/. "$(SM_INSTALL_DIR)/"
	mkdir -p "$(HOME)/.config/autostart"
	cat arcade-setup/stepmania.desktop | SM_CONFIG_DIR="$(SM_CONFIG_DIR)" envsubst > "$(HOME)/.config/autostart/stepmania.desktop"
	mkdir -p "$(HOME)/Pictures/"
	cp -rfv ./arcade-setup/stepmania-wallpaper/ "$(HOME)"/Pictures/.
	DISPLAY=:0 pcmanfm --set-wallpaper="$(HOME)/Pictures/stepmania-wallpaper/yellow_5.1_16:9.png"

.PHONY: overclock-apply
overclock-apply:
	chmod a+x ./performance-tune/overclock-pi.sh
	./performance-tune/overclock-pi.sh $(RPI_MODEL)

.PHONY: no-turbo
no-turbo:
	sudo ./merge-config.sh ./performance-tune/no-turbo.config /boot/config.txt
endif
