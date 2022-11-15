PROMPT This INSTANCE
select s1.username || '@' || s1.machine || ' ( SID=' || s1.sid || ' - SERIAL#= '|| s1.SERIAL# ||' )  is blocking ' ||
 s2.username|| '@' || s2.machine || ' ( SID=' || s2.sid || ' - SERIAL#= '|| s2.SERIAL# ||' ) '||CHR(10)||
 'Para Matar: '||chr(10)||
 'ALTER SYSTEM DISCONNECT SESSION '||CHR(39)|| s1.sid||','||s1.SERIAL#||CHR(39)||' IMMEDIATE;'
AS blocking_status
from v$lock l1, v$session s1, v$lock l2, v$session s2
where s1.sid=l1.sid
and s2.sid=l2.sid
and l1.BLOCK=1
and l2.request > 0
and l1.id1 = l2.id1
and l2.id2 = l2.id2 ;
Prompt RAC
select distinct s1.username || '@' || s1.machine|| ' ( INST=' || s1.inst_id || ' SID=' || s1.sid ||' SERIAL#='||s1.serial#|| ' ) esta bloqueando '
|| s2.username || '@' || s2.machine || ' ( INST=' || s2.inst_id || ' SID=' || s2.sid ||' SERIAL#='||s2.serial# ||' ) '||chr(10)||
'Wait time: '||w.seconds_in_wait||'s'||CHR(10)||
 'Para matar sessao bloqueadora, na instance  '||s1.inst_id ||'  execute: '||chr(10)||
 'ALTER SYSTEM DISCONNECT SESSION '||CHR(39)|| s1.sid||','||s1.SERIAL#||CHR(39)||' IMMEDIATE;'||chr(10)||chr(10)
AS blocking_status
from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2,gv$session_wait w
where s1.sid=l1.sid and s2.sid=l2.sid
and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
and l1.block > 0 and l2.request > 0
and l1.id1 = l2.id1 and l1.id2 = l2.id2
and w.sid=s2.sid
and w.seconds_in_wait > 5;
