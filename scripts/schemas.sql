-- -----------------------------------------------------------------------------------
-- File Name    : schemas.sql
-- Author       : Thiago Escodino (thiago@escti.net)
-- Description  : Lista os schemas com objetos e seus respectivos tamanhos.
-- Call Syntax  : @schemas.sql
-- Last Modified: 07/07/2022
-- -----------------------------------------------------------------------------------
col schema for a20
set lines 150 pages 2000

SELECT
OWNER AS SCHEMA,
CEIL(SUM(bytes)/ 1024 / 1024) AS SIZE_MB,
COUNT(segment_name) AS NUM_OBJECTS
FROM
dba_segments
WHERE
OWNER NOT IN('ANONYMOUS', 'APEX_040200', 'APEX_PUBLIC_USER', 'APPQOSSYS',
'AUDSYS', 'BI', 'CTXSYS', 'DBSNMP', 'DIP', 'DVF', 'DVSYS', 'EXFSYS',
'FLOWS_FILES', 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'HR', 'IX',
'LBACSYS', 'MDDATA', 'MDSYS', 'OE', 'ORACLE_OCM', 'ORDDATA', 'ORDPLUGINS',
'ORDSYS', 'OUTLN', 'PM', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SPATIAL_CSW_ADMIN_USR',
'SPATIAL_WFS_ADMIN_USR', 'SYS', 'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSTEM',
'WMSYS', 'XDB', 'SYSMAN', 'RMAN', 'RMAN_BACKUP', 'OWBSYS', 'OWBSYS_AUDIT',
'APEX_030200', 'MGMT_VIEW', 'OJVMSYS', 'XS$NULL', 'OLAPSYS', 'SECURITY','PERFSTAT')
GROUP BY
OWNER
ORDER BY
SUM(BYTES) DESC; 
