
MAILSERVER_DATA=	/srv/mail
DOMAIN=		barbunicorn.gay

DMS_GITHUB_URL=	https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master

SSL_CERT=	~/ssl_certs/barbunicorn.gay.crt
SSL_KEY=	~/ssl_certs/barbunicorn.key

${WORKDIR}:
	mkdir -p ${@}

${MAILSERVER_DATA}/barbunicorn.gay.crt: ${MAILSERVER_DATA}
	${SUDO} cp ${SSL_CERT} ${@}

${MAILSERVER_DATA}/barbunicorn.key: ${MAILSERVER_DATA}
	${SUDO} openssl rsa -in ${SSL_KEY} -out ${@}

config: ${MAILSERVER_DATA}/barbunicorn.gay.crt ${MAILSERVER_DATA}/barbunicorn.key \
	${MAILSERVER_DATA}/config

add-user: ${MAILSERVER_DATA}/config
	@[ -z "${MAILUSER}" ] && echo "Please set the env variable MAILUSER" && exit 1
	if [ "$$(${SUDO} docker ps --filter "name=mailserver" --quiet)" ] ; then \
		${SUDO} docker exec -ti mailserver setup email add ${MAILUSER}@${DOMAIN} ; \
	else \
		${SUDO} docker run -v ${MAILSERVER_DATA}/config:/tmp/docker-mailserver \
			docker.io/mailserver/docker-mailserver:latest setup email add \
			${MAILUSER}@${DOMAIN} ; \
	fi
