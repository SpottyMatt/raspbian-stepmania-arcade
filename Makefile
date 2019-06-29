SM_CONFIG_DIR=$(HOME)/.stepmania-5.1
SM_INSTALL_DIR=/usr/games/stepmania

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
	[ -e "$(HOME)/.asoundrc" ] && rm "$(HOME)/.asoundrc"

.PHONY: stepmania-install
stepmania-install:
	curl https://github.com/SpottyMatt/stepmania-raspi-deb/releases/download/v5.1.0-b2/stepmania-5.1.0-b2-20180723-armhf.deb > /tmp/stepmania-5.1.0-b2-20180723-armhf.deb
	sudo apt-get install -f /tmp/stepmania-5.1.0-b2-20180723-armhf.deb

.PHONY: arcade-setup
arcade-setup:
	mkdir -p "$(SM_CONFIG_DIR)"
	cp -rfv ./arcade-setup/user-settings/. "$(SM_CONFIG_DIR)/"
	chmod a+x "$(SM_CONFIG_DIR)/Save/merge-ini.sh"
	chmod a+x "$(SM_CONFIG_DIR)/launch.sh"
	cp -rfv ./arcade-setup/global-settings/. "$(SM_INSTALL_DIR)/"
	mkdir -p "$(HOME)/.config/autostart"
	cat arcade-setup/stepmania.desktop | RUNUSER=$(shell whoami) envsubst > "$(HOME)/.config/autostart/stepmania.desktop"
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
