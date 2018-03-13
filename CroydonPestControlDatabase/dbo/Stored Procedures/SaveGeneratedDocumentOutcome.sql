CREATE PROC [dbo].[SaveGeneratedDocumentOutcome]
	  @InspectionId INT
	, @DocumentPath VARCHAR(1000)
	, @ExportConfigName VARCHAR(100)
	, @IsSuccessful BIT
AS
BEGIN TRY

	DECLARE @ProcessName VARCHAR(255)
		  , @DocumentTypeId INT

    SET @ProcessName = OBJECT_NAME(@@PROCID)
	SET @DocumentTypeId = (SELECT DocumentTypeId FROM [Lookup].DocumentType WHERE ExportConfigName = @ExportConfigName)

	IF EXISTS(SELECT 1 FROM Inspection.Document WHERE InspectionId = @InspectionId AND DocumentPath = @DocumentPath)
		BEGIN
			UPDATE Inspection.Document
			SET Attempt = Attempt + 1
				, LastUpdated = CURRENT_TIMESTAMP
				, IsSuccessful = @IsSuccessful
				, DocumentPath = @DocumentPath
			WHERE InspectionId = @InspectionId AND DocumentPath = @DocumentPath
		END
	ELSE
		BEGIN
			INSERT INTO Inspection.Document(
				InspectionId
				, DocumentTypeId
				, DocumentPath
				, IsSuccessful
			)
			VALUES(
				@InspectionId
				, @DocumentTypeId
				, @DocumentPath
				, @IsSuccessful
			)
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
