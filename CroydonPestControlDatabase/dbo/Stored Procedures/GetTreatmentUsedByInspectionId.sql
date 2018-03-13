

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[GetTreatmentUsedByInspectionId](
      @InspectionId INT
)
AS
BEGIN TRY

    SELECT T.TreatmentDesc AS Treatment
		  , T.ActiveIngredient
		  , T.RegistrationNo
    FROM Inspection.TreatmentUsed AS TU
    LEFT OUTER JOIN [Lookup].Treatment AS T ON TU.TreatmentId = T.TreatmentId
    WHERE TU.PestTreatmentId IN (SELECT PestTreatmentId FROM Inspection.PestTreatment WHERE InspectionId = @InspectionId)
    ORDER BY T.TreatmentDesc

END TRY
BEGIN CATCH

    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

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
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH
