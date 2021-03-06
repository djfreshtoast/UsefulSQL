/****** Object:  StoredProcedure [dbo].[usp_orphaned_user_fix]    Script Date: 12/28/2015 1:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Re-associate orphaned users on instance
--Jeff Van Laethem 12/21/2015

CREATE PROCEDURE [dbo].[usp_orphaned_user_fix](@recreateLogins BIT = 0)
AS
SET NOCOUNT ON
	--drop global temp table if exists
	IF Object_Id('##orphanedUsers') IS NOT NULL 
		BEGIN
			DROP TABLE ##orphanedUsers
		 END

	IF Object_Id('##results') IS NOT NULL 
		BEGIN
			DROP TABLE ##orphanedUsers
		 END

	--create global temp table. It's global so it can be used in different batches throughout the script
	CREATE TABLE ##orphanedUsers(dbName VARCHAR(100), userName VARCHAR(100), userSid VARBINARY(100), userType BIT)

	--For each database, insert the db name, username, and sids that are orphaned into the temp table.
	EXEC sp_msforeachdb 'USE ?
	INSERT INTO ##orphanedUsers
	select ''?'' as ''database'', 
	UserName = a.name, 
	UserSID = a.sid, 
	userType = CASE a.type
		WHEN ''U'' THEN 0
		WHEN ''S'' THEN 1
	END
FROM sys.database_principals a LEFT JOIN sys.server_principals b 
	ON a.sid = b.sid 
	WHERE (a.type = ''S'' OR a.type = ''U'') AND a.name NOT IN (''dbo'', ''guest'', ''INFORMATION_SCHEMA'',''sys'') and b.name IS NULL AND (LEN(a.sid) <=16 OR a.type = ''U'')'

	CREATE TABLE ##results (username VARCHAR(100), usertype VARCHAR(20), dbname VARCHAR(100), actiontaken VARCHAR(1000))

	--DECLARE variables for cursor usage
	DECLARE @db VARCHAR(100), @user VARCHAR(100), @sid VARCHAR(100), @type BIT

	--make cursor
	DECLARE orphanCursor CURSOR FOR
	SELECT dbName, userName, Convert(VARCHAR(100), userSid, 1), userType
	FROM ##orphanedUsers
	OPEN orphanCursor
	FETCH NEXT FROM orphanCursor
	INTO @db, @user, @sid, @type

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--see if login exists already
		DECLARE @currentLogin VARCHAR(100) = NULL
		SELECT @currentLogin = name
		FROM sys.sql_logins
		WHERE name = @user

		DECLARE @sql NVARCHAR(500)

		IF @currentLogin IS NULL AND @type = 1
		BEGIN
			IF @recreateLogins = 1
			BEGIN
				SET @sql = 'CREATE LOGIN [' + @user + '] WITH PASSWORD = ''Temp!2345'', SID = ' + @sid + ', CHECK_EXPIRATION = OFF'
				EXEC(@sql)
				INSERT INTO ##results
				        (username,
				         usertype,
				         dbname,
				         actiontaken)
				VALUES  (@user, -- username - varchar(100)
				         'SQL', -- usertype - varchar(20)
				         @db, -- dbname - varchar(100)
				         'SQL login created with pass = ''Temp!2345'''  -- actiontaken - varchar(1000)
				         )
			END
			ELSE IF @recreateLogins = 0
			BEGIN
				INSERT INTO ##results
				    (username,
				     usertype,
				     dbname,
				     actiontaken)
				VALUES(@user,
							   'SQL',
							   @db,
							   'SQL login not created - @recreateLogins set to 0')
			END
		END
		ELSE IF @type = 0 AND @currentLogin IS NULL AND NOT EXISTS (SELECT loginname FROM master.dbo.syslogins WHERE name = @user)
		BEGIN
			SET @sql = 'CREATE LOGIN [' + @user + '] FROM WINDOWS'
			EXEC(@sql)
				INSERT INTO ##results
				        (username,
				         usertype,
				         dbname,
				         actiontaken)
				VALUES(@user,
							   'Windows',
							   @db,
							   'Login created')
		END
		ELSE IF @currentLogin IS NOT NULL
		BEGIN
			SET @sql = 'USE ' + @db + ' ALTER USER [' + @user + '] WITH LOGIN = [' + @user + ']'
			EXEC(@sql)
				INSERT INTO ##results
				        (username,
				         usertype,
				         dbname,
				         actiontaken)
				VALUES (@user,
								'SQL',
								@db,
								'SQL login existed. Re-associated user.')
		END

		FETCH NEXT FROM orphanCursor
		INTO @db, @user, @sid, @type
	END

	CLOSE orphanCursor;
	DEALLOCATE orphanCursor;

	SELECT username AS 'User',
				  usertype AS 'User Type',
				  dbname AS 'Database',
				  actiontaken AS 'Action Taken'
				   FROM ##results

	DROP TABLE ##orphanedUsers
	DROP TABLE ##results