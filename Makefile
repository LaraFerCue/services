# Orchestrating file for the services offered

SUDO=
ifneq (${USER}, root)
SUDO=sudo
endif

DOMAIN=		barbunicorn.gay

WORKDIR=	${CURDIR}/work

export WORKDIR

CONTAINERS=	traefik portainer mailserver
UP_TARGETS=	$(foreach container,${CONTAINERS},${container}/up)
DOWN_TARGETS=	$(foreach container,${CONTAINERS},${container}/down)

.PHONY: traefik/up traefik/down
${UP_TARGETS}:
	make -C $(dir ${@}) config
	cd $(dir ${@}) && ${SUDO} docker-compose up -d

${DOWN_TARGETS}:
	cd $(dir ${@}) && ${SUDO} docker-compose down
