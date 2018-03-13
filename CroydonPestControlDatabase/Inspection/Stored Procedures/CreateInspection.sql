CREATE PROCEDURE [Inspection].[CreateInspection](
	 @UserId INT = NULL
    , @AltInspectionId INT = NULL
    , @InspectionDate DATETIME
    , @AmPm CHAR(2)
    , @OfficerId INT = NULL
    , @AssignedBy INT = NULL
    , @DateAssigned DATETIME = NULL
    , @PropertyId INT
    , @TenantId INT = NULL
    , @BlockCycleId INT = NULL
    , @DiaryId INT
    , @Telephone VARCHAR(20) = NULL
    , @FollowUpDate DATETIME = NULL
    , @FollowUpAmPm CHAR(2) = NULL
    , @FollowUpId INT = NULL
    , @FollowUpNotes VARCHAR(2000) = NULL
    , @FollowUpInspectionId INT = NULL
    , @LastUpdatedBy INT = NULL
    , @NewInspectionId INT OUTPUT
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
		  , @Message VARCHAR(2000)
    
    DECLARE @NewInspection TABLE(
	   InspectionId INT
    )

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    -- CHECK FOR EXISTING INSPECTION IN SAME DATE
    IF NOT EXISTS(SELECT 1 FROM Inspection.Inspection WHERE PropertyId = @PropertyId AND InspectionDate = @InspectionDate) AND ISDATE(@InspectionDate) = 1
	   BEGIN
		  INSERT INTO [Inspection].[Inspection](
					[AltInspectionId]
				   , [InspectionDate]
				   , [AmPm]
				   , [OfficerId]
				   , [AssignedBy]
				   , [DateAssigned]
				   , [PropertyId]
				   , [TenantId]
				   , [BlockCycleId]
				   , [DiaryId]
				   , [Telephone]
				   , [FollowUpDate]
				   , [FollowUpAmPm]
				   , [FollowUpId]
				   , [FollowUpNotes]
				   , [FollowUpInspectionId]
				   , [LastUpdated]
				   , [LastUpdatedBy]
				   , [StatusId]
			   ) OUTPUT INSERTED.InspectionId INTO @NewInspection(InspectionId)
			  VALUES(
					@AltInspectionId
				   , @InspectionDate
				   , @AmPm
				   , @OfficerId
				   , @AssignedBy
				   , @DateAssigned
				   , @PropertyId
				   , @TenantId
				   , @BlockCycleId
				   , @DiaryId
				   , @Telephone
				   , @FollowUpDate
				   , @FollowUpAmPm
				   , @FollowUpId
				   , @FollowUpNotes
				   , @FollowUpInspectionId
				   , CURRENT_TIMESTAMP
				   , @LastUpdatedBy
				   , 1 -- PENDING
			 )

			 SET @NewInspectionId = (SELECT TOP 1 InspectionId FROM @NewInspection)
		  END
	   ELSE
		  BEGIN
			
			 -- LOG EVENT: INSPECTION ALREADY EXISTS FOR THIS DATE
			 SET @Message = 'Inspection already exists for property ' + CAST(@PropertyId AS VARCHAR(10)) + ' on date ' + CONVERT(VARCHAR, @InspectionDate, 103)

			 EXEC [Log].LogEvent
				  @ProcessName = @ProcessName
				, @OfficerId = @UserId
				, @Message = @Message
			 
		  END

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