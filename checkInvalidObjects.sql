EXEC DBMS_UTILITY.compile_schema(schema => '&1');

SPOOL invalidObjects.out
select count(object_name) || ' invalid objects'
from dba_objects
where status = 'INVALID'
AND OBJECT_TYPE != 'JAVA CLASS';

SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  status = 'INVALID'
AND OBJECT_TYPE != 'JAVA CLASS'
ORDER BY owner, object_type, object_name;
SPOOL OFF;
exit;
