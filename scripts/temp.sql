set linesize 150
column file_name format a60
col USER_BYTES for 99999999
col MAXBYTES for 99999999
col BYTES for 99999999
col TABLESPACE_NAME for a15
select 
file_name
,tablespace_name
,autoextensible
,USER_BYTES /1024/1024 U_BYTES
,MAXBYTES /1024/1024 max_used
,BYTES /1024/1024 mb_used
from dba_temp_files
;
