#!/bin/bash

echo "File V1.5" 

sudo chown -R 1000:1000 /home/jenkins/log

sqlplus system/oracle @/home/jenkins/createdir.sql >> /home/jenkins/log/createdir.log;

if [ -f "$INIT_FILES/init_before_impdp.sql" ];
then
   sqlplus system/oracle @$INIT_FILES/init_before_impdp.sql >> /home/jenkins/log/init_before_impdp.log;
fi

if [ -f "$DUMP_FILE_PATH" ];
then
	cp $DUMP_FILE_PATH /tmp/metadata.dump
	impdp system/oracle directory=DUMP_DIR SCHEMAS=$IMPORT_SCHEMA dumpfile=metadata.dump logfile=impdp.log;
	cp /tmp/impdp.log /home/jenkins/log/
fi

if [ -f "$INIT_FILES/init_after_impdp.sql" ];
then
	sqlplus system/oracle @$INIT_FILES/init_after_impdp.sql >> /home/jenkins/log/init_after_impdp.log;
fi

for f in $SQL_PATH/*; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
            sqlplus $SQLPLUS_USER/$SQLPLUS_PASSWORD @$f >> /home/jenkins/log/alters_user.log;
	   fi
    fi
done

for f in $SYSTEM_SQL_PATH/*; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]; then
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
        echo "${BAD_BUILD}${JOB} completed with errors.";
        exit 1
else
        echo "${GOOD_BUILD}${JOB} completed successfully."
        exit 0
fi


