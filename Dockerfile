ARG distro=stretch
FROM resin/rpi-raspbian:$distro

WORKDIR ${HOME}
COPY . ${HOME}/

RUN ls -hal ${HOME}

# build stepmania
RUN make build-only

# install the built stepmania
RUN make --dir stepmania install


