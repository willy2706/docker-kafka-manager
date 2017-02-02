FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Sbt
RUN wget -O - -L --no-check-certificate https://dl.bintray.com/sbt/native-packages/sbt/0.13.11/sbt-0.13.11.tgz | tar zx
RUN ln -s /sbt/bin/sbt /usr/bin/sbt

RUN cd /tmp && wget -O - https://github.com/yahoo/kafka-manager/archive/1.3.1.8.tar.gz | tar zx && \
    cd /tmp/kafka-manager* && \
    sbt clean dist && \
    unzip target/universal/kafka-manager-*.zip -d / && \
    mv /kafka-manager* /kafka-manager && \
    rm -rf /tmp/kafka-manager*

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

