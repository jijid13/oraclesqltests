#!/bin/bash

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export PATH=$ORACLE_HOME/bin:$PATH

#Fix Oracle Listener
sudo sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora

echo "STARTING ORACLE..."
sudo service oracle-xe start

sudo chown -R 1000:1000 /home/jenkins/workspace/log

/home/jenkins/sqltests.sh
