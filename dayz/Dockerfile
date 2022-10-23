FROM steamcmd/steamcmd:ubuntu

RUN apt update --yes
RUN apt install --yes libcap2 curl

ENV HOME=/dayz
WORKDIR /dayz
RUN steamcmd +force_install_dir /dayz +login anonymous +app_update 1042420 verify +quit
ENTRYPOINT ["/dayz/DayZServer", "-cpuCount=3", "-dologs", \
	"-adminlog", "-netlog", "-freezecheck", "-profiles=/data", \
	"-config=/dayz/serverDZ_barb.cfg" ]
