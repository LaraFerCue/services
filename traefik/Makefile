
TRAEFIK_DATA=	/srv/traefik

${WORKDIR}:
	mkdir -p ${@}

${TRAEFIK_DATA} ${TRAEFIK_DATA}/providers ${MAILSERVER_DATA}/config:
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

config: ${TRAEFIK_DATA}/traefik.yml ${TRAEFIK_DATA}/acme.json ${TRAEFIK_DATA}/providers/api.yml
