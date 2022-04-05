PROMETHEUS_DATA=	/srv/prometheus
GRAFANA_DATA=	/srv/grafana

${PROMETHEUS_DATA} ${GRAFANA_DATA}:
	${SUDO} mkdir -p ${@}

config: ${PROMETHEUS_DATA}/prometheus.yml ${GRAFANA_DATA}/grafana.ini /etc/docker/daemon.json

${PROMETHEUS_DATA}/prometheus.yml: ${PROMETHEUS_DATA}
	${SUDO} cp ${CURDIR}/files/prometheus.yml ${@}

${GRAFANA_DATA}/grafana.ini: ${GRAFANA_DATA}
	${SUDO} cp ${CURDIR}/files/grafana.ini ${@}

/etc/docker/daemon.json:
	${SUDO} cp ${CURDIR}/files/$(notdir ${@}) ${@}
