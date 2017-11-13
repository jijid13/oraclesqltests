#!/bin/bash

mkdir /home/jenkins/db
cp -r "$SQL_PATH"/* /home/jenkins/db
export SQL_PATH=/home/jenkins/db

mkdir /home/jenkins/system
cp -r "$SYSTEM_SQL_PATH"/* /home/jenkins/system
export SYSTEM_SQL_PATH=/home/jenkins/system


now=$(date +"%A %W %Y %X")

echo "[$now] [Info] : File V1.8" 

echo "[$now] [Info] : Log path rights"
sudo chown -R 1000:1000 /home/jenkins/log

sqlplus system/oracle <<EOF 
ALTER USER system IDENTIFIED BY oracle;
EOF

echo "[$now] [Info] : Clear logs"
rm -rf /home/jenkins/log/*

echo "[$now] [Info] : Create Dump Dir"
sqlplus system/oracle @/home/jenkins/createdir.sql >> /home/jenkins/log/createdir.log;

if [ -f "$INIT_FILES/init_before_impdp.sql" ];
then
	echo "[$now] [Info] : Run init before impdp"
	sqlplus system/oracle @$INIT_FILES/init_before_impdp.sql >> /home/jenkins/log/init_before_impdp.log;
fi

if [ -f "$DUMP_FILE_PATH" ];
then
	echo "[$now] [Info] : Copy the dump file $DUMP_FILE_PATH"
	cp $DUMP_FILE_PATH /tmp/metadata.dump
	echo "[$now] [Info] : Start the import"
	impdp system/oracle directory=DUMP_DIR SCHEMAS=$IMPORT_SCHEMA dumpfile=metadata.dump logfile=impdp.log >> /tmp/import.log;
fi

if [ -f "$INIT_FILES/init_after_impdp.sql" ];
then
	echo "[$now] [Info] : Run init after impdp"
	sqlplus system/oracle @$INIT_FILES/init_after_impdp.sql >> /home/jenkins/log/init_after_impdp.log;
fi

for f in `ls -v $SQL_PATH/*`; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
		echo "[$now] [Info] : Run sql file $f"
		echo "$f" >> /home/jenkins/log/alters_user.log;
            	sqlplus $SQLPLUS_USER/$SQLPLUS_PASSWORD @$f >> /home/jenkins/log/alters_user.log;
	   fi
    fi
done

for f in `ls -v $SYSTEM_SQL_PATH/*`; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
		echo "[$now] [Info] : Run system sql file $f"
		echo "$f" >> /home/jenkins/log/alters_system.log;
            	sqlplus system/oracle @$f >> /home/jenkins/log/alters_system.log;
        fi
    fi
done

echo "check invalid Objects"
sqlplus system/oracle @/home/jenkins/checkInvalidObjects.sql $IMPORT_SCHEMA $FILTERED_OUT_OBJECTS >> /home/jenkins/log/checkInvalidObjects.log

echo "[$now] [Info] : start logs trace **************************************************************************************"
echo "***********************************************************************************************************************"

echo "init_before_impdp.log *************************************"
cat /home/jenkins/log/init_before_impdp.log

echo "init_after_impdp.log **************************************"
cat /home/jenkins/log/init_after_impdp.log

echo "alters_user.log *******************************************"
cat /home/jenkins/log/alters_user.log

echo "alters_system.log *****************************************"
cat /home/jenkins/log/alters_system.log

echo "alters_system.log *****************************************"
cat /home/jenkins/log/alters_system.log

echo "checkInvalidObjects.log ***********************************"
cat /home/jenkins/log/checkInvalidObjects.log

echo "***********************************************************************************************************************"
echo "[$now] [Info] : end logs trace ****************************************************************************************"

CONSOLE_RED="\033[2;31m"
CONSOLE_GREEN="\033[2;32m"
CONSOLE_CLEAR="\033[0m"
JOB=$1
GOOD_BUILD="${GREEN}Last build successful. "
BAD_BUILD="${RED}Last build failed. "


if grep -q "ORA-" /home/jenkins/log/*.log; then
	if [ -f "/tmp/impdp.log" ];
	then
		echo "[$now] [Info] : Copy the impdp log file"
		cp /tmp/impdp.log /home/jenkins/log/
	fi
	echo "[$now] [Error] : ${BAD_BUILD}${JOB} completed with errors.";
        exit 1
else
	if [ -f "/tmp/impdp.log" ];
	then
		echo "[$now] [Info] : Copy the impdp log file"
		cp /tmp/impdp.log /home/jenkins/log/
	fi
	
	if grep -q "0 invalid objects" /home/jenkins/log/checkInvalidObjects.log; then
		echo "[$now] [Info] : ${GOOD_BUILD}${JOB} completed successfully."
        	exit 0
	else
		echo "[$now] [Error] : ${BAD_BUILD}${JOB} completed with errors.";
        	exit 1
	fi
fi


