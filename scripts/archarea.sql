set lines 150 pages 2000
col name for a45
col space_limit 999999999.99

SELECT name,
       To_char(space_limit, '999,999,999,999')
       AS SPACE_LIMIT,
       To_char(space_limit - space_used + space_reclaimable, '999,999,999,999')
       AS
       SPACE_AVAILABLE,
       Round(( space_used - space_reclaimable ) / space_limit * 100, 1)
       AS PERCENT_FULL
FROM   v$recovery_file_dest; 
