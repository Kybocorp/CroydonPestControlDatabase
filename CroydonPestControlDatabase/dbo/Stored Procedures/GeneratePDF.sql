CREATE PROC [dbo].[GeneratePDF]
	  @InspectionId INT
	, @FileName NVARCHAR(255)
	, @ExportConfigName NVARCHAR(100)
	, @execution_id BIGINT OUTPUT
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
		  , @Folder VARCHAR(100)
		  , @Project VARCHAR(100)
		  , @Package VARCHAR(100)
		  , @ReportServerPath NVARCHAR(1000)
		  , @FilePath NVARCHAR(1000)
		  , @DestinationPath NVARCHAR(500)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    SELECT @Folder = FolderName
		  , @Project = ProjectName
		  , @Package = PackageName
		  , @ReportServerPath = ReportServerPath
		  , @DestinationPath = DestinationPath
	FROM [Lookup].ExportConfig
    WHERE ExportConfigName = @ExportConfigName

	SET @FilePath = @DestinationPath + '\' + @FileName

    IF EXISTS (SELECT 1 FROM Inspection.Inspection WHERE InspectionId = @InspectionId)
	   BEGIN

		  DECLARE @Result INT

		  -- CREATE EXECUTION OF THE SSIS PACKAGE
		  EXEC ssisdb.catalog.create_execution
			 @folder_name = @Folder
			 ,@project_name = @Project
			 ,@package_name = @Package
			 ,@execution_id = @execution_id OUTPUT

		  -- ADD PARAMETERS FOR THE PACKAGE
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'FilePath', @FilePath
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'DestinationPath', @DestinationPath
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'InspectionId', @InspectionId
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'ReportServerPath', @ReportServerPath
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'ExportConfigName', @ExportConfigName

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
