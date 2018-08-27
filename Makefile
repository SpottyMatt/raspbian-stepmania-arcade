.PHONY: all
all:
	$(MAKE) system-prep
	$(MAKE) stepmania-prep
	$(MAKE) stepmania-build
	$(MAKE) stepmania-install

.PHONY: system-prep
system-prep:
	sudo sed -i 's/#deb-src/deb-src/g' /etc/apt/sources.list
	sudo apt-get update
	sudo apt-get install -y \
		binutils-dev \
		build-essential \
		cmake \
		ffmpeg \
		libasound-dev \
		libbz2-dev \
		libc6-dev \
		libcairo2-dev \
		libgdk-pixbuf2.0-dev \
		libglew1.5-dev \
		libglu1-mesa-dev \
		libgtk2.0-dev \
		libjack0 \
		libjack-dev \
		libjpeg-dev \
		libmad0-dev \
		libogg-dev \
		libpango1.0-dev \
		libpng-dev \
		libpulse-dev \
		libudev-dev \
		libva-dev \
		libvorbis-dev \
		libxrandr-dev \
		libxtst-dev \
		mesa-common-dev \
		mesa-utils \
		unclutter \
		yasm \
		zlib1g-dev
	sudo apt-get autoremove -y
	sudo mkdir -p /usr/local/stepmania-5.2
	sudo chmod a+rw /usr/local/stepmania-5.2
	chmod a+x ./merge-config.sh
	sudo ./merge-config.sh ./performance-tune/raspi-3b-tune.config /boot/config.txt

.PHONY: stepmania-prep
.ONESHELL:
stepmania-prep:
	git submodule init
	git submodule update
	cd stepmania
	git submodule init
	git submodule update
	git fetch
	git merge origin/master
	git apply ../stepmania-build/raspi-3b-arm.patch && git commit --author="raspian-3b-stepmania-arcade <spottymatt@gmail.com>" -a -m "Patched to enable building on ARM processors with -DARM_CPU=1"
	cmake -G "Unix Makefiles" \
	        -DWITH_CRASH_HANDLER=0 \
	        -DWITH_SSE2=0 \
	        -DWITH_MINIMAID=0 \
	        -DWITH_FULL_RELEASE=1 \
		-DCMAKE_BUILD_TYPE=Release \
	        -DARM_CPU=1
	cmake .
	git reset --hard origin/master

.PHONY: stepmania-build
stepmania-build:
	$(MAKE) --dir stepmania

.PHONY: stepmania-install
stepmania-install:
	$(MAKE) --dir stepmania install
	mkdir -p "$(HOME)/stepmania-5.0/Save"
	touch "$(HOME)/.stepmania-5.0/Save/Preferences.ini"
	./merge-config.sh ./stepmania-install/Preferences.ini "$(HOME)/.stepmania-5.0/Save/Preferences.ini"
	cp -f ./stepmania-install/launch.sh "$(HOME)/.stepmania-5.0/"
	chmod a+x "$(HOME)/.stepmania-5.0/launch.sh"
	mkdir -p "$(HOME)/.config/autostart"
	cat stepmania-install/stepmania.desktop | RUNUSER=$(shell whoami) envsubst > "$(HOME)/.config/autostart/stepmania.desktop"

.PHONY: overclock-apply
overclock-apply:
	chmod a+x ./performance-tune/overclock-pi3.sh
	./performance-tune/overclock-pi3.sh
