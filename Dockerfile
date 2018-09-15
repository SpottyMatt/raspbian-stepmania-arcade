ARG distro=stretch
FROM resin/rpi-raspbian:$distro

WORKDIR /work
COPY . /work/

RUN ls -hal

# install make
RUN apt-get update && apt-get install -y \
	build-essential \
	git

# build stepmania
RUN make build-only

# install the built stepmania
RUN make --dir stepmania install


