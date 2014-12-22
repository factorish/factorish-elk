# This file creates a container that runs Elasticsearch
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM paulczar/java_confd
MAINTAINER Paul Czarkowski "paul@paulcz.net"

RUN \
  cd /opt && \
  curl -sSL https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz \
  | tar xzf - && \
  cd - && \
  ln -s /opt/elasticsearch-1.4.2 /opt/elasticsearch

ADD . /app
RUN chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

# Expose ports.
EXPOSE 9200 9300
