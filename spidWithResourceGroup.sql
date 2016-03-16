select r.session_id, 
		   Convert(NCHAR(20), wg.name) as group_name, 
		   t.scheduler_id,r.status
FROM sys.dm_exec_requests r 
JOIN sys.dm_os_tasks t on r.task_address = t.task_address
JOIN sys.dm_resource_governor_workload_groups wg on r.group_id = wg.group_id
WHERE r.session_id > 50 --and Convert(NCHAR(20), wg.name) NOT IN ('default', 'internal')