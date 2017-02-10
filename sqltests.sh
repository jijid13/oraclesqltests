sqlplus system/oracle /createdir.sql;
sqlplus system/oracle $INIT_FILES/init_before_impdp.sql;
cp $DUMP_PATH/metadata.dump /tmp
impdp system/oracle directory=DUMP_DIR SCHEMA=$SCHEMA dumpfile=metadata.dump logfile=impdp.log;
sqlplus system/oracle $INIT_FILES/init_after_impdp.sql;

for f in $SQL_PATH/*; do
    if [ -f $f ]; then
	if [[ $f == *.sql ]]
        	sqlplus $SCHEMA/$PASSWORD $f;
	fi
    fi
done

for f in $ADMIN_SQL_PATH/*; do
    if [ -f $f ]; then
        if [[ $f == *.sql ]]
                sqlplus system/oracle $f;
        fi
    fi
done

