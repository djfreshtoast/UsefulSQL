SELECT * FROM sys.dm_exec_query_memory_grants
SELECT * FROM sys.dm_exec_query_resource_semaphores

SELECT 'Page Life Expectancy (Sec)' AS 'Metric', 
			[cntr_value] AS 'Value'
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%' 
		   AND [counter_name] = 'Page life expectancy'
UNION SELECT '# Blocked Queries' AS 'Metric', 
					  Count(*) AS 'Value'
FROM sys.dm_exec_requests
WHERE blocking_session_id IS NOT NULL 
		   AND sql_handle IS NOT NULL 
		   AND blocking_session_id <> 0