USE [SSDB]
GO

SELECT s.name + '.' + o.name AS 'Table',
			  i.name AS 'Index Name',
			  i.type_desc AS 'Index Type',
			  ius.user_seeks,
			  ius.user_scans,
			  ius.user_lookups,
			  ius.user_updates,
			  ius.last_user_seek,
			  ius.last_user_scan,
			  ius.last_user_lookup,
			  ius.last_user_update,
			  z.index_depth,
			  z.avg_fragmentation_in_percent,
			  z.fragment_count,
			  z.avg_fragment_size_in_pages,
			  z.page_count,
			  z.avg_page_space_used_in_percent,
			  z.record_count,
			  z.min_record_size_in_bytes,
			  z.max_record_size_in_bytes,
			  z.avg_record_size_in_bytes,
			  z.compressed_page_count
FROM sys.dm_db_index_physical_stats(Db_Id(), NULL, NULL, NULL, 'SAMPLED') z
Left JOIN sys.indexes i ON i.index_id = z.index_id AND i.object_id = z.object_id
LEFT JOIN sys.objects o ON o.object_id = i.object_id
LEFT JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.dm_db_index_usage_stats ius ON ius.index_id = i.index_id AND ius.object_id = o.object_id
WHERE ius.database_id = DB_Id() AND i.type_desc <> 'HEAP'
ORDER BY avg_fragmentation_in_percent DESC