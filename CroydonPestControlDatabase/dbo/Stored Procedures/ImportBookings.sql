
CREATE PROC [dbo].[ImportBookings]
AS
BEGIN TRY

	BEGIN TRAN

    DECLARE @ProcessName VARCHAR(255)
			, @LastRunTime DATETIME
			, @CurrentRunTime DATETIME
			, @SyncConfigName VARCHAR(100)

	SET @SyncConfigName = 'Bookings_Update'
    SET @ProcessName = OBJECT_NAME(@@PROCID)
	SET @LastRunTime = (SELECT lastRunTime FROM dbo.syncConfig WHERE configName = @SyncConfigName)
	SET @CurrentRunTime = (SELECT CURRENT_TIMESTAMP)

	DECLARE @NewInspections TABLE(
		  InspectionId INT
		, AltInspectionId INT
	)


	-- DROP TEMP TABLE IF EXISTS
	IF OBJECT_ID('tempdb..#bookings', 'U') IS NOT NULL DROP TABLE #bookings


	-- GET LATEST BOOKINGS
	SELECT    [UID] AS AltInspectionId
			, Sheet AS DiaryId
			, VisitDate AS InspectionDate
			, LEFT(AMPM, 2) AS AMPM
			, UPRN
			, COALESCE(Pest + '.', '') + COALESCE(' ' + Comments, '') AS FollowUpNote
			, Telephone
			, Prop_UID AS PropertyId
			, LastUpdated
			, InspectionId
	INTO #bookings
	FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
	WHERE Allocated = 'Y'
	AND lastUpdated > @LastRunTime


	IF (SELECT COUNT(*) FROM #bookings) > 0
	BEGIN
		-- UPDATE EXISTING BOOKINGS
		UPDATE I
		SET I.InspectionDate = B.InspectionDate
			, I.AMPM = B.AMPM
			, I.PropertyId = B.PropertyId
			, I.DiaryId = B.DiaryId
			, I.FollowUpNotes = B.FollowUpNote
			, I.LastUpdated = B.LastUpdated
			, I.Telephone = B.Telephone
		FROM Inspection.Inspection AS I
		INNER JOIN #bookings AS B ON I.InspectionId = B.InspectionId AND I.StatusId = 1


		-- INSERT NEW BOOKINGS
		INSERT INTO [Inspection].[Inspection](
				  [AltInspectionId]
				, [InspectionDate]
				, [AmPm]
				, [PropertyId]
				--, [TenantId]
				, [FollowUpNotes]
				, [DiaryId]
				, [Telephone]
				, [StatusId]
				, LastUpdated
				) OUTPUT INSERTED.InspectionId, INSERTED.AltInspectionId INTO @NewInspections(InspectionId, AltInspectionId)
		SELECT    AltInspectionId
				, InspectionDate
				, AMPM
				, PropertyId
				, FollowUpNote
				, DiaryId
				, Telephone
				, 1 AS StatusId
				, LastUpdated
		FROM #bookings
		WHERE InspectionId IS NULL


		-- UPDATE CROYDON BOOKING SYSTEM WITH NEW INSPECTION ID
		IF (SELECT COUNT(*) FROM @NewInspections) > 0
		BEGIN
			UPDATE P
			SET P.InspectionId = N.InspectionId
			FROM @NewInspections AS N
			INNER JOIN LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits AS P ON N.AltInspectionId = P.[UID]
		END


		-- DROP TEMP TABLE
		IF OBJECT_ID('tempdb..#bookings', 'U') IS NOT NULL DROP TABLE #bookings

	END


	-- UPDATE SYNC CONFIG
	UPDATE dbo.syncConfig
	SET lastRunTime = @CurrentRunTime
	WHERE configName = @SyncConfigName

	
	-- COMMIT TRANSACTION
	COMMIT TRAN

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
		  , @InspectionId = NULL
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH