set term off
store set &__DIR_TEMP.\sqlenv replace
set term on
set ver off
set feed off
set serveroutput on size 1000000

col tablespace_name for a30
col tot_used head "Used Mb" for 999999.99
col tot_free head "Free Mb" for 999999.99
col tot_aloc head "Aloc Mb" for 999999.99
col usedpercent head "Used %" for 999.99

break on report
compute sum label Total of tot_used on report
compute sum label Total of tot_aloc on report

select
        t1.tablespace_name
        ,round(t1.tot_aloc-(t2.tot_free),2) tot_used
        ,round(t1.tot_aloc,2) tot_aloc
        ,round(((t3.maxsize)-(round(t1.tot_aloc-(t2.tot_free),2)))) tot_free
        ,round(t3.maxsize,2) maxsize
        ,case when t3.maxsize > 0 then round((((t3.maxsize)-(round(t1.tot_aloc-(t2.tot_free),2)))/t3.maxsize)*100,2) else
         0 end freepercent
from
(select tablespace_name, sum(bytes)/1024/1024 tot_aloc
from dba_data_files
group by tablespace_name) t1,
(select tablespace_name, sum(bytes)/1024/1024 tot_free
from dba_free_space
group by tablespace_name) t2,
(SELECT TABLESPACE_NAME, sum(MAXBYTES)/1024/1024 maxsize
FROM dba_data_files
GROUP BY TABLESPACE_NAME) t3
where t1.tablespace_name = t2.tablespace_name(+)
and t3.TABLESPACE_NAME = t1.tablespace_name
order by freepercent asc;

set head off


@&__DIR_TEMP.\sqlenv
set term on
