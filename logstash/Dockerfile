# This file creates a container that runs Logstash
#
# Author: Paul Czarkowski
# Date: 08/16/2014

FROM factorish/factorish-java
MAINTAINER Paul Czarkowski "paul@paulcz.net"

ENV LOGSTASH logstash-1.5.0.beta1

RUN \
  cd /opt && \
  curl -sSL http://download.elasticsearch.org/logstash/logstash/$LOGSTASH.tar.gz \
  | tar xzf - && \
  cd - && \
  ln -s /opt/$LOGSTASH /opt/logstash && \
  mkdir /opt/logstash/conf.d

ADD . /app
RUN chmod +x /app/bin/*

# Define default command.
CMD ["/app/bin/boot"]

# Expose ports.
EXPOSE 514
