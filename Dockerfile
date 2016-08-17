FROM ubuntu:xenial

RUN apt-get update && apt-get install -y curl vim less
RUN curl -L -o /opt/sensu.deb https://sensu.global.ssl.fastly.net/apt/pool/sensu/main/s/sensu/sensu_0.25.7-1_amd64.deb && dpkg -i /opt/sensu.deb

COPY files/start.sh /opt/start.sh
RUN chmod 755 /opt/start.sh

