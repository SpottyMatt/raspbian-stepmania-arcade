DISTRO=$(shell dpkg --status tzdata|grep Provides|cut -f2 -d'-')

SM_CONFIG_DIR=$(HOME)/.stepmania-5.1
SM_INSTALL_DIR=$(shell dirname $$(readlink -f $$(which stepmania)) 2>/dev/null)

SM_BINARY_VERSION=5.1.0-b2
SM_BINARY_URL=https://github.com/SpottyMatt/raspbian-stepmania-deb/releases/download/v$(SM_BINARY_VERSION)/stepmania-$(SM_BINARY_VERSION)-armhf-$(DISTRO).deb

.PHONY: all
all:
	$(MAKE) system-prep
	$(MAKE) stepmania-install
	$(MAKE) arcade-setup

.PHONY: system-prep
system-prep:
	chmod a+x ./merge-config.sh
	sudo ./merge-config.sh ./performance-tune/raspi-3b-tune.config /boot/config.txt
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
	sudo apt-get install -f /tmp/stepmania.deb
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
	chmod a+x ./performance-tune/overclock-pi3.sh
	./performance-tune/overclock-pi3.sh

.PHONY: no-turbo
no-turbo:
	sudo ./merge-config.sh ./performance-tune/no-turbo.config /boot/config.txt
