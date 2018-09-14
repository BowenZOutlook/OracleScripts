-- -----------------------------------------------------------------------------------
-- File Name    : active_session_stats.sql
-- Author       : Bowen Zhuang
-- Description  : Display active session and blocked session and blocked objects
-- Requirements : Access to the gV$ and DBA views.
-- Call Syntax  : @active_session_stats.sql
-- Last Modified: 02/02/2018
-- -----------------------------------------------------------------------------------

SET LINESIZE 550
SET PAGESIZE 1000

column Blocking_Instance_type format A23
COLUMN username FORMAT A30
COLUMN blocking_username FORMAT A30
COLUMN osuser FORMAT A20
COLUMN spid FORMAT A10
COLUMN service_name FORMAT A15
COLUMN module FORMAT A45
COLUMN machine FORMAT A30
COLUMN logon_time FORMAT A20
column Lock_Table format A30
column Lock_Rowid format A18
column EVENT format A30

SELECT /*+ rule */
       s.inst_id,
       case when s.final_blocking_session is not null and s.final_blocking_instance=s.inst_id  then
           'Same Instance Blocking'
           when  s.final_blocking_session is not null and s.final_blocking_instance<>s.inst_id then
           'Diff Instanace Blocking'
       end Blocking_Instance_type,
       s.username,
       s.osuser,
       s.final_blocking_instance as blocking_inst_id,
       s.final_blocking_session as blocking_sid,
       s.sid,
       s.serial#,
       p.spid,
       s.lockwait,
       s.status,
       s.sql_id,
       s.prev_sql_id,
       s.module,
       s.machine,
       s.program,
       s.event,
       Case
         When s.final_blocking_session Is Not Null Then
          (Select Object_Name
             From Dba_Objects
            Where Object_Id = s.Row_Wait_Obj#)
       End Lock_Table,
       Case
         When s.final_blocking_session Is Not Null And
              s.Event = 'enq: TX - row lock contention' Then
          Dbms_Rowid.Rowid_Create(1,
                                  s.Row_Wait_Obj#,
                                  s.Row_Wait_File#,
                                  s.Row_Wait_Block#,
                                  s.Row_Wait_Row#)
       End Lock_Rowid,
       ss.username as blocking_username,
       ss.status as blocking_status,
       TO_CHAR(s.logon_Time,'YYYY-MM-DD HH24:MI:SS') AS logon_time,
       s.last_call_et AS last_call_et_secs
FROM   gv$session s,
       gv$process p,
       gv$session ss
WHERE  s.paddr  = p.addr
AND    s.status = 'ACTIVE'
and    s.username is not null
and    s.inst_id = p.inst_id
and    ss.inst_id(+) = s.final_blocking_instance
and    ss.sid(+) = s.final_blocking_session
ORDER BY s.username, s.osuser;
