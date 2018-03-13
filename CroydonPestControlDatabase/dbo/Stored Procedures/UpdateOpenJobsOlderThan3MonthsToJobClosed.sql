CREATE PROC [dbo].[UpdateOpenJobsOlderThan3MonthsToJobClosed]
AS
BEGIN TRY

    BEGIN TRAN

		UPDATE Inspection.Inspection
		SET JobClosed = 1
			, JobClosedDate = CURRENT_TIMESTAMP
			, LastUpdated = CURRENT_TIMESTAMP
		WHERE InspectionId IN (
				SELECT MAX(InspectionId)
				FROM Inspection.Inspection
				WHERE StatusId <> 1
				GROUP BY PropertyId
			)
		AND COALESCE(JobClosed, 0) = 0
		AND DATEDIFF(DD, InspectionDate, CURRENT_TIMESTAMP) > 90
	
	COMMIT TRAN
    
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