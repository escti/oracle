-- -----------------------------------------------------------------------------------
-- File Name    : inst.sql
-- Author       : Thiago Escodino (thiago@escti.net)
-- Description  : Lista informações sobre a instancia conectada.
-- Call Syntax  : @inst.sql
-- Last Modified: 07/07/2022
-- -----------------------------------------------------------------------------------

set lines 150 pages 2000
col host_name for a20
col instance_name for a15
col startup_time for a18
col user for a12
col current_schema for a15
col version for a10
col status for a10

select 
	decode(instr(host_name,'.'),0,host_name,substr(host_name,1,instr(host_name,'.')-1)) host_name,
	instance_name,
	user,
	sys_context('userenv', 'current_schema') current_schema,
	i.status,
	to_char(startup_time, 'dd/mm/yy hh24:mi:ss') startup_time,
	version, 
	logins, 
	d.open_mode
from 
	v$instance i, 
	v$database d;

col host_name clear
col instance_name clear
col startup_time clear
col user clear
col current_schema clear
col version clear
col status clear
