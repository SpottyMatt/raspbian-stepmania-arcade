.PHONY: all
all:
	$(MAKE) system-prep
	$(MAKE) stepmania-build

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
		yasm \
		zlib1g-dev
	sudo apt-get autoremove -y

.PHONY: stepmania-build
.ONESHELL:
stepmania-build:
	git submodule init
	git submodule update
	cd stepmania
	git submodule init
	git submodule update
	git fetch
	git merge origin/master
	cmake -G "Unix Makefiles" \
	        -DWITH_CRASH_HANDLER=0 \
	        -DWITH_SSE2=0 \
	        -DWITH_MINIMAID=0 \
	        -DWITH_FULL_RELEASE=1 \
	        -DARM_CPU=1
	cmake .
