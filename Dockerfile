# This file creates a base container for the elk stack
#
# Author: Paul Czarkowski
# Date: 12/20/2014

FROM java:7
MAINTAINER Paul Czarkowski "paul@paulcz.net"

# Base Deps
RUN \
  apt-get update -yq && \
  apt-get install -yq \
  make \
  ca-certificates \
  net-tools \
  sudo \
  wget \
  vim \
  strace \
  lsof \
  netcat \
  lsb-release \
  locales \
  socat \
  --no-install-recommends

# download latest stable etcdctl

# install etcdctl and confd
RUN curl -sSL -o /usr/local/bin/etcdctl https://s3-us-west-2.amazonaws.com/opdemand/etcdctl-v0.4.6 \
&& chmod +x /usr/local/bin/etcdctl \
&& curl -sSL -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 \
&& chmod +x /usr/local/bin/confd

# Set up app dir

RUN mkdir /app

WORKDIR /app