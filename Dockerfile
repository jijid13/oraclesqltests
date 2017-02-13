# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM ubuntu:14.04.1

MAINTAINER Madjid Kazi Tani <jijid13@gmail.com>

ENV ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
ENV ORACLE_SID=XE
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV DUMP_PATH=/
ENV INIT_FILES=/
ENV SCHEMA=PB00
ENV SQL_PATH=/
ENV ADMIN_SQL_PATH=/
ENV PASSWORD=oracle

# In case you need proxy
#RUN echo 'Acquire::http::Proxy "http://127.0.0.1:8080";' >> /etc/apt/apt.conf

# Add locales after locale-gen as needed
# Upgrade packages on image
# Preparations for sshd
run locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends openssh-server &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends git &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends wget &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends libaio1 &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends net-tools &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends bc &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

ADD oracle-xe_11.2.0-1.0_amd64.debaa /
ADD oracle-xe_11.2.0-1.0_amd64.debab /
ADD oracle-xe_11.2.0-1.0_amd64.debac /

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install JDK 7 (latest edition)
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew"  --no-install-recommends openjdk-7-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Set user jenkins to the image
RUN useradd -m -d /home/jenkins -s /bin/sh jenkins &&\
    echo "jenkins:jenkins" | chpasswd &&\
    usermod -a -G sudo jenkins &&\
    echo "jenkins    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


RUN mkdir /home/jenkins/workspace && \
    chown jenkins:jenkins /home/jenkins/workspace && \
    mkdir /home/jenkins/workspace/testoracle && \
    chown jenkins:jenkins /home/jenkins/workspace/testoracle 

ADD chkconfig /sbin/
ADD init.ora /
ADD initXETemp.ora /
ADD startup.sh /
ADD createdir.sql /home/jenkins/
ADD sqltests.sh /home/jenkins/

RUN chmod u+x /home/jenkins/sqltests.sh && \
    chown jenkins:jenkins /home/jenkins/sqltests.sh && \
    chown jenkins:jenkins /startup.sh

RUN ln -s /usr/bin/awk /bin/awk && \
    mkdir /var/lock/subsys && \
    chmod 755 /sbin/chkconfig && \
    chmod +x /startup.sh && \
    cat /oracle-xe_11.2.0-1.0_amd64.deba* > /oracle-xe_11.2.0-1.0_amd64.deb && \
    dpkg --install /oracle-xe_11.2.0-1.0_amd64.deb && \
    rm -rf oracle-xe* && \
    mv /init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
    mv /initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
    printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]

