CREATE PROC dbo.GeneratePDFLoop
AS
BEGIN TRY

	DECLARE @Counter INT
			, @MaxCount INT
			, @InspectionId INT
			, @Today VARCHAR(10)
			, @NewFileName VARCHAR(255)
			, @Address VARCHAR(200)
			, @ExportConfigName VARCHAR(100)
			, @DocumentPath VARCHAR(255)
			, @FilePath VARCHAR(255)
			, @TenantFullName NVARCHAR(200)
			, @TenantId INT
			, @TenantEmail VARCHAR(255)
			, @ExecutionId BIGINT
			, @ProcessName VARCHAR(255)

	SET @ProcessName = OBJECT_NAME(@@PROCID)


	IF OBJECT_ID('tempdb..#ids', 'U') IS NOT NULL DROP TABLE #ids

	SELECT ROW_NUMBER() OVER(ORDER BY I.InspectionId) AS RowNo
			, I.InspectionId
			, COALESCE(NULLIF(LTRIM(RTRIM(I.HouseName)), '') + ' ', '') + COALESCE(NULLIF(LTRIM(RTRIM(I.HouseNo)), '') + ' ', '') + COALESCE(NULLIF(LTRIM(RTRIM(I.Street)), ''), '') AS [Address]
			, I.TenantId
			, COALESCE(I.TenantFirstName + ' ', '') + COALESCE(I.TenantLastName, '') AS TenantFullName
			, T.Email
	INTO #ids
	FROM dbo.vwInspections AS I
	LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
	WHERE InspectionId NOT IN (
			SELECT InspectionId
			FROM Inspection.Document
		)
	AND [Status] = 'Complete'


	SET @Counter = 1
	SET @MaxCount = (SELECT COUNT(*) FROM #ids)
	SET @ExportConfigName = 'PestControlGenerateSummaryPDF'
	SET @DocumentPath = (SELECT DestinationPath FROM [Lookup].ExportConfig WHERE ExportConfigName = @ExportConfigName)
	SET @Today = (SELECT CONVERT(VARCHAR, GETDATE(), 112))

	WHILE @Counter <= @MaxCount
		BEGIN

			/**************************************************************
						PRODUCE SUMMARY PDF AND SEND EMAIL :)
			**************************************************************/

			SELECT @FilePath = @DocumentPath + '\' + CAST(InspectionId AS VARCHAR(10)) + '_' + @Today + '_' + [Address] + '_Summary.pdf'
					, @InspectionId = InspectionId
					, @Address = [Address]
					, @TenantFullName = TenantFullName
					, @TenantId = COALESCE(TenantId, 0)
					, @TenantEmail = Email
			FROM #ids
			WHERE RowNo = @Counter
	
	
			IF(COALESCE(@TenantEmail, '') <> '')
				BEGIN
						-- GENERATE PDF AND SEND EMAIL
					EXEC [dbo].[SendEmailInspectionOutcome]
						@InspectionId = @InspectionId
					, @TenantId = @TenantId
					, @ContactName = @TenantFullName
					, @DocumentPath = @DocumentPath
					, @EmailAddress = @TenantEmail
					, @EmailTemplateName = 'InspectionSummary'
					, @ExportConfigName = @ExportConfigName
					, @execution_id = @ExecutionId OUTPUT
				END
			ELSE
				BEGIN
				
					SET @FilePath = CAST(@InspectionId AS VARCHAR(10)) + '_' + @Today + '_' + @Address + '_Summary.pdf'

					-- GENERATE PDF
					EXEC [dbo].[GeneratePDF]
						@InspectionId = @InspectionId
					, @FileName = @Filepath
					, @ExportConfigName = @ExportConfigName
					, @execution_id = @ExecutionId

				END


			/*************************************************************
					LOOP THROUGH AND CHECK IF PACKAGE IS DONE
			*************************************************************/
			DECLARE @Seconds TINYINT
			SET @Seconds = 0

			WHILE 1=1
				BEGIN
				
					IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[executions] WHERE Execution_id = @ExecutionId AND [status] = 2)
						BEGIN
							BREAK
						END

					IF @Seconds > 60
						BEGIN
							EXEC [SSISDB].[catalog].[stop_operation] @ExecutionId
							BREAK
						END


					WAITFOR DELAY '00:00:02'

					SET @Seconds = @Seconds + 2
				END

			PRINT @Filepath + ' File was generated.'

			SET @Counter = @Counter + 1

		END

	IF OBJECT_ID('tempdb..#ids', 'U') IS NOT NULL DROP TABLE #ids
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