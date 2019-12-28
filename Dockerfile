FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends curl software-properties-common build-essential git jq && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR=/DoH
ENV GO_DL_URL="https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz"
ENV DoH_V="latest"
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID DoH && \
	chown -R DoH $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R DoH /opt/scripts

USER DoH

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]