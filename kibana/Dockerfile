# This file creates a container that runs Kibana
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM factorish/factorish-java
MAINTAINER Paul Czarkowski "paul@paulcz.net"

# install etcdctl and confd
RUN curl -sSL -o /usr/local/bin/etcdctl https://s3-us-west-2.amazonaws.com/opdemand/etcdctl-v0.4.6 \
  && curl -sSL -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 \
  && chmod +x /usr/local/bin/etcdctl \
  && chmod +x /usr/local/bin/confd \
  && mkdir -p /app

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
