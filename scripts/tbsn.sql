set term off
store set &__DIR_TEMP.\sqlenv replace
set head on
set term on
set ver off
set feed off


col tablespace_name for a20
col tot_used head "Used Mb" for 999999.99
col tot_free head "Free Mb" for 999999.99
col tot_aloc head "Aloc Mb" for 999999.99
col usedpercent head "Used %" for 999.99

select t1.tablespace_name, (t1.tot_aloc-nvl(t2.tot_free,0)) tot_used,
       nvl(t2.tot_free,0) tot_free,
       t1.tot_aloc, (1-(nvl(t2.tot_free,0)/t1.tot_aloc))*100 usedpercent
from
(select tablespace_name, sum(bytes)/1024/1024 tot_aloc
from dba_data_files
group by tablespace_name) t1,
(select tablespace_name, sum(bytes)/1024/1024 tot_free
from dba_free_space
group by tablespace_name) t2
where t1.tablespace_name = t2.tablespace_name(+)
and t1.tablespace_name like upper ('&1');

col cont head "Temp?" for a5
col extmgmt head "ExtMgmt" for a7
col segmgmt head "SegMgmt" for a7
col initext head "InitExt(Kb)" for 99999999
col nextext head "NextExt(Kb)" for 99999999
col maxext head "MaxExt(Kb)" for 99999999
col pct_increase head "Inc%" for 9999
select t.tablespace_name,
       decode(t.contents,'PERMANENT','NO','YES') Cont,
       decode(t.extent_management,'DICTIONARY','DICT','LOCAL') ExtMgmt,
       t.segment_space_management SegMgmt,
       t.initial_extent/1024 initext,
       t.next_extent/1024 nextext,
       t.max_extents/1024 maxext,
       t.pct_increase
from dba_tablespaces t
where t.tablespace_name like upper ('&1');

col file_name for a60 head "Arquivo"
col autoextensible for a3 head "Ext?"
col Tam_kb for 99999999 head "Tamanho (Mb)"
col tammax_kb for 99999999 head "Maximo (Mb)"
col NextExt for 99999999 head "Next (Mb)"
select df.file_name, df.autoextensible,bytes/1024/1024 Tam_kb,
       maxbytes/1024/1024 tammax_kb,
       (df.increment_by*t.block_size/1024/1024) NextExt
from dba_tablespaces t, dba_data_files df
where t.tablespace_name = df.tablespace_name
and t.tablespace_name like upper ('&1')
order by df.file_id;

set head off

@&__DIR_TEMP.\sqlenv
set term on