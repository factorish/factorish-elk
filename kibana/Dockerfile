# This file creates a container that runs Elasticsearch
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM paulczar/java_confd
MAINTAINER Paul Czarkowski "paul@paulcz.net"

ENV KIBANA kibana-4.0.0-beta3

RUN \
  cd /opt && \
  curl -sSL https://download.elasticsearch.org/kibana/kibana/$KIBANA.tar.gz \
  | tar xzf - && \
  cd - && \
  ln -s /opt/$KIBANA /opt/kibana

ADD . /app
RUN chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

# Expose ports.
EXPOSE 5601
