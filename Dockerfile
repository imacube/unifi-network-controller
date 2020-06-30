FROM debian:9

RUN apt-get update
RUN apt-get install -y ca-certificates apt-transport-https gnupg2 procps
RUN echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50
RUN apt-get update
RUN apt-get install unifi -y
RUN apt-get clean

ADD docker-entrypoint.bash /docker-entrypoint.bash
RUN chmod +x docker-entrypoint.bash

VOLUME ["/var/lib/unifi", "/var/log/unifi"]
VOLUME ["/var/lib/mongodb", "/var/log/mongodb"]

ENTRYPOINT ["/docker-entrypoint.bash"]
