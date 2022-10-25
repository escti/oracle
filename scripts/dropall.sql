-- -----------------------------------------------------------------------------------
-- File Name    : dropall.sql
-- Author       : Thiago Escodino (thiago@escti.net)
-- Description  : Gera comandos para apagar objetos de um schema.
-- Call Syntax  : @dropall.sql
-- Last Modified: 07/07/2022
-- -----------------------------------------------------------------------------------
set heading off
set verify off
set feedback off

prompt ALTER SESSION SET RECYCLEBIN=OFF;;

SELECT CASE
           WHEN object_type = 'TABLE' THEN 'drop ' || object_type || ' "' || OWNER || '"."' || object_name ||'" cascade constraints'
           WHEN object_type in ('OPERATOR',
                                'TYPE') THEN 'drop ' || object_type || ' "' || OWNER || '"."' || object_name ||'" force'
           ELSE 'drop ' || object_type || ' "' || OWNER || '"."' || object_name || '"'
       END || ';'
FROM dba_objects
WHERE OWNER = upper('&&1')
  AND object_type not in ('INDEX',
                          'LOB',
                          'PACKAGE BODY',
                          'TRIGGER')
ORDER BY object_type;

prompt ALTER SESSION SET RECYCLEBIN=ON;;

undef 1
