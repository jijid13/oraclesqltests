EXEC DBMS_UTILITY.compile_schema(schema => '&1');

begin
for r in (
                            select ao.object_name, syno.table_owner, syno.table_name from all_objects ao 
                            join all_synonyms syno on syno.synonym_name = ao.object_name
                            where status ='INVALID' and object_type='SYNONYM'
              )
loop
Begin
execute Immediate 'create or replace public synonym '||r.object_name||' for ' || r.table_owner||'.'||r.table_name;
dbms_output.put_line('create or replace public synonym '||r.object_name||' for ' || r.table_owner||'.'||r.table_name||';');
Exception
When Others Then
dbms_output.put_line('Public synonym '||r.object_name||' still invalid.ERROR :' || SQLERRM);
End;
end loop;
end;
/


SPOOL invalidObjects.out
select count(object_name) || ' invalid objects'
from dba_objects
where status = 'INVALID'
AND OBJECT_TYPE != 'JAVA CLASS'
AND object_name not in ('&2');

SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  status = 'INVALID'
AND OBJECT_TYPE != 'JAVA CLASS'
AND object_name not in ('&2')
ORDER BY owner, object_type, object_name;
SPOOL OFF;
exit;
