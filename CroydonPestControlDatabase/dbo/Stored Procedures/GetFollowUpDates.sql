
CREATE PROC [dbo].[GetFollowUpDates](
    @InspectionId INT
    , @Pests VARCHAR(255)
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
			, @DiaryId INT

    SET @ProcessName = OBJECT_NAME(@@PROCID)
	SET @DiaryId = (SELECT DiaryId FROM Inspection.Inspection WHERE InspectionId = @InspectionId)

    DECLARE @PestsTable TABLE(
	   PestId INT
    )

    INSERT INTO @PestsTable(PestId)
    SELECT Id
    FROM dbo.SplitInts(@Pests, '|')

    DECLARE @BedBugsID INT
    SET @BedBugsID = (SELECT PestId FROM [Lookup].Pest WHERE PestName = 'Bedbugs')

    DECLARE @FollowUpDates TABLE (
	     BookingId INT
	   , BookingDate DATE
	   , BookingSlot CHAR(2)
    )

	-- CHECK IF BEDBUGS
    IF (@BedBugsID IN (SELECT PestId FROM @PestsTable))
	   BEGIN
			-- BEDBUGS DIARY
		  INSERT INTO @FollowUpDates(
			   BookingId
			 , BookingDate
			 , BookingSlot
		  )
		  SELECT [UID]
				, VisitDate
				, LEFT(AMPM, 2)
		  FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
		  WHERE VisitDate BETWEEN DATEADD(DD, 1, CURRENT_TIMESTAMP) AND DATEADD(MONTH, 3, CURRENT_TIMESTAMP)
		  AND Sheet = 4
		  AND Allocated = 'N'
	   END
    ELSE
	   BEGIN
		  INSERT INTO @FollowUpDates(
			   BookingId
			 , BookingDate
			 , BookingSlot
		  )
		  SELECT [UID]
				, VisitDate
				, LEFT(AMPM, 2)
		  FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
		  WHERE VisitDate BETWEEN DATEADD(DD, 1, CURRENT_TIMESTAMP) AND DATEADD(MONTH, 3, CURRENT_TIMESTAMP)
		  AND Sheet = @DiaryId
		  AND Allocated = 'N'
		  
	   END

    SELECT MAX(BookingId) AS BookingId
	   , BookingDate
	   , LEFT(BookingSlot, 2) AS BookingSlot
    FROM @FollowUpDates
	GROUP BY BookingDate, BookingSlot

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

