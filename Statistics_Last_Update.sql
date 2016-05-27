SELECT s.name, s.stats_id, s.object_id, STATS_DATE(s.object_id, s.stats_id) AS 'Update Date', o.name AS 'Table'
FROM sys.stats s
INNER JOIN sys.objects o ON o.object_id = s.object_id
WHERE o.name IN ('MER_Terminal', 'MER_DBA', 'MER_CARD', 'GEN_ASSOCIATION', 'GEN_APPLICATION_ATTRIBUTE', 'GEN_STW_NAME', 'MER_EQUIPMENT_DETAIL')
ORDER BY o.name ASC, s.stats_id ASC