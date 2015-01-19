# This file creates a container that runs Elasticsearch
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM factorish/factorish-java
MAINTAINER Paul Czarkowski "paul@paulcz.net"

RUN \
  cd /opt && \
  curl -sSL https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz \
  | tar xzf - && \
  cd - && \
  ln -s /opt/elasticsearch-1.4.2 /opt/elasticsearch && \
  mkdir /data

ADD . /app
RUN chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

VOLUME /data

# Expose ports.
EXPOSE 9200 9300
