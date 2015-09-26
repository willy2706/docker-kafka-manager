FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Sbt
RUN wget -O - -L https://dl.bintray.com/sbt/native-packages/sbt/0.13.9/sbt-0.13.9.tgz | tar zx
RUN ln -s /sbt/bin/sbt /usr/bin/sbt
RUN sbt about

RUN cd /tmp && git clone --depth 1 https://github.com/yahoo/kafka-manager.git
RUN cd /tmp/kafka-manager && \
    sbt clean dist && \
    unzip target/universal/kafka-manager-*.zip -d / && \
    mv /kafka-manager* /kafka-manager && \
    rm -rf /tmp/kafka-manager

#Add runit services
COPY sv /etc/service 

