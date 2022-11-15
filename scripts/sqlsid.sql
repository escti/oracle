------------------------------------------------------------------------------------------
-- SQLSID.SQL
-- Apresenta texto do SQL executado pela sessao SID
------------------------------------------------------------------------------------------

set term off
set term on
set ver off
set line 130

col sql_text head "Comando" for a64
col sid for 999
col serial# for 99999

break on sid on serial#

select s.sid,s.serial#,st.sql_text
from v$session s, v$sqltext st
where s.sid = &1
and s.sql_address = st.address
and s.sql_hash_value = st.hash_value
order by st.piece;

set term on
