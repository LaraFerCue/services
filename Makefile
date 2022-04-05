# Orchestrating file for the services offered

SUDO=
ifneq (${USER}, root)
SUDO=sudo
endif

WORKDIR=	${CURDIR}/work

export WORKDIR SUDO

%/config:
	make -C $(dir ${@}) config

%/up:
	make -C $(dir ${@}) config
	cd $(dir ${@}) && ${SUDO} docker-compose up -d

%/down:
	cd $(dir ${@}) && ${SUDO} docker-compose down
