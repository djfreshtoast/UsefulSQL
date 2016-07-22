SELECT s.name, 
			s.stats_id, 
			s.object_id, 
			STATS_DATE(s.object_id, s.stats_id) AS 'Update Date', 
			o.name AS 'Table'
FROM sys.stats s
INNER JOIN sys.objects o ON o.object_id = s.object_id
WHERE o.name IN ('employee_info')
ORDER BY Stats_Date(s.object_id, s.stats_id) ASC