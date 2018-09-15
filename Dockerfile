ARG distro=stretch
FROM resin/rpi-raspbian:$distro

WORKDIR /work
COPY . /work/

# install make
RUN apt-get update && apt-get install -y \
	git \
	make

RUN git config --global user.name raspian-3b-stepmania-arcade && git config user.email "SpottyMatt@gmail.com"

# build stepmania
RUN make -j4 build-only

# install the built stepmania
RUN make --dir stepmania install


