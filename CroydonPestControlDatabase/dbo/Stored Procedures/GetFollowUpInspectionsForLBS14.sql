

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[GetFollowUpInspectionsForLBS14](
      @InspectionId INT
    , @FollowUpId INT
)
AS
BEGIN TRY
    
    -- DECLARE VARIABLES
    DECLARE @UPRN VARCHAR(20)
		  , @Pests VARCHAR(100)
		  , @Telephone VARCHAR(20)
		  , @FollowUpNotes VARCHAR(1000)
		  , @AltPropertyId INT

    -- RETRIEVE INSPECTION DETAILS
    SELECT @UPRN = P.UPRN
		  , @Pests = Pests.Pests
		  , @Telephone = I.Telephone
		  , @FollowUpNotes = FollowUpNotes
		  , @AltPropertyId = P.AltPropertyId
    FROM Inspection.Inspection AS I
    LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
    LEFT OUTER JOIN (
			 SELECT 
				PT.InspectionId,
				STUFF((SELECT ', ' + P.PestName
					   FROM Inspection.PestTreatment AS T
					   INNER JOIN [Lookup].Pest AS P ON T.PestId = P.PestId
					   WHERE T.InspectionId = PT.InspectionId
					   FOR XML PATH('')), 1, 1, '') AS Pests
			 FROM Inspection.PestTreatment AS PT
			 GROUP BY PT.InspectionId
			 --ORDER BY PT.InspectionId
		  ) AS Pests ON I.InspectionId = Pests.InspectionId
    WHERE I.InspectionId = @InspectionId

    -- UPDATE BOOKING
    --UPDATE [LBS14].PCC_Croydon.dbo.Pest_ReactiveVisits
    --SET UPRN = @UPRN
		  --, Pest = @Pests
		  --, Telephone = @Telephone
		  --, Comments = @FollowUpNotes
		  --, Prop_UId = @AltPropertyId
    --WHERE [UID] = @FollowUpId

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
