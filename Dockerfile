FROM debian:stretch-slim
MAINTAINER  Yunusemre Şentürk <se.yunusemre@gmail.com>

RUN apt-get update && apt-get install \
  build-essential equivs devscripts --no-install-recommends -y

COPY . /pardus-store
