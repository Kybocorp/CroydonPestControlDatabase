CREATE PROC dbo.KillRunningPackages
AS
BEGIN TRY
	DECLARE @ProcessName VARCHAR(255)
	SET @ProcessName = OBJECT_NAME(@@PROCID)

	IF OBJECT_ID('tempdb..#Kill', 'U') IS NOT NULL DROP TABLE #Kill

	SELECT ROW_NUMBER() OVER(ORDER BY execution_id) AS RowNo
			, execution_id
	INTO #Kill
	FROM [SSISDB].[catalog].[executions]
	WHERE [folder_name] = 'PestControl'
	AND [status] = 2
	AND end_time IS NULL
	AND DATEDIFF(MINUTE, start_time, CURRENT_TIMESTAMP) > 30

	DECLARE @Counter INT
			, @MaxCount INT
			, @ExecutionId INT

	SET @Counter = 1
	SET @MaxCount = (SELECT COUNT(*) FROM #Kill)

	WHILE @Counter <= @MaxCount
		BEGIN

			SET @ExecutionId = (SELECT execution_id FROM #Kill WHERE RowNo = @Counter)

			EXEC [SSISDB].[catalog].[stop_operation] @ExecutionId

			PRINT CAST(@Counter AS VARCHAR(10)) + ') Killed Execution ' + CAST(@ExecutionId AS VARCHAR(10))

			SET @Counter = @Counter + 1

		END

	IF OBJECT_ID('tempdb..#Kill', 'U') IS NOT NULL DROP TABLE #Kill
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