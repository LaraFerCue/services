# Orchestrating file for the services offered

SUDO=
ifneq (${USER}, root)
SUDO=sudo
endif

WORKDIR=	${CURDIR}/work

export WORKDIR SUDO

SERVICES=	nginx mailserver portainer traefik valheim mail monitoring
restart_cmds=	$(addsuffix /restart,${SERVICES})

%/config:
	make -C $(dir ${@}) config

%/up:
	cd $(dir ${@}) && ${SUDO} docker-compose pull && ${SUDO} docker-compose up -d

%/down:
	cd $(dir ${@}) && ${SUDO} docker-compose down

renew-mail-certs:
	make -C ${CURDIR} traefik/down
	sudo docker run -it --rm --name certbot -v /srv/mail/letsencrypt/:/etc/letsencrypt -v "/var/lib/letsencrypt:/var/lib/letsencrypt" -p80:80 -p443:443 certbot/certbot certonly

$(restart_cmds): %/restart: | %/down %/up
