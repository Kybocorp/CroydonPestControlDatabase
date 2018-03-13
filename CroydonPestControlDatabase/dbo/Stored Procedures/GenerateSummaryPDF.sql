CREATE PROC [dbo].[GenerateSummaryPDF]
	  @InspectionId INT
	, @FilePath NVARCHAR(1000)
	, @ExportConfigName VARCHAR(100)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
		  , @Folder VARCHAR(100)
		  , @Project VARCHAR(100)
		  , @Package VARCHAR(100)
		  , @ReportServerPath NVARCHAR(1000)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    SELECT @Folder = FolderName
		  , @Project = ProjectName
		  , @Package = PackageName
		  , @ReportServerPath = ReportServerPath
	FROM [Lookup].ExportConfig
    WHERE ExportConfigName = @ExportConfigName

    IF EXISTS (SELECT 1 FROM Inspection.Inspection WHERE InspectionId = @InspectionId)
	   BEGIN

		  DECLARE @execution_id BIGINT
				, @Result INT

		  -- CREATE EXECUTION OF THE SSIS PACKAGE
		  EXEC ssisdb.catalog.create_execution
			 @folder_name = @Folder
			 ,@project_name = @Project
			 ,@package_name = @Package
			 ,@execution_id = @execution_id OUTPUT

		  -- ADD PARAMETERS FOR THE PACKAGE
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'FilePath', @FilePath
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'InspectionId', @InspectionId
		  EXEC ssisdb.catalog.set_execution_parameter_value @execution_id, 30, 'ReportServerPath', @ReportServerPath

		  -- BEGIN EXECUTION
		  EXEC @Result = ssisdb.catalog.start_execution @execution_id


		  -- WAIT FOR 12 SEC WHILST REPORT IS GENERATED
		  WAITFOR DELAY '00:00:12'

		  -- UPDATE THE FILEPATH FOR THE PDF IF REPORT RUN WAS SUCCESSFUL
		  IF (@Result = 0)
		  BEGIN
			
			 INSERT INTO Inspection.Summary(
				  InspectionId
				, SummaryPath
			 )
			 VALUES(
				    @InspectionId
				, @FilePath
			 )

		  END
	
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
