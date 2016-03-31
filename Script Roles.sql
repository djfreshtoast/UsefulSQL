SELECT 
state_desc + ' ' + pm.permission_name + ' ON [' + Isnull(ss.name COLLATE SQL_Latin1_General_CP1_CI_AS, Object_name(pm.major_id)) + '] TO [' + rp.name + ']'
FROM   sys.database_principals rp 
       INNER JOIN sys.database_permissions pm 
               ON pm.grantee_principal_id = rp.principal_id 
       LEFT JOIN sys.schemas ss 
              ON pm.major_id = ss.schema_id 
       LEFT JOIN sys.objects obj 
              ON pm.[major_id] = obj.[object_id] 
WHERE  rp.type_desc = 'DATABASE_ROLE' 
       AND pm.class_desc <> 'DATABASE' 
	   AND rp.name NOT LIKE 'db_%'
ORDER  BY rp.name, 
          rp.type_desc, 
          pm.class_desc 	