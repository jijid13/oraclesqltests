#!/bin/bash

echo "File V1.7" 

echo "Log path rights"
sudo chown -R 1000:1000 /home/jenkins/log

echo "Clear logs"
rm -rf /home/jenkins/log/*

echo "Create Dump Dir"
sqlplus system/oracle @/home/jenkins/createdir.sql >> /home/jenkins/log/createdir.log;

if [ -f "$INIT_FILES/init_before_impdp.sql" ];
then
	echo "Run init before impdp"
	sqlplus system/oracle @$INIT_FILES/init_before_impdp.sql >> /home/jenkins/log/init_before_impdp.log;
fi

if [ -f "$DUMP_FILE_PATH" ];
then
	echo "Copy the dump file $DUMP_FILE_PATH"
	cp $DUMP_FILE_PATH /tmp/metadata.dump
	echo "Start the import"
	impdp system/oracle directory=DUMP_DIR SCHEMAS=$IMPORT_SCHEMA dumpfile=metadata.dump logfile=impdp.log >> /tmp/import.log;
fi

if [ -f "$INIT_FILES/init_after_impdp.sql" ];
then
	echo "Run init after impdp"
	sqlplus system/oracle @$INIT_FILES/init_after_impdp.sql >> /home/jenkins/log/init_after_impdp.log;
fi

for f in $SQL_PATH/*; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
		echo "Run sql file $f"
            	sqlplus $SQLPLUS_USER/$SQLPLUS_PASSWORD @$f >> /home/jenkins/log/alters_user.log;
	   fi
    fi
done

for f in $SYSTEM_SQL_PATH/*; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
		echo "Run system sql file $f"
            	sqlplus system/oracle @$f >> /home/jenkins/log/alters_system.log;
        fi
    fi
done


CONSOLE_RED="\033[2;31m"
CONSOLE_GREEN="\033[2;32m"
CONSOLE_CLEAR="\033[0m"
JOB=$1
GOOD_BUILD="${GREEN}Last build successful. "
BAD_BUILD="${RED}Last build failed. "


if grep -q "ORA-" /home/jenkins/log/*.log; then
	if [ -f "/tmp/impdp.log" ];
	then
		echo "Copy the impdp log file"
		cp /tmp/impdp.log /home/jenkins/log/
	fi
	echo "${BAD_BUILD}${JOB} completed with errors.";
        exit 1
else
	if [ -f "/tmp/impdp.log" ];
	then
		echo "Copy the impdp log file"
		cp /tmp/impdp.log /home/jenkins/log/
	fi
        echo "${GOOD_BUILD}${JOB} completed successfully."
        exit 0
fi


