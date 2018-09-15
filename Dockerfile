ARG distro=stretch
FROM resin/rpi-raspbian:$distro

WORKDIR $(HOME)
COPY . $(HOME)/

RUN ls -hal $(HOME)

