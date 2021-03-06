/*
		Returns all users in the db_owner, db_datawriter, and db_ddladmin, and db_securityadmin roles for each DB, as well as users with SA on the server
*/

USE tempdb
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = '##perms')
BEGIN
	DROP TABLE ##perms
END

CREATE TABLE ##perms([Server] VARCHAR(100),
											[Database] VARCHAR(100),
											[Role] VARCHAR(100),
											[User] VARCHAR(100))

EXEC sp_msforeachdb 'USE [?] INSERT INTO ##perms SELECT @@SERVERNAME AS ''Server'', ''?'' AS ''Database'', DPR.name AS ''Role'', DPU.name AS ''User'' FROM sys.database_role_members RM
LEFT JOIN sys.database_principals DPR ON DPR.principal_id = RM.role_principal_id
LEFT JOIN sys.database_principals DPU ON DPU.principal_id = RM.member_principal_id
WHERE DPR.name IN (
''db_owner'',
''db_datawriter'',
''db_ddladmin'',
''db_securityadmin''
)'

INSERT INTO ##perms
SELECT @@SERVERNAME AS 'Server', 'Server-Level' AS 'Database', 'SA' AS 'Role',p.name AS [User]
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        AND p.name NOT LIKE '##%'
        AND s.sysadmin = 1
		AND p.is_disabled = 0

SELECT * FROM ##perms

SELECT databases.name AS 'Database', sql_logins.name AS 'Owner' FROM sys.databases
LEFT JOIN sys.sql_logins ON owner_sid = sid