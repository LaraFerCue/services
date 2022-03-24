# Orchestrating file for the services offered

SUDO=
ifneq (${USER}, root)
SUDO=sudo
endif

TRAEFIK_DATA=	/srv/traefik
WORKDIR=	${CURDIR}/work

${WORKDIR}:
	mkdir -p ${@}

${TRAEFIK_DATA} ${TRAEFIK_DATA}/providers:
	${SUDO} mkdir -p ${@}

${TRAEFIK_DATA}/traefik.yml: ${TRAEFIK_DATA}
	${SUDO} install -o root -g root ${CURDIR}/files/traefik.yml ${TRAEFIK_DATA}/traefik.yml

${TRAEFIK_DATA}/acme.json: ${TRAEFIK_DATA}
	${SUDO} touch ${@}
	${SUDO} chmod 0600 ${@}

${TRAEFIK_DATA}/providers/api.yml: ${WORKDIR}/api.yml ${TRAEFIK_DATA}/providers
	${SUDO} install -o root -g root ${WORKDIR}/api.yml ${@}

${WORKDIR}/config.user_pass: ${WORKDIR}
	@echo " Please type the password for user ${USER} ..."
	@htpasswd -n ${USER} > ${@}

${WORKDIR}/api.yml: ${WORKDIR} ${WORKDIR}/config.user_pass
		sed -e 's|%%USER_PASSWORD%%|$(strip $(shell cat ${WORKDIR}/config.user_pass))|' \
			${CURDIR}/files/providers/api.yml > ${@}

.PHONY: traefik/up traefik/down
traefik/up: ${TRAEFIK_DATA}/traefik.yml ${TRAEFIK_DATA}/acme.json ${TRAEFIK_DATA}/providers/api.yml
traefik/up portainer/up:
	${SUDO} docker-compose -f $(subst /up,,${@}).yml up -d

traefik/down portainer/down:
	${SUDO} docker-compose -f $(subst /down,,${@}).yml down
