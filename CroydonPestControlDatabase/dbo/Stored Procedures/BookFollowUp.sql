
CREATE PROC [dbo].[BookFollowUp](
	  @InspectionId INT
	, @PropertyId INT
	, @Telephone VARCHAR(20)
	, @FollowUpNotes VARCHAR(2000)
	, @StatusId INT = 1
	, @FollowUpId INT
	, @Pests VARCHAR(100)
	, @NewInspectionId INT OUTPUT
	, @AltBookingId INT OUTPUT
	, @AMPM CHAR(2) OUTPUT
	, @InspectionDate DATETIME OUTPUT
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

	-- BEGIN TRANSACTION
	-- BEGIN TRAN

	-- DECLARE VARIABLES
	DECLARE @AltAMPM CHAR(2)
			, @DiaryId INT
			, @Allocated BIT
			, @UPRN VARCHAR(20)
			, @OfficerName VARCHAR(200)

	DECLARE @NewInspectionTable TABLE(
		NewInspectionId INT
	)

	SET @OfficerName = (SELECT COALESCE(LEFT(FirstName, 1), '') + COALESCE(LastName, '') FROM dbo.Officer WHERE OfficerId IN (SELECT OfficerId FROM Inspection.Inspection WHERE InspectionId = @InspectionId))
	SET @UPRN = (SELECT UPRN FROM Property.Property WHERE PropertyId = @PropertyId)

    
	/**************************************************************
						GET BOOKING INFO
	**************************************************************/
	SELECT @InspectionDate = VisitDate
			, @AMPM = LEFT(AMPM, 2)
			, @DiaryId = Sheet
			, @Allocated = (CASE
								WHEN Allocated = 'N' THEN 0
								ELSE 1
							END)
	FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
	WHERE [UID] = @FollowUpId


	/**************************************************************
		  GET ALTERNATIVE BOOKING IF CURRENT BOOKING IS TAKEN
	**************************************************************/
	IF @Allocated = 1
	BEGIN

		WHILE COALESCE(@AltBookingId, 0) = 0
		BEGIN

			SELECT TOP 1 @AltBookingId = [UID]
					, @AltAMPM = LEFT(AMPM, 2)
			FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
			WHERE VisitDate = @InspectionDate
			AND LEFT(AMPM, 2) = @AMPM
			AND Sheet = @DiaryId
			AND Allocated = 'N'


			IF COALESCE(@AltBookingId, 0) = 0
			BEGIN

				SELECT TOP 1 @AltBookingId = [UID]
						, @AltAMPM = LEFT(AMPM, 2)
				FROM LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
				WHERE VisitDate = @InspectionDate
				AND Allocated = 'N'
				AND Sheet = @DiaryId

			END

			-- ADD ONE DAY TO THE INSPECTION DATE
			SET @InspectionDate = DATEADD(DD, 1, @InspectionDate)

		END

		-- UPDATE FOLLOW UP ID WITH THE NEW BOOKING ID
		SET @FollowUpId = @AltBookingId
		SET @AMPM = @AltAMPM

	END


	/**************************************************************
						CREATE NEW INSPECTION
	**************************************************************/
	INSERT INTO Inspection.Inspection(
		  InspectionDate
		, AMPM
		, DiaryId
		, PropertyId
		, Telephone
		, FollowUpNotes
		, StatusId
		, AltInspectionId
	) OUTPUT INSERTED.InspectionId INTO @NewInspectionTable(NewInspectionId)
	SELECT @InspectionDate
		, @AMPM
		, @DiaryId
		, @PropertyId
		, @Telephone
		, @FollowUpNotes
		, @StatusId
		, @FollowUpId

	-- EXTRACT NEW INSPECTION ID
	SET @NewInspectionId = (SELECT TOP 1 NewInspectionId FROM @NewInspectionTable)

	/**************************************************************
							UPDATE BOOKING
	**************************************************************/
	UPDATE LBS14.PCC_Croydon.dbo.Pest_ReactiveVisits
	SET Allocated = 'Y'
		, Prop_UID = @PropertyId
		, Comments = @FollowUpNotes
		, InspectionId = @NewInspectionId
		, Telephone = @Telephone
		, Pest = @Pests
		, UPRN = @UPRN
		, AddedBy = @OfficerName
	WHERE [UID] = @FollowUpId


	-- COMMIT TRANSACTION
	-- COMMIT TRAN

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