set term off
set term on
set line 178 pages 2000
col username for a20
col profile for a30
col default_tablespace head "Default tbs" for a20
col temporary_tablespace head "Temp tbs" for a25
col created for a12
col resource_grp for a25
col account_status for a16

select username,default_tablespace,temporary_tablespace,
       to_char(created, 'ddmmyy hh24:mi') created,
       account_status,
       initial_rsrc_consumer_group resource_grp,profile
from dba_users
order by username;

set term on
