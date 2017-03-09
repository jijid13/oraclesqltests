EXEC DBMS_UTILITY.compile_schema(schema => '&1');

SPOOL invalidObjects.out
select count(object_name) || ' invalid objects'
from dba_objects
where status = 'INVALID';

SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  status = 'INVALID'
ORDER BY owner, object_type, object_name;
SPOOL OFF;
exit;
