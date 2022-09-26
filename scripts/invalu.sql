set term off
store set &__DIR_TEMP.\sqlenv replace
set term on
set echo off
set linesize 150
set pagesize 0
set timing off
set feedback off
set trimspool on
set ver off

spool &__DIR_TEMP.\valida.sql
select
  'alter ' || decode(object_type,'PACKAGE BODY','PACKAGE',object_type) ||
  ' "' || owner || '"."' || object_name || '" compile;'
from dba_objects
where owner = upper('&1')
and status = 'INVALID'
and instr(object_type,'TYPE') = 0
and instr(object_type,'OPERATOR') = 0
and object_type <> 'MATERIALIZED VIEW'
order by decode(object_type, 'PACKAGE BODY', 0, 'PACKAGE', 0, 'FUNCTION', 1, 'PROCEDURE', 2, 'TRIGGER', 3);
spool off
prompt Para validar: @&__DIR_TEMP.\valida
set pagesize 100
set feedback on
set term off
@&__DIR_TEMP.\sqlenv
set term on
