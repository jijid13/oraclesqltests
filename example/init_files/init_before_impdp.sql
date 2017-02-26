CREATE USER user1 IDENTIFIED BY oracle;

GRANT CREATE SESSION TO user1;

revoke create public synonyms from user1;

exit;