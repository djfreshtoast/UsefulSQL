SELECT partition_id, 
	   b.object_id, 
	   b.index_id, 
	   partition_number, 
	   hobt_id, 
	   rows, 
	   filestream_filegroup_id, 
	   data_compression_desc, 
	   b.name as 'Index Name', 
	   b.type_desc as 'Index Type', 
	   is_unique, 
	   o.name as 'Table Name',
	   o.type_desc as 'Table Type'
FROM sys.partitions a
INNER Join sys.indexes b ON b.object_id = a.object_id 
							AND b.index_id = a.index_id
LEFT JOIN sys.objects o ON o.object_id = b.object_id
WHERE a.data_compression > 0