-- -----------------------------------------------------------------------------------
-- File Name    : inativas.sql
-- Author       : Thiago Escodino (thiago@escti.net)
-- Description  : Mata todas as sessões inativas sem transações pendentes.
-- Call Syntax  : @inativas
-- Last Modified: 07/07/2022
-- -----------------------------------------------------------------------------------
set trim on
set trims on
set feedback off
SET UND off
set lines 10000 pages 5000
spo /home/oracle/tmp/_inativas.txt
SELECT
    'ALTER SYSTEM KILL SESSION '''
    || sid
    || ','
    || serial#
    || '''IMMEDIATE;'
FROM
    v$session
WHERE
        status = 'INACTIVE'
    AND taddr IS NULL
    AND username NOT IN ( 'ORACLE', 'SYS' );
spo off
select count (*) FROM V$SESSION WHERE STATUS = 'INACTIVE' and USERNAME not in ('ORACLE','SYS');
@/home/oracle/tmp/_inativas.txt
select count (*) FROM V$SESSION WHERE STATUS = 'INACTIVE' and USERNAME not in ('ORACLE','SYS');
