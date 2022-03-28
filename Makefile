# Orchestrating file for the services offered

SUDO=
ifneq (${USER}, root)
SUDO=sudo
endif

DOMAIN=		barbunicorn.gay

TRAEFIK_DATA=	/srv/traefik
MAILSERVER_DATA=	/srv/mail
WORKDIR=	${CURDIR}/work

CONTAINERS=	traefik portainer mailserver
UP_TARGETS=	$(foreach container,${CONTAINERS},${container}/up)
DOWN_TARGETS=	$(foreach container,${CONTAINERS},${container}/down)

DMS_GITHUB_URL=	https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master

SSL_CERT=	~/ssl_certs/barbunicorn.gay.crt
SSL_KEY=	~/ssl_certs/barbunicorn.key

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

.PHONY: traefik/up traefik/down
traefik/up: ${TRAEFIK_DATA}/traefik.yml ${TRAEFIK_DATA}/acme.json ${TRAEFIK_DATA}/providers/api.yml
${UP_TARGETS}:
	${SUDO} docker-compose -f $(subst /up,,${@}).yml up -d

${DOWN_TARGETS}:
	${SUDO} docker-compose -f $(subst /down,,${@}).yml down

${WORKDIR}/setup.sh: ${WORKDIR}
	cd ${WORKDIR} && wget ${DMS_GITHUB_URL}/setup.sh

${MAILSERVER_DATA}/barbunicorn.gay.crt: ${MAILSERVER_DATA}
	${SUDO} cp ${SSL_CERT} ${@}

${MAILSERVER_DATA}/barbunicorn.key: ${MAILSERVER_DATA}
	${SUDO} openssl rsa -in ${SSL_KEY} -out ${@}

mailserver/up: ${MAILSERVER_DATA}/barbunicorn.gay.crt ${MAILSERVER_DATA}/barbunicorn.key \
	${MAILSERVER_DATA}/config
mailserver/add-user: ${WORKDIR}/setup.sh ${MAILSERVER_DATA}/config
	@[ -z "${MAILUSER}" ] && echo "Please set the env variable MAILUSER" && exit 1
	if [ "$$(${SUDO} docker ps --filter "name=mailserver" --quiet)" ] ; then \
		${SUDO} docker exec -ti mailserver setup email add ${MAILUSER}@${DOMAIN} ; \
	else \
		${SUPO} docker run -v ${MAILSERVER_DATA}/config:/tmp/docker-mailserver \
			docker.io/mailserver/docker-mailserver:latest setup email add \
			${MAILUSER}@${DOMAIN} ; \
	fi
