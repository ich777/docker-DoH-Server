FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install wget curl software-properties-common build-essential git jq

ENV DATA_DIR=/DoH
ENV GO_DL_URL="https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz"
ENV DoH_V=2.1.2
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID DoH
RUN chown -R DoH $DATA_DIR

RUN ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R DoH /opt/scripts

USER DoH

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]