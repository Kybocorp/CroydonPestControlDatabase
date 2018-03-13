
CREATE PROC [dbo].[UpdateInspectionNoAccess](
    @InspectionId INT
    , @NoAccessId INT
    , @FollowUpId INT
    , @FollowUpNotes VARCHAR(2000) = NULL
    , @VisitTypeId INT = NULL
    , @Result BIT OUTPUT
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
		  , @FollowUpDate DATETIME
		  , @FollowUpAmPm CHAR(2)
		  , @Message VARCHAR(1000)
		  , @FollowUpInspectionId INT
		  , @PropertyId INT
		  , @Telephone VARCHAR(20)
		  , @TenantId INT
		  , @TenantFirstName VARCHAR(200)
		  , @TenantLastName VARCHAR(200)
		  , @TenantEmail VARCHAR(255)
		  , @Address VARCHAR(200)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

    SET NOCOUNT ON

    /********************************************************
				INSERT INTO AUDIT TABLE
    ********************************************************/
    INSERT INTO [Log].[UpdateInspectionNoAccess](
		InspectionId
	   , NoAccessId
	   , VisitTypeId
	   , FollowUpId
	   , FollowUpNotes
    )
    VALUES(
	     @InspectionId
	   , @NoAccessId
	   , @VisitTypeId
	   , @FollowUpId
	   , @FollowUpNotes
    )


	/**************************************************************
			GET FOLLOW UP DATE AND AMPM IF APPLICABLE
	**************************************************************/
	DECLARE @AltBookingId INT
			, @PestsString VARCHAR(100)
	
	SELECT @FollowUpInspectionId = FollowUpInspectionId
			, @PropertyId = I.PropertyId
			, @PestsString = ''
			, @Telephone = I.Telephone
			, @TenantId = I.TenantId
			, @TenantFirstName = T.FirstName
			, @TenantLastName = T.LastName
			, @TenantEmail = T.Email
			, @Address = COALESCE(NULLIF(LTRIM(RTRIM(P.HouseName)), '') + '_', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.HouseNo)), '') + '_', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.Street)), ''), '')
	FROM Inspection.Inspection AS I
	LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
	LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
	WHERE InspectionId = @InspectionId

	IF(@FollowUpId > 0 AND COALESCE(@FollowUpInspectionId, 0) = 0)
	BEGIN


		/************************************
					LOG EVENT
		************************************/
			EXEC [Log].LogEvent 
				@ProcessName = @ProcessName
				, @InspectionId = @InspectionId
				, @Message = 'Retrieving follow-up date and slot.'



			/**************************************************************
							BOOK FOLLOW-UP VISIT
			**************************************************************/
		EXEC [dbo].[BookFollowUp]
				@InspectionId = @InspectionId
			, @PropertyId = @PropertyId
			, @Telephone = @Telephone
			, @FollowUpNotes = @FollowUpNotes
			, @FollowUpId = @FollowUpId
			, @Pests = @PestsString
			, @NewInspectionId = @FollowUpInspectionId OUTPUT
			, @AltBookingId = @AltBookingId OUTPUT
			, @AMPM = @FollowUpAmPm OUTPUT
			, @InspectionDate = @FollowUpDate OUTPUT

			
		-- UPDATE @FollowUpId
		IF @AltBookingId > 0
		BEGIN
			SET @FollowUpId = @AltBookingId
		END


		/************************************
					LOG EVENT
		************************************/
		SET @Message = 'Successfully created follow-up inspection: ' + CAST(@FollowUpInspectionId AS VARCHAR(10))

		EXEC [Log].LogEvent 
				@ProcessName = @ProcessName
				, @InspectionId = @InspectionId
				, @Message = @Message
		  
		END


    /********************************************************
				UPDATE INSPECTION
    ********************************************************/

    DECLARE @StatusId INT

    SET @Result = 1
    SET @StatusId = (SELECT TOP 1 StatusId FROM [Lookup].[Status] WHERE StatusDesc = 'NoAccess')

    IF(@InspectionId > 0 AND @NoAccessId > 0)
	   BEGIN

		  UPDATE Inspection.Inspection
		  SET NoAccessId = @NoAccessId
			, StatusId = @StatusId
			, VisitTypeId = @VisitTypeId
			, FollowUpId = @FollowUpId
			, FollowUpDate = @FollowUpDate
			, FollowUpAmPm = @FollowUpAmPm
			, FollowUpNotes = @FollowUpNotes
			, NoAccessTime = CURRENT_TIMESTAMP
			, LastUpdated = CURRENT_TIMESTAMP
		  WHERE InspectionId = @InspectionId


		  	/**************************************************************
						PRODUCE SUMMARY PDF AND SEND EMAIL :)
			**************************************************************/
			DECLARE @ExportConfigName VARCHAR(100)
					, @DocumentPath VARCHAR(255)
					, @TenantFullName NVARCHAR(200)
					, @execution_id BIGINT

			SET @ExportConfigName = 'PestControlGenerateNoAccessSummaryPDF'
			SET @DocumentPath = (SELECT DestinationPath FROM [Lookup].ExportConfig WHERE ExportConfigName = @ExportConfigName)
			SET @DocumentPath = @DocumentPath + '\' + CAST(@InspectionId AS VARCHAR(10)) + '_' + @Address + '_NoAccess.pdf'
			SET @TenantFullName = COALESCE(@TenantFirstName + ' ', '') + COALESCE(@TenantLastName, '')
			SET @TenantId = COALESCE(@TenantId, 0)
	
	
			IF(COALESCE(@TenantEmail, '') <> '')
				BEGIN
					 -- GENERATE PDF AND SEND EMAIL
					EXEC [dbo].[SendEmailInspectionOutcome]
					  @InspectionId = @InspectionId
					, @TenantId = @TenantId
					, @ContactName = @TenantFullName
					, @DocumentPath = @DocumentPath
					, @EmailAddress = @TenantEmail
					, @EmailTemplateName = 'InspectionNoAccess'
					, @ExportConfigName = @ExportConfigName
					, @execution_id = @execution_id OUTPUT
				END
			ELSE
				BEGIN
					DECLARE @DocFileName VARCHAR(255)
					SET @DocFileName = CAST(@InspectionId AS VARCHAR(10)) + '_' + @Address + '_NoAccess.pdf'

					-- GENERATE PDF
					EXEC [dbo].[GeneratePDF]
					  @InspectionId = @InspectionId
					, @FileName = @DocFileName
					, @ExportConfigName = @ExportConfigName
					, @execution_id = @execution_id OUTPUT
				END


	   END
    ELSE
	   BEGIN 

		  -- LOG INVALID InspectionId
		  IF(@InspectionId !>0)
			 BEGIN
				/************************************
						LOG EVENT
				************************************/
				EXEC [Log].LogEvent 
					   @ProcessName = @ProcessName
					 , @InspectionId = @InspectionId
					 , @Message = 'Error updating inspection to No Access. Invalid InspectionId supplied'
					 , @IsError = 1
			 END
		  
		  -- LOG INVALID NoAccessId
		  IF(@NoAccessId !>0)
			 BEGIN
				DECLARE @m VARCHAR(100) = 'Error updating inspection to No Access. Invalid NoAccessId supplied: ' + @NoAccessId

				/************************************
						LOG EVENT
				************************************/
				EXEC [Log].LogEvent 
					   @ProcessName = @ProcessName
					 , @InspectionId = @InspectionId
					 , @Message = @m
					 , @IsError = 1
			 END

		  SET @Result = 0
	   END

    RETURN @Result

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

