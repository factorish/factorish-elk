# This file creates a container that runs Elasticsearch
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM factorish/factorish-java
MAINTAINER Paul Czarkowski "paul@paulcz.net"

WORKDIR /app

ENV ELASTICSEARCH elasticsearch-1.4.2

# install Elasticsearch
RUN \
  cd /opt && \
  curl -sSL https://download.elasticsearch.org/elasticsearch/elasticsearch/$ELASTICSEARCH.tar.gz \
  | tar xzf - && \
  cd - && \
  ln -s /opt/$ELASTICSEARCH /opt/elasticsearch && \
  mkdir /data

ADD . /app

RUN \
  chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

VOLUME /data

# Expose ports.
EXPOSE 9200 9300
