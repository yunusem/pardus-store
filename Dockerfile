FROM debian:testing-slim
MAINTAINER  Gökhan Karabulut <gokhanettin@gmail.com>

RUN apt-get update && apt-get install \
  build-essential equivs devscripts --no-install-recommends -y

COPY . /pardus-store



