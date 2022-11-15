------------------------------------------------------------------------------------------
-- VS.SQL
-- Apresenta informacoes de sessoes no banco de dados
------------------------------------------------------------------------------------------

set term off
store set /tmp/sqlenv replace
set term on

set line 150 pages 2000
col program for a18 wrap
col machine for a15
col username for a15
col osuser for a15
col logon for a14
col client_info for a20
col sid for 9999
col spid for a8
col serial# for 99999

select p.spid,
       substr(s.machine,instr(replace(s.machine,'/','\'),'\',-2)+1) machine,
       substr(substr(s.osuser,instr(replace(s.osuser,'/','\'),'\',-2)+1),1,10) osuser,
       s.username, s.sid, s.serial#, s.taddr trans,
       to_char(logon_time,'dd/mm/yy hh24:mi') logon,
       s.client_info,
       substr(s.program,instr(replace(replace(s.program,'/','\'),']','\'),'\',-2)+1) program
  from v$session s, v$process p
  where s.paddr = p.addr(+)
  and s.username is not null
  order by p.spid;

@/tmp/sqlenv
set term on
