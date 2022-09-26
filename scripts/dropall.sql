@env_s

set heading off
set verify off
set feedback off

prompt @dropall <owner>

prompt ALTER SESSION SET RECYCLEBIN=OFF;;

select 
	case 
		when object_type = 'TABLE' then 'drop ' || object_type || ' "' || owner || '"."' || object_name ||'" cascade constraints'
		when object_type in ('OPERATOR', 'TYPE') then 'drop ' || object_type || ' "' || owner || '"."' || object_name ||'" force'
		else 'drop ' || object_type || ' "' || owner || '"."' || object_name || '"'
	end || ';'
from dba_objects
where owner = upper('&&1')
and object_type not in ('INDEX', 'LOB', 'PACKAGE BODY', 'TRIGGER')
order by object_type;

prompt ALTER SESSION SET RECYCLEBIN=ON;;
spo off

undef 1

@env_l
