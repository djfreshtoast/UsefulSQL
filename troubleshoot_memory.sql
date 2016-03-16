EXEC sp_whoisactive

SELECT * FROM sys.dm_exec_query_memory_grants
SELECT * FROM sys.dm_exec_query_resource_semaphores

SELECT 'Page Life Expectancy' AS 'Metric', [cntr_value] AS 'Value', 'If this value is below ~500 and not growing, there may be memory issues on the server. This value indicates the average length in seconds that a page remains in the buffer pool. The longer the better.' AS 'Description'
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%' AND [counter_name] = 'Page life expectancy'
UNION SELECT
'# Blocked Queries' AS 'Metric', Count(*) AS 'Value', 'Any non-0 # here is a bad thing. This is the number of queries that are currently blocked by another query. Run EXEC sp_whoisactive.' AS 'Description' 
FROM sys.dm_exec_requests
WHERE blocking_session_id IS NOT NULL AND sql_handle IS NOT NULL AND blocking_session_id <> 0