#!/bin/bash 
## Script: escti_backup_rman_full.sh
## Proposito: Fazer backup FULL do banco de dados ONLINE
## Modificado: Thiago E. de Albuquerque (dba@@escti.net)
## Data última modificação: 26/10/2022
# Variaveis
echo  ----------------------------------------------------
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Iniciando procedimento:

export NLS_DATE_FORMAT="YYYY/MM/DD HH24:MI:SS"
. ~/.bash_profile
SID=${1}
DIR=${2}

export ORACLE_SID="$SID"
DATA=`date --date="0 days ago" +%Y%m%d%H%M%S`

# Lock no arquivo para impedir execucao dupla
LOCK=$DIR/.backup_rman_$SID.lck

if [ -f $LOCK ]; then 
echo  $(date  +%d-%m-%Y_%H:%M:%S) - procedimento já está em execução. Saindo...
fi 

if [ -f $LOCK ]; then
    exit 1
fi

touch $LOCK

# iniciar backup via RMAN
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Iniciando backup:

rman target / LOG=$DIR/log/log_bkp_rman_$SID_$DATA.log <<EOF
run
{
SET COMMAND ID TO '1bkp_SP-$SID';
sql "create pfile = ''$DIR/PF_$SID_$DATA.ora'' from spfile";

crosscheck archivelog all;

SET COMMAND ID TO '2bkp_FL-$SID';
backup as compressed backupset database
tag '$DATA'
filesperset 5
format '$DIR/db_%d_%s_%p.bkp'
plus archivelog
format '$DIR/arch_%d_%s_%p.bkp'
delete all input;

SET COMMAND ID TO '3bkp_CF-$SID';
copy current controlfile to '$DIR/CF_$SID_$DATA.bkp';

crosscheck backup;
SET COMMAND ID TO '4bkp_DL-$SID';
DELETE NOPROMPT OBSOLETE;
}
EOF

echo  $(date  +%d-%m-%Y_%H:%M:%S) - backup finalizado

# Remove o arquivo de LOCK
rm $LOCK

# Remove arquivos de logs do backup rman com mais de 30 dias de criação
echo  $(date  +%d-%m-%Y_%H:%M:%S) - removendo logs antigos
find $DIR/log -name "log_bkp_rman_*.log" -mtime +29 -exec rm  {} \;

# Remove backups antigos fora do período de rentenção
echo  $(date  +%d-%m-%Y_%H:%M:%S) - removendo arquivos fora da retenção

rman target / LOG=$DIR/log/log_cleanup_rman_$SID_$DATA.log <<EOF
run
{
SET COMMAND ID TO 'clean_old_$SID';
crosscheck archivelog all;
crosscheck backupset;
crosscheck backup ;
crosscheck copy ;
crosscheck datafilecopy all;
delete noprompt obsolete;
delete noprompt expired archivelog all;
delete noprompt expired backup;
}
EOF

echo  $(date  +%d-%m-%Y_%H:%M:%S) - fim do procedimento.
echo  ----------------------------------------------------