FROM debian:wheezy-slim

#Add packages hosts
#RUN echo 'deb http://http.debian.net/debian wheezy-backports main' >> /etc/apt/sources.list.d/backports.list

#RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

#RUN apt-get update \
# && apt-get install -y apt-transport-https ca-certificates gnupg2

#RUN echo 'deb https://apt.dockerproject.org/repo debian-wheezy main' >> /etc/apt/sources.list.d/docker.list
#RUN apt-get update
#RUN apt-cache policy docker-engine

#RUN apt-get install -y unzip \
# && apt-get install -y mercurial \
# && apt-get install -y docker-engine \ 
# && service docker start 

#ADD ORACLE INSTANT CLIENT
#RUN mkdir -p opt/oracle
#ADD ./oracle/linux/ .

#ADD instantclient-basic-linux.x64-11.2.0.4.0.zip .
#ADD instantclient-sqlplus-linux.x64-11.2.0.4.0.zip .
#ADD instantclient-tools-linux.x64-11.2.0.4.0.zip .
#ADD instantclient-sdk-linux.x64-11.2.0.4.0.zip .

#RUN unzip instantclient-basic-linux.x64-11.2.0.4.0.zip -d /opt/oracle \
#  && unzip instantclient-sqlplus-linux.x64-11.2.0.4.0.zip -d /opt/oracle  \
#  && unzip instantclient-tools-linux.x64-11.2.0.4.0.zip -d /opt/oracle  \
#  && unzip instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /opt/oracle  \
#  && mv /opt/oracle/instantclient_11_2 /opt/oracle/instantclient \
#  && ln -s /opt/oracle/instantclient/libclntsh.so.11.2 /opt/oracle/instantclient/libclntsh.so \
#  && ln -s /opt/oracle/instantclient/libocci.so.11.2 /opt/oracle/instantclient/libocci.so   
#ENV LD_LIBRARY_PATH="/opt/oracle/instantclient”
#ENV OCI_HOME="/opt/oracle/instantclient”
#ENV OCI_LIB_DIR="/opt/oracle/instantclient”
#ENV OCI_INCLUDE_DIR="/opt/oracle/instantclient/sdk/include"

#RUN echo '/opt/oracle/instantclient/' | tee -a /etc/ld.so.conf.d/oracle_instant_client.conf && ldconfig



MAINTAINER Madjid Kazi Tani <jijid13@gmail.com>

ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
ENV ORACLE_SID=XE
ENV PATH=$ORACLE_HOME/bin:$PATH

ADD chkconfig /sbin/
ADD init.ora /
ADD initXETemp.ora /
ADD startup.sh /

# Install Oracle dependencies
RUN apt-get install wget -y && \
    wget https://github.com/jijid13/oraclesqltests/raw/master/oracle-xe_11.2.0-1.0_amd64.debaa && \
    wget https://github.com/jijid13/oraclesqltests/raw/master/oracle-xe_11.2.0-1.0_amd64.debab && \
    wget https://github.com/jijid13/oraclesqltests/raw/master/oracle-xe_11.2.0-1.0_amd64.debac && \
    apt-get install -y libaio1 net-tools bc && \
    ln -s /usr/bin/awk /bin/awk && \
    mkdir /var/lock/subsys && \
    chmod 755 /sbin/chkconfig && \
    chmod +x /startup.sh && \
    cat /oracle-xe_11.2.0-1.0_amd64.deba* > /oracle-xe_11.2.0-1.0_amd64.deb && \
    dpkg --install /oracle-xe_11.2.0-1.0_amd64.deb && \
    rm -rf oracle-xe* && \
    mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
    mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
    printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

EXPOSE 1521
EXPOSE 8080

ENTRYPOINT ["/startup.sh"]


