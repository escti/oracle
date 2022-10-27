#!/bin/bash 

## Script: escti_backup_archive.sh 
## Proposito: Fazer backup ARCHIVE do banco de dados ONLINE 
## Autor: NEXA
## Modificado: Thiago E. de Albuquerque (thiago@escti.net, dba@escti.net) 
## Data última modificação: 26/10/2022 
## Command: ./escti_backup_archive.sh SID /DIR/
# -- CONFIGURAÇÃO --
# Crie a pasta: mkdir -p /bkpdir/banco/rman/log  
# Permitir execução: chmod +x /home/oracle/escti/rotinas/escti_backup_archive.sh
# Adicionar ao crontab: */20 * * * * /home/oracle/escti/rotinas/escti_backup_archive.sh scp1 /oracle/backup/rman/scp1

# Variaveis 
. ~/.bash_profile 
SID=${1} 
DIR=${2} 
export ORACLE_SID="$SID" 
DATA=`date --date="0 days ago" +%Y%m%d%H%M%S` 
echo  -----------------------------------------------------
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Iniciando procedimento: 
# Lock no arquivo para impedir execucao dupla 
LOCK=$DIR/.backup_arch_$SID.lck 

if [ -f $LOCK ]; then 
echo  $(date  +%d-%m-%Y_%H:%M:%S) - arquivo de lock presente. Finalizando... 
    exit 1 
fi 

touch $LOCK 

# RMAN 
rman target / LOG=$DIR/log/log_bkp_arch_$SID_$DATA.log <<EOF 
run 
{ 
allocate channel c1 type disk; 
SET COMMAND ID TO '1bkp_arch_$SID'; 
backup as compressed backupset archivelog all 
format '$DIR/arch_%d_%s_%p.bkp' 
delete all input; 
release channel c1; 
} 
EOF

rm $LOCK 

echo  $(date  +%d-%m-%Y_%H:%M:%S) - Fim do backup
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Excluindo logs antigos

# Remove arquivos de logs do backup archive com mais de 30 dias de criação 
find $DIR/log -name "log_bkp_arch_*.log" -mtime +29 -exec rm  {} \; 

#remove manualmente backups com mais de D+1
#find $DIR/ -name '*.bkp' -daystart -mtime +1 -exec rm -f '{}' ';'

echo  ----------------------------------------------------
echo  -- Resumo do log da execução --
cat $DIR/log/log_bkp_arch_$SID_$DATA.log
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Fim do procedimento.
echo  ----------------------------------------------------