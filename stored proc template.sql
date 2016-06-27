
IF NOT EXISTS ( SELECT	*
				FROM	sys.schemas
				WHERE	[name] = 'administration' )
	BEGIN
		EXECUTE('CREATE SCHEMA [administration] AUTHORIZATION [dbo]')
	END
GO

/*###########################################################################################*/
IF NOT EXISTS ( SELECT	*
				FROM	sys.tables
				WHERE	[name] = 'error_log'
						AND [schema_id] = ( SELECT	[schema_id]
											FROM	sys.[schemas]
											WHERE	[name] = 'administration'
										  ) )
	BEGIN
		CREATE TABLE [administration].[error_log]
			(
			  [error_log_id] [INT] IDENTITY(1, 1)
								   NOT NULL ,
			  [error_date] [DATETIME] NOT NULL ,
			  [database_name] [NVARCHAR](128) NOT NULL ,
			  [error_number] [INT] NULL ,
			  [error_severity] [INT] NULL ,
			  [error_state] [INT] NULL ,
			  [error_procedure] [NVARCHAR](126) NULL ,
			  [error_line] [INT] NULL ,
			  [error_message] [NVARCHAR](4000) NULL ,
			  CONSTRAINT [PK_error_log_error_log_id] PRIMARY KEY CLUSTERED
				( [error_log_id] ASC )
				WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
					   IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
					   ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
			)
		ON	[PRIMARY]
	END
GO

/*###########################################################################################*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create procedure to retrieve error information.
CREATE PROCEDURE [administration].[usp_get_error_info]
	(
	  @database_name NVARCHAR(128) ,
	  @stored_procedure NVARCHAR(255) ,
	  @error NVARCHAR(4000)
	)
AS
	SET NOCOUNT ON

	INSERT	INTO administration.error_log
			( error_date ,
			  database_name ,
			  error_number ,
			  error_severity ,
			  error_state ,
			  error_procedure ,
			  error_line ,
			  error_message )
			SELECT	GETDATE() AS error_date ,
					@database_name ,
					ERROR_NUMBER() AS ErrorNumber ,
					ERROR_SEVERITY() AS ErrorSeverity ,
					ERROR_STATE() AS ErrorState ,
					@stored_procedure AS ErrorProcedure ,
					ERROR_LINE() AS ErrorLine ,
					@error AS ErrorMessage;
GO
/*###########################################################################################*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_name_here] 

AS 
BEGIN
SET NOCOUNT ON;

DECLARE @error_message NVARCHAR(4000);

----------------------------------------------------------------
BEGIN TRY
	
	-- put code here

END TRY
----------------------------------------------------------------
BEGIN CATCH
   	DECLARE @database_name NVARCHAR(128), @stored_procedure NVARCHAR(128), @error NVARCHAR(4000);
	SELECT @database_name = db_name(), @stored_procedure = ERROR_PROCEDURE(), @error = ERROR_MESSAGE();

    EXECUTE [administration].[usp_get_error_info] @database_name, @stored_procedure, @error;

	IF (@error_message IS NULL)
		SET @error_message = @error;
	
	THROW 51000, @error_message, 1;	
END CATCH
----------------------------------------------------------------
END
GO