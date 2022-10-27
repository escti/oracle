#!/bin/bash 
## Script: escti_backup_dpump_full.sh 
## Versão: 1.8 
## Proposito: Fazer backup full via DataPump com compactação
## Autor: Thiago Escodino de Albuquerque (dba@escti.net) 
## Data última modificação: 18/05/2022

# Variaveis de ambiente e banco

. ~/.bash_profile 
echo  ------------------------------------------------------
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Iniciando procedimento:

export ORAENV_ASK=NO 
SID=${1} 
DIR=${2} 
RETENCAO=0 
PARALELISMO_COMPACTACAO=4 
EXTERNO='/mnt/bkp_dpump' 

export ORACLE_SID="$SID" 
. oraenv 

DATA=`date --date="0 days ago" +%Y%m%d%H%M%S` 
DATA_LOG=`date  +%d-%m-%Y_%H:%M:%S` 

# Variaveis do email
# REMETENTE=servidor@cliente.com.br
# DESTINATARIO=dba@escti.net, email@cliente.com.br
# SERVIDORSMTP=10.178.1.141
# ASSUNTO='[CLIENTE] - Backup DataPump servidor/instancia $ESTADO'
# TEXTO='O resultado do backup do banco xxxx no servidor xxx de IP xx.xx.xx.xx foi: $ESTADO. Detalhes da execução em anexo'
# ANEXO=/u01/app/odaorahome/backup/dpump/nexa_dpump.log

# Lock no arquivo para impedir execucao dupla 
LOCK=$DIR/.backup_dpump_$SID.lck 
if [ -f $LOCK ]; then 
echo  $(date  +%d-%m-%Y_%H:%M:%S) - procedimento já está em execução. Saindo...

    exit 1 

fi 

touch $LOCK 

echo  $(date  +%d-%m-%Y_%H:%M:%S) - apagando arquivos antigos:

#REMOVE ARQUIVOS DE ACORDO COM A DATA DE RETENCAO 
find ${DIR} -name '*.tar.gz' -mtime +$RETENCAO -exec rm -rf {} \; 
find ${DIR} -name '*.log' -mtime +6 -exec rm {} \; 

echo  $(date  +%d-%m-%Y_%H:%M:%S) - iniciando backup dpump:

mkdir -p $DIR/$DATA; 

sqlplus -s "/ as sysdba" <<-EOF 
create pfile='$DIR/$DATA/PF.ora' from memory;
create spfile from memory;
ALTER DATABASE BACKUP CONTROLFILE TO '$DIR/$DATA/CF.bkp';
ALTER DATABASE BACKUP CONTROLFILE TO TRACE;
create or replace directory DPUMP_DIR as '$DIR/';
exit 
EOF

# CHECK SCN 
ATUAL_SCN=$(sqlplus -s "/ as sysdba" <<-EOF 
SET FEEDBACK OFF HEADING OFF PAGESIZE 0 VERIFY OFF ECHO OFF 
col CURRENT_SCN for 9999999999999999999999999999 
select current_scn from v\$database; 
exit 
EOF 
) 

# #11g
# $ORACLE_HOME/bin/expdp "'/ as sysdba'" DIRECTORY=DPUMP_DIR DUMPFILE=expdp_"$SID"_%U.dmp FLASHBACK_SCN="${ATUAL_SCN//[!0-9]/}" FULL=Y FILESIZE=5g LOGFILE=expdp_"$SID"_"$DATA".log EXCLUDE=statistics,schema:\"in \(\'PERFSTAT\'\)\" METRICS=YES


#12g+
$ORACLE_HOME/bin/expdp "'/ as sysdba'" DIRECTORY=DPUMP_DIR DUMPFILE=expdp_"$SID"_%U.dmp FLASHBACK_SCN="${ATUAL_SCN//[!0-9]/}" FULL=Y FILESIZE=5g LOGFILE=expdp_"$SID"_"$DATA".log EXCLUDE=statistics,schema:\"in \(\'PERFSTAT\'\)\" LOGTIME=ALL METRICS=YES
STATUS_DPUMP=$? 

