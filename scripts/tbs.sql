@env_s

set feedback off

col file# for 999
col tablespace_name for a25
col file_name for a90 wrap
col tam for 999999999
col status for a9
col "Temp?" for a5
col "Manag" for a5
col ext for a3
col maxsize for 999999999

break on report
compute sum label Total of tam on report
compute sum label Total of maxsize on report

select f.file#,
       ts.name tablespace_name, 
       f.name file_name, 
       f.bytes/1024/1024 tam,
       t.bigfile,
       t.status,
       decode(contents,'PERMANENT','NO','YES') "Temp?",
       decode(extent_management,'DICTIONARY','DICT','LOCAL') "Manag",
       pf.autoextensible ext, 
       decode(pf.maxbytes/1024/1024,0,f.bytes/1024/1024,pf.maxbytes/1024/1024) maxsize,
       round(pf.increment_by*8/1024,0) inc
from v$datafile f,v$tablespace ts, dba_tablespaces t, 
     dba_data_files pf
where f.ts# = ts.ts#
and ts.name = t.tablespace_name
and f.file# = pf.file_id(+)
order by 2,3;


select f.file#,ts.name tablespace_name, f.name file_name, f.bytes/1024/1024 tam,f.status,
       decode(contents,'PERMANENT','NO','YES') "Temp?",
       decode(extent_management,'DICTIONARY','DICT','LOCAL') "Manag",
       pf.autoextensible ext, pf.maxbytes/1024/1024 maxsize, round(pf.increment_by*8/1024,0) inc
from v$tempfile f,v$tablespace ts, dba_tablespaces t,
     dba_temp_files pf
where f.ts# = ts.ts#
and ts.name = t.tablespace_name
and f.file# = pf.file_id(+)
order by 2;

cle compute

@env_l


