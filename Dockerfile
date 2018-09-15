ARG distro=stretch
FROM resin/rpi-raspbian:$distro

WORKDIR /work
COPY . /work/

RUN ls -hal

# install make
RUN apt-get update && apt-get install -y \
	build-essential \
	git

RUN git config --global user.name raspian-3b-stepmania-arcade && git config user.email "SpottyMatt@gmail.com"

# build stepmania
RUN make -j2 build-only

# install the built stepmania
RUN make --dir stepmania install


