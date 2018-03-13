

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[ProcessInspectionUpdates]
AS
BEGIN TRY

    BEGIN TRAN

    DECLARE @ProcessName VARCHAR(255)
		  , @Message VARCHAR(1000)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    /*************************************************************
					   HANDLE UPDATES
    *************************************************************/
    
    UPDATE I
    SET I.InspectionDate = U.InspectionDate
	   , I.AmPm = U.AmPm
	   , I.OfficerId = U.OfficerId
	   , I.Diaryid = U.DiaryId
	   , I.Telephone = U.Telephone
	   , I.FollowUpNotes = COALESCE(U.Pest + ' ', '') + U.Comments
	   , I.LastUpdated = CURRENT_TIMESTAMP
    FROM Inspection.Inspection AS I
    INNER JOIN dbo.PCC_CroydonUpdates AS U ON I.InspectionId = U.InspectionId

    /************************************
			 LOG EVENT
    ************************************/
    SET @Message = 'Successfully updated ' + CAST(@@ROWCOUNT AS VARCHAR(4)) + ' inspections.'

    EXEC [Log].LogEvent
		  @ProcessName = @ProcessName
		  , @Message = @Message


    /*************************************************************
					   HANDLE INSERTS
    *************************************************************/
    
    DECLARE @NewInspections TABLE(
	     InspectionId INT NOT NULL
	   , AltInspectionId INT NOT NULL
    )

    DECLARE @NewProperties TABLE(
	     PropertyId INT NOT NULL
	   , UPRN VARCHAR(20)
    )

    DECLARE @StatusId INT
    SET @StatusId = (SELECT StatusId FROM [Lookup].[Status] WHERE StatusDesc = 'Pending')

    -- GET RID OF ANY BLOCKIDs WHICH DONT EXIST
    UPDATE dbo.PCC_CroydonInserts
    SET BlockId = NULL
    WHERE BlockId NOT IN (SELECT BlockId FROM Property.Block)

    -- INSERT ANY NEW PROPERTIES AND RETRIEVE THE NEW PropertyId
    INSERT INTO Property.Property(
		AltPropertyId
	   , BlockId
	   , HouseName
	   , HouseNo
	   , Street
	   , AddressLine1
	   , AddressLine2
	   , Postcode
	   , UPRN
	   , Easting
	   , Northing
    ) OUTPUT INSERTED.PropertyId, INSERTED.UPRN INTO @NewProperties(PropertyId, UPRN)
    SELECT AltPropertyId
	   , BlockId
	   , HouseName
	   , HouseNo
	   , Street
	   , AddressLine1
	   , AddressLine2
	   , Postcode
	   , UPRN
	   , Easting
	   , Northing
    FROM dbo.PCC_CroydonInserts
    WHERE UPRN NOT IN (SELECT UPRN FROM Property.Property)

    -- UPDATE THE STAGING TABLE WITH THE NEW PropertyId
    UPDATE I
    SET I.PropertyId = N.PropertyId
    FROM dbo.PCC_CroydonInserts AS I
    INNER JOIN @NewProperties AS N ON I.UPRN = N.UPRN


    -- INSERT THE NEW BOOKING INTO INSPECTIONS TABLE
    INSERT INTO Inspection.Inspection(
	     AltInspectionId
	   , InspectionDate
	   , AmPm
	   , OfficerId
	   , PropertyId
	   , DiaryId
	   , Telephone
	   , FollowUpNotes
	   , StatusId
    ) OUTPUT INSERTED.InspectionId, INSERTED.AltInspectionId INTO @NewInspections(InspectionId, AltInspectionId)
    SELECT AltInspectionId
	   , InspectionDate
	   , AmPm
	   , OfficerId
	   , PropertyId
	   , DiaryId
	   , Telephone
	   , Comments
	   , @StatusId
    FROM dbo.PCC_CroydonInserts
    WHERE AltInspectionId NOT IN (SELECT AltInspectionId FROM Inspection.Inspection WHERE AltInspectionId IS NOT NULL)

    -- UPDATE THE STAGING TABLE WITH THE NEW InspectionId
    UPDATE I
    SET I.InspectionId = N.InspectionId
    FROM dbo.PCC_CroydonInserts AS I
    INNER JOIN @NewInspections AS N ON I.AltInspectionId = N.AltInspectionId
    WHERE N.InspectionId IS NOT NULL


    /************************************
			 LOG EVENT
    ************************************/
    SET @Message = 'Successfully inserted ' + CAST(@@ROWCOUNT AS VARCHAR(4)) + ' inspections.'

    EXEC [Log].LogEvent
		  @ProcessName = @ProcessName
		  , @Message = @Message


    -- UPDATE THE LAT AND LONG VALUES
    EXEC dbo.ConvertPropertiesEastingNorthingToLatLong


    /************************************
			 LOG EVENT
    ************************************/

    EXEC [Log].LogEvent
		  @ProcessName = @ProcessName
		  , @Message = 'Successfully updated Latitide and Longitude values.'

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
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH
