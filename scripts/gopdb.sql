set lines 150 pages 2000
col host_name for a20
col instance_name for a15
col startup_time for a18
col user for a5
col current_schema for a15
col version for a10
col status for a10
col pdb_name for a15

SELECT pdb_id,
       pdb_name
FROM dba_pdbs
ORDER BY 1;


ALTER SESSION
SET container=&pdbname;


SELECT decode(instr(host_name, '.'), 0, host_name, substr(host_name, 1, instr(host_name, '.')-1)) host_name,
       instance_name as inst_name,
	   p.PDB_NAME,
       USER,
       sys_context('userenv', 'current_schema') current_schema,
       i.status,
       to_char(startup_time, 'dd/mm/yy hh24:mi:ss') startup_time,
       VERSION,
       logins,
       d.open_mode
FROM v$instance i,
     v$database d,
	 dba_pdbs p
	 ;
