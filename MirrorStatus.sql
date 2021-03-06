DECLARE @MirroringRole VARCHAR(25);
SET @MirroringRole = CASE WHEN (SELECT mirroring_role
    FROM sys.database_mirroring
    WHERE DB_NAME(database_id) = N'Ontrak_DPI') =  1 THEN 'PRIMARY'
	WHEN (SELECT mirroring_role
    FROM sys.database_mirroring
    WHERE DB_NAME(database_id) = N'Ontrak_DPI') =  2 THEN 'SECONDARY'
	ELSE 'NOT MIRRORED'
	END

IF @MirroringRole = 'PRIMARY'
	BEGIN
		SELECT [agent_job_name]
			,[agent_job_while_primary]
			,[agent_job_while_secondary]
			,[agent_job_id]
		FROM [dba_admin].[dbo].[agent_job_exceptions]
		FULL OUTER JOIN msdb.dbo.sysjobs ON msdb.dbo.sysjobs.job_id = dba_admin.dbo.agent_job_exceptions.agent_job_id
		WHERE dba_admin.dbo.agent_job_exceptions.agent_job_while_primary <> msdb.dbo.sysjobs.[enabled]
	END
ELSE IF @MirroringRole = 'SECONDARY'
	BEGIN
			SELECT [agent_job_name]
			,[agent_job_while_primary]
			,[agent_job_while_secondary]
			,[agent_job_id]
		FROM [dba_admin].[dbo].[agent_job_exceptions]
		FULL OUTER JOIN msdb.dbo.sysjobs ON msdb.dbo.sysjobs.job_id = dba_admin.dbo.agent_job_exceptions.agent_job_id
		WHERE dba_admin.dbo.agent_job_exceptions.agent_job_while_secondary <> msdb.dbo.sysjobs.[enabled]
	END