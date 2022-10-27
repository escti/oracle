##############################################################################################
# ROTINAS ESCTI (dba@escti.net)
# Backup fisico (RMAN)
59 18  * * * /home/oracle/escti/scripts/rotinas/escti_backup_rman_full.sh SID >> /home/oracle/escti/scripts/rotinas/escti_backup_rman_full.log 2>&1
*/20 * * * * /home/oracle/escti/scripts/rotinas/escti_backup_archive.sh SID >> /home/oracle/escti/scripts/rotinas/escti_backup_archive.log 2>&1

# Backup lógico (DPump)
59 23  * * * /home/oracle/escti/scripts/rotinas/escti_backup_dpump_full.sh SID /dir/local/ >> /home/oracle/escti/scripts/rotinas/escti_backup_dpump_full.log 2>&1

# Manutenção
59 05  * * * /home/oracle/escti/scripts/rotinas/escti_clean_audits.sh SID 30
59 06,11,18,23 * * * /home/oracle/escti/scripts/rotinas/escti_kill_inativas.sh SID
##############################################################################################
