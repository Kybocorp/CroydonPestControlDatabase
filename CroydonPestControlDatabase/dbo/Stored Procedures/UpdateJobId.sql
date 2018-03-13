CREATE PROC [dbo].[UpdateJobId]
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

	IF OBJECT_ID('tempdb..#Latest', 'U') IS NOT NULL DROP TABLE #Latest
	SELECT PropertyId
			, JobClosed
			, JobId
			, ROW_NUMBER() OVER(PARTITION BY PropertyId ORDER BY InspectionDate DESC) AS RowNo
	INTO #Latest
	FROM Inspection.Inspection
	WHERE PropertyId IN (
			SELECT PropertyId
			FROM Inspection.Inspection
			WHERE JobId = 0
		)

	DELETE FROM #Latest WHERE RowNo > 1

	UPDATE I
	SET I.JobId = COALESCE(CASE
					WHEN L.JobClosed = 1 THEN L.JobId + 1
					ELSE L.JobId
				END, 0)
	FROM Inspection.Inspection AS I
	INNER JOIN #Latest AS L ON I.PropertyId = L.PropertyId
	WHERE I.JobId = 0

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
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH