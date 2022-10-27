#!/bin/bash

## Script: escti_kill_inativas.sh
## Proposito: Eliminar sessões inativas
## Autor: Thiago E. de Albuquerque (dba@escti.net)
## Data última modificação: 26/10/2022
## Cron: 59 05,11,18,23 * * * /home/oracle/nexa/scripts/rotinas/escti_kill_inativas.sh nbs
# Variaveis
. ~/.bash_profile
SID=${1}
export ORACLE_SID="$SID"

sqlplus -s / as sysdba <<EOF
purge dba_recyclebin;
set trim on
set trims on
set feedback off
SET UND off
set lines 10000 pages 5000
spo _inativas.txt
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
@_inativas.txt
select count (*) FROM V$SESSION WHERE STATUS = 'INACTIVE' and USERNAME not in ('ORACLE','SYS');
exit
EOF
