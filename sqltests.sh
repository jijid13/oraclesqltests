@@ -1,40 +0,0 @@
#!/bin/bash
sqlplus system/oracle @/home/jenkins/createdir.sql;

sqlplus system/oracle @$INIT_FILES/init_before_impdp.sql;

cp $DUMP_FILE_PATH /tmp/metadata.dump
impdp system/oracle directory=DUMP_DIR SCHEMA=$IMPORT_SCHEMA dumpfile=metadata.dump logfile=/home/jenkins/log/impdp.log;

sqlplus system/oracle @$INIT_FILES/init_after_impdp.sql;

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


if grep -q "ORA-" /tmp/*.log; then
        echo "${BAD_BUILD}${JOB} completed with errors.";
else
        echo "${GOOD_BUILD}${JOB} completed successfully."
fi
