-- -----------------------------------------------------------------------------------
-- File Name    : get_fk_noindex.sql
-- Author       : Bowen Zhuang
-- Description  : get not create indexes for FK
-- Requirements : Access to the DBA views.
-- Call Syntax  : @get_fk_noindex.sql SCOTT
-- Last Modified: 09/12/2018
-- -----------------------------------------------------------------------------------

set verify off
set linesize 1000
set pagesize 1000
col owner format a30
col table_name format a30
col constraint_name format a30
col column_name format a30

define OWNER_NAME=&1

WITH cons AS
  (SELECT owner,
    table_name,
    constraint_name
  FROM dba_constraints
  WHERE owner         =upper('&OWNER_NAME')
  AND constraint_type ='R'),
  idx AS
  (SELECT table_owner,
    table_name,
    column_name
  FROM dba_ind_columns
  WHERE table_owner=upper('&OWNER_NAME'))
SELECT dba_cons_columns.owner,
  dba_cons_columns.table_name,
  dba_cons_columns.constraint_name,
  dba_cons_columns.column_name
FROM dba_cons_columns
WHERE (owner,table_name,constraint_name) IN
  (SELECT * FROM cons)
AND (owner,table_name,column_name) NOT IN
  (SELECT * FROM idx);
