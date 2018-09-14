-- -----------------------------------------------------------------------------------
-- File Name    : cap_col_histogram.sql
-- Author       : Bowen Zhuang
-- Description  : captrue column with index which need collecton histogram
-- Requirements : 1. Access to the DBA views.
--                2. dependent on statistical information
-- Call Syntax  : @cap_col_histogram.sql SCOTT
-- Last Modified: 09/12/2018
-- -----------------------------------------------------------------------------------

set verify off
set linesize 1000
set pagesize 1000
col owner format a30
col table_name format a30
col column_name format a30
col index_full_name format a42
col histogram format a20
col last_analyzed format a22

define OWNER_NAME=&1

SELECT a.owner,
  a.table_name,
  a.column_name,
  c.index_owner||'.'||c.index_name as index_full_name,
  b.num_rows,
  a.histogram,
  a.num_distinct cardinality,
  TO_CHAR(a.last_analyzed,'YYYY-MM-DD HH24:MI:SS') AS last_analyzed,
  ROUND(a.num_distinct/b.num_rows *100,2) selectivity
FROM dba_tab_col_statistics a,
  dba_tables b,
  dba_ind_columns c
WHERE a.owner                               = b.owner
AND a.table_name                            = b.table_name
AND a.owner                                 =upper('&OWNER_NAME')
AND a.owner                                 = c.table_owner
AND a.table_name                            = c.table_name
AND a.column_name                           = c.column_name
AND ROUND(a.num_distinct/b.num_rows *100,2) <5
AND b.num_rows                              >5000
ORDER BY owner,
  table_name,
  column_name,
  selectivity;
