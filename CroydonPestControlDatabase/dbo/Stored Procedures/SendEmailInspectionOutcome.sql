CREATE PROC [dbo].[SendEmailInspectionOutcome]
	  @InspectionId INT
	, @TenantId INT
	, @ContactName NVARCHAR(100)
	, @DocumentPath NVARCHAR(1000)
	, @EmailAddress NVARCHAR(255)
	, @EmailTemplateName NVARCHAR(100)
	, @ExportConfigName NVARCHAR(100)
	, @execution_id BIGINT OUTPUT
AS
BEGIN TRY

	/**************************************
			LOG DETAILS RECEIVED
    **************************************/
	INSERT INTO [Log].[SendEmailInspectionOutcome](
		  InspectionId
		, TenantId
		, ContactName
		, DocumentPath
		, EmailAddress
		, EmailTemplateName
		, ExportConfigName
		)
	VALUES(
		  @InspectionId
		, @TenantId
		, @ContactName
		, @DocumentPath
		, @EmailAddress
		, @EmailTemplateName
		, @ExportConfigName
	)


	/***************************************************
			BEGIN PREPARING SSIS PACKAGE EXECUTION
    ***************************************************/

    DECLARE @ProcessName VARCHAR(255)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    IF EXISTS (SELECT 1 FROM Inspection.Inspection WHERE InspectionId = @InspectionId)
	   BEGIN

		  DECLARE @Result INT

		  -- CREATE EXECUTION OF THE SSIS PACKAGE
		  EXEC ssisdb.catalog.create_execution
			 @folder_name = 'PestControl'
			 ,@project_name = 'PestControlExports'
			 ,@package_name = 'SendEmailInspectionOutcome.dtsx'
			 ,@execution_id = @execution_id OUTPUT

		  -- ADD PARAMETERS FOR THE PACKAGE
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'ContactName', @ContactName
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'DocumentPath', @DocumentPath
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'EmailAddress', @EmailAddress
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'EmailTemplateName', @EmailTemplateName
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'ExportConfigName', @ExportConfigName
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'InspectionId', @InspectionId
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'TenantId', @TenantId

		  -- BEGIN EXECUTION
		  EXEC @Result = ssisdb.catalog.start_execution @execution_id

	   END

END TRY
BEGIN CATCH

    -- ROLLBACK TRANSACTION
	   IF @@TRANCOUNT > 0 ROLLBACK TRAN

    -- DECLARE AND SET VARIABLES
	   DECLARE @ErrorMessage VARCHAR(2000)
		  , @ErrorSeverity TINYINT
		  , @ErrorState TINYINT
		  , @ErrorLine INT

	   SET @ErrorMessage  = ERROR_MESSAGE()
	   SET @ErrorSeverity = ERROR_SEVERITY()
	   SET @ErrorState    = ERROR_STATE()
	   SET @ErrorLine	  = ERROR_LINE()

    -- LOG ERROR
	   EXEC [Log].LogEvent 
		    @ProcessName = @ProcessName
		  , @InspectionId = @InspectionId
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH
