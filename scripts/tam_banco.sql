-- Script: TAM_BANCO.SQL
-- Deve ser executado no banco X (origem) para geração do tamanho
-- total do banco.(temp, redo, dados etc.)
-- gera saida do tipo:
--
set term off
store set &__DIR_TEMP.\sqlenv replace
set term on

set term on
set ver off

col "Total Usado Mb." for 999999999999.99
col "Total Alocado Mb." for 999999999999.99
col "Host" for a20
select t5.host Host,t5.instancia Banco,(t1.tot_aloc-nvl(t2.tot_free,0)) "Total Usado Mb.",
(t1.tot_aloc+nvl(t3.tot_redo,0)) "Total Alocado Mb.", t4.tot_temp "Total Temporaria Mb."
from
(select sum(bytes)/1024/1024 tot_aloc
from dba_data_files)t1,
(select  sum(bytes)/1024/1024 tot_free
from dba_free_space) t2,
(select  sum(bytes)/1024/1024 tot_redo
from v$logfile lf,v$log l
where lf.group# = l.group#
) t3,
(select sum(tf.bytes/1024/1024) tot_temp
from dba_temp_files tf,dba_tablespaces t
where tf.tablespace_name = t.tablespace_name
) t4,
(select replace(host_name,'.cst.com.br') host,instance_name instancia
from v$instance
) t5;


@&__DIR_TEMP.\sqlenv.sql
set term on