DATA_FIM_EXPORT=`date +%s` 

mv $DIR/expdp*.dmp $DIR/$DATA 

cp $DIR/expdp_"$SID"_"$DATA".log $DIR/$DATA 

#COLETA TAMANHO DO BACKUP 
SIZE=$(du -b  $DIR/$DATA | awk '{ print $1}') 

case $STATUS_DPUMP in 
  0) echo "EX_SUCC $STATUS_DPUMP" 
     ESTADO="SUCESSO" 
     ;; 
  5) echo "EX_SUCC_ERR" 
     ESTADO="INCOMPLETO" 
     ;; 
  1) echo "EX_FAIL" 
     ESTADO="FALHA" 
     ;; 
  *) echo "INVALID NUMBER!" 
 ESTADO="FALHA" 
     ;; 
esac 

echo  $(date  +%d-%m-%Y_%H:%M:%S) - Resultado do Backup é: $ESTADO.
#MODIFICA O NOME DO LOG em caso de erro 
if [[ $STATUS_DPUMP != 0 ]] ; then 
  mv ${DIR}/expdp_"${SID}"_"${DATA}".log ${DIR}/expdp_"${SID}"_"${DATA}"_falhou.log 
fi 

echo  $(date  +%d-%m-%Y_%H:%M:%S) - compactando arquivos:

#COMPACTA BACKUPS 
tar -czvf $DIR/"$SID"_"$DATA".tar.gz $DIR/$DATA/* --remove-files 

#tar cf - $DIR/$DATA/expdp*.dmp $DIR/$DATA/expdp*.log --remove-files | pigz -7 -p $PARALELISMO_COMPACTACAO > $DIR/"$SID"_"$DATA".tar.gz 

rm -rf ${DIR}/${DATA}; 

DATA_FIM_COMPACTACAO=`date +%s` 
SIZE_COMPACTADO=0 
SIZE_COMPACTADO=$(du -b  ${DIR}/"${SID}"_"${DATA}".tar.gz | awk '{ print $1}') 

rm $LOCK 

#echo  $(date  +%d-%m-%Y_%H:%M:%S) - enviando para o monitoramento:

#linha_E=`tail -n 1 ${DIR}/expdp_"$ORACLE_SID"_"$DATA"*.log`
#PROD=`sqlplus -s / as sysdba <<EOF
#    SET heading OFF feedback off serveroutput on;
#INSERT INTO "ESCTI"."RELATORIO_EXP" (DATA_CAPTURA,INFO,FILE_NAME,SIZE_COMPACTADO) VALUES (SYSDATE,'$linha_E','$arquivolog',SIZE_COMPACTADO);
#COMMIT;
#EOF`

#echo  $(date  +%d-%m-%Y_%H:%M:%S) - copiando para disco externo.
#Copia e retencao externa 
#/usr/bin/rsync -avugop --append ${DIR}/"${SID}"_"${DATA}".tar.gz ${DIR}/expdp_"${SID}"_"${DATA}".log ${EXTERNO}/${SID}/ 
#find ${EXTERNO}/${SID} -name '*.tar.gz' -daystart -mtime +$RETENCAO -delete; 
#find ${EXTERNO}/${SID} -name 'expdp*.log' -daystart -mtime +$RETENCAO -delete; 

#ENVIA EMAIL EM CASO DE ERRO 
#if [[ $STATUS_DPUMP != 0 ]] ; then

#/home/oracle/nexa/scripts/rotinas/sendEmail -f $REMETENTE -t $DESTINATARIO -s $SERVIDORSMTP -u "$ASSUNTO" -m "$TEXTO" -a $ANEXO

#fi 
echo  $(date  +%d-%m-%Y_%H:%M:%S) - Fim do procedimento.
echo  ----------------------------------------------------

