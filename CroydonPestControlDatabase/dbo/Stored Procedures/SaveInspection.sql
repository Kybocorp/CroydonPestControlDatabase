
CREATE PROC [dbo].[SaveInspection](
    @Inspection XML
    , @Result BIT OUTPUT
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
		  , @Now DATETIME
		  , @Message VARCHAR(1000)

    SET @ProcessName = OBJECT_NAME(@@PROCID)
    SET @Now = CURRENT_TIMESTAMP



    /********************************************************
				INSERT INTO AUDIT TABLE
    ********************************************************/
    INSERT INTO [Log].[SaveInspection](
	   Inspection
    )
    VALUES(
	   @Inspection
    )


	   /************************************
			   LOG EVENT
	   ************************************/
	   EXEC [Log].LogEvent 
			 @ProcessName = @ProcessName
		    , @Message = 'Starting to extract data from XML'


    SET @Result = 1

    -- DECLARE VARIABLES
    DECLARE @FollowUpDate DATETIME
		  , @FollowUpAmPm CHAR(2)
		  , @LogMessage VARCHAR(100)
		  , @InspectionId INT
		  --, @Status VARCHAR(20)
		  , @StatusId INT
		  , @TenantId INT
		  , @PropertyId INT
		  , @InspectionDate DATETIME
		  , @AmPm CHAR(2)
		  , @DiaryId INT
		  , @Telephone VARCHAR(20)
		  , @FollowUpInspectionId INT
		  , @CurrentStatusId INT

    SET @InspectionId = @Inspection.value('(/InspectionRequest/InspectionId)[1]', 'INT')
    --SET @Status = @Inspection.value('(/InspectionRequest/Status)[1]', 'VARCHAR(50)')
    SET @StatusId = (SELECT StatusId FROM [Lookup].[Status] WHERE StatusDesc = 'Complete')

    -- GET INSPECTION DETAILS
    SELECT @TenantId = TenantId
		  , @PropertyId = PropertyId
		  , @FollowUpInspectionId = FollowUpInspectionId
		  , @CurrentStatusId = StatusId
		  , @Telephone = Telephone
    FROM Inspection.Inspection
    WHERE InspectionId = @InspectionId

	IF (@CurrentStatusId <> @StatusId)
		BEGIN

			--DECLARE TABLE VARIABLES
			DECLARE @Tenant TABLE(
				TenantId INT
			   , FirstName VARCHAR(100)
			   , LastName VARCHAR(100)
			   , Telephone VARCHAR(20)
			   , Email VARCHAR(255)
			   , IsDangerous BIT
			   , IsNew BIT
			)

			DECLARE @Property TABLE(
				PropertyId INT
			   , HouseName VARCHAR(100)
			   , HouseNo VARCHAR(100)
			   , Street VARCHAR(100)
			   , AddressLine1 VARCHAR(100)
			   , AddressLine2 VARCHAR(100)
			   , PostCode VARCHAR(20)
			   , Longitude DECIMAL(10, 7)
			   , Latitude DECIMAL(10, 7)
			)

			DECLARE @Form TABLE(
				StartTime DATETIME
			   , EndTime DATETIME
			   , NoAccess INT
			   , InsectMonitorsFound INT
			   , BaitPointsFound INT
			   , HygieneLevelId INT
			   , PaymentTypeId INT
			   , PaymentAmount MONEY
			   , JobClosed BIT
			   , VisitTypeId INT
			   , FollowUpId INT
			   , FollowUpNotes VARCHAR(2000)
			   , Notes VARCHAR(2000)
			   , TenantSignature VARBINARY(MAX)
			   , UserSignature VARBINARY(MAX)
			)

			DECLARE @Conditions TABLE(
				ConditionType VARCHAR(50)
			   , ConditionId INT
			)

			DECLARE @PestTreatment TABLE(
				PestTreatmentId INT IDENTITY(1, 1)
			   , PestId INT
			   , InfestationLevelId INT
			   , MonitorsUsed INT
			   , BaitPointsUsed INT
			   , RefrainUsingFor INT
			   , Areas XML
			   , Treatments XML
			   , [NewId] INT
			)

			DECLARE @Images TABLE(
				ImageId INT IDENTITY(1, 1)
			   , [Image] VARBINARY(MAX)
			)


			-- GET TENANT DATA
			INSERT INTO @Tenant(
				TenantId
			   , FirstName
			   , LastName
			   , Telephone
			   , Email
			   , IsDangerous
			   , IsNew
			)
			SELECT T.t.value('./TenantId[1]', 'INT')
				  , T.t.value('./FirstName[1]', 'VARCHAR(100)')
				  , T.t.value('./LastName[1]', 'VARCHAR(100)')
				  , T.t.value('./Telephone[1]', 'VARCHAR(20)')
				  , T.t.value('./Email[1]', 'VARCHAR(255)')
				  , T.t.value('./IsDangerous[1]', 'BIT')
				  , T.t.value('./IsNewTenant[1]', 'BIT')
			FROM @Inspection.nodes('/InspectionRequest/Tenant') T(t)


			-- GET ADDRESS DATA
			INSERT INTO @Property(
				PropertyId
			   , HouseName
			   , HouseNo
			   , Street
			   , AddressLine1
			   , AddressLine2
			   , PostCode
			   , Longitude
			   , Latitude
			)
			SELECT T.p.value('./PropertyId[1]', 'INT')
				  , T.p.value('./HouseName[1]', 'VARCHAR(100)')
				  , T.p.value('./HouseNumber[1]', 'VARCHAR(100)')
				  , T.p.value('./Street[1]', 'VARCHAR(100)')
				  , T.p.value('./AddressLine1[1]', 'VARCHAR(100)')
				  , T.p.value('./AddressLine2[1]', 'VARCHAR(100)')
				  , T.p.value('./PostCode[1]', 'VARCHAR(100)')
				  , T.p.value('./Longitude[1]', 'DECIMAL(10, 7)')
				  , T.p.value('./Latitude[1]', 'DECIMAL(10, 7)')
			FROM @Inspection.nodes('/InspectionRequest/Address') T(p)


			-- GET INSPECTION FORM DATA
			INSERT INTO @Form(
				StartTime
			   , EndTime
			   , NoAccess
			   , InsectMonitorsFound
			   , BaitPointsFound
			   , HygieneLevelId
			   , PaymentTypeId
			   , PaymentAmount
			   , JobClosed
			   , VisitTypeId
			   , FollowUpId
			   , FollowUpNotes
			   , Notes
			   , TenantSignature
			   , UserSignature
			)
			SELECT T.a.value('./StartTime[1]', 'DATETIME')
			   , T.a.value('./EndTime[1]', 'DATETIME')
			   , T.a.value('./NoAccess[1]', 'INT')
			   , T.a.value('./InsectMonitorsFound[1]', 'INT')
			   , T.a.value('./BaitPointsFound[1]', 'INT')
			   , T.a.value('./HygieneLevelId[1]', 'INT')
			   , T.a.value('./PaymentDetails[1]/PaymentTypeId[1]', 'INT')
			   , T.a.value('./PaymentDetails[1]/AmountPaid[1]', 'MONEY')
			   , T.a.value('./JobClosed[1]', 'BIT')
			   , T.a.value('./VisitTypeId[1]', 'INT')
			   , T.a.value('./FollowUpDate[1]', 'INT')
			   , T.a.value('./FollowUpNotes[1]', 'VARCHAR(2000)')
			   , T.a.value('./Notes[1]', 'VARCHAR(2000)')
			   , T.a.value('./TenantSignature[1]', 'VARBINARY(MAX)')
			   , T.a.value('./UserSignature[1]', 'VARBINARY(MAX)')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm') T(a)


			-- GET CONDITIONS
    
			   -- GET RiskAssessments
			INSERT INTO @Conditions(
			   ConditionType
			   , ConditionId
			)
			SELECT 'RiskAssessment'
				  , T.a.value('.', 'INT')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm/RiskAssessmentIds/int') T(a)

			   -- GET StandardComments
			INSERT INTO @Conditions(
			   ConditionType
			   , ConditionId
			)
			SELECT 'StandardComment'
				  , T.a.value('.', 'INT')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm/StandardCommentsIds/int') T(a)

			   -- GET HygieneComments
			INSERT INTO @Conditions(
			   ConditionType
			   , ConditionId
			)
			SELECT 'HygieneComment'
				  , T.a.value('.', 'INT')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm/HygieneCommentIds/int') T(a)


			-- GET TREATMENTS
			INSERT INTO @PestTreatment(
				PestId
			   , InfestationLevelId
			   , MonitorsUsed
			   , BaitPointsUsed
			   , RefrainUsingFor
			   , Areas
			   , Treatments
			)
			SELECT T.m.value('./PestId[1]', 'INT')
			   , T.m.value('./InfestationLevelId[1]', 'INT')
			   , T.m.value('./MonitorsUsed[1]', 'INT')
			   , T.m.value('./BaitPointsUsed[1]', 'INT')
			   , T.m.value('./RefrainUsingFor[1]', 'INT')
			   , T.m.query('./AreaIds')
			   , T.m.query('./TreatmentIds')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm/Treatments/TreatmentViewModel') T(m)
			WHERE T.m.value('./PestId[1]', 'INT') NOT IN (SELECT PestId FROM Inspection.PestTreatment WHERE InspectionId = @InspectionId)


			-- GET IMAGES
			INSERT INTO @Images(
			   [Image]
			)
			SELECT T.a.value('.', 'VARBINARY(MAX)')
			FROM @Inspection.nodes('/InspectionRequest/PestControlForm/EvidenceImages/base64Binary') T(a)


			   /************************************
					   LOG EVENT
			   ************************************/
			   EXEC [Log].LogEvent 
					 @ProcessName = @ProcessName
					, @InspectionId = @InspectionId
					, @Message = 'Finished extracting data from XML'



			/**************************************************************
					PROCESS THE TENANT - CHECK IF NEW
			**************************************************************/
			DECLARE   @TenantFirstName VARCHAR(100)
				  , @TenantLastName VARCHAR(100)
				  , @TenantTelephone VARCHAR(20)
				  , @TenantEmail VARCHAR(255)
				  , @TenantIsNew BIT
				  , @TenantIsDangerous BIT


			SELECT  /*@TenantId = TenantId
				  ,*/ @TenantFirstName = COALESCE(FirstName, '')
				  , @TenantLastName = COALESCE(LastName, '')
				  , @TenantTelephone = Telephone
				  , @TenantEmail = Email
				  , @TenantIsNew = CASE
										WHEN IsNew = 0 AND COALESCE(@TenantId, 0) = 0 THEN 1
										ELSE IsNew
									END
				  , @TenantIsDangerous = IsDangerous
			FROM @Tenant

			-- BLANK OUT EMAIL ADDRESS IF ITS PestControladmin@southwark.gov.uk
			IF @TenantEmail = 'PestControladmin@southwark.gov.uk'
			BEGIN
				SET @TenantEmail = NULL
			END

			-- CHECK IF TenantId IS GREATER THAN 0
			IF(@TenantIsNew = 1)
			   BEGIN

				  DECLARE @NewTenantTable TABLE(
						Id INT
					 )
		  
				
				  -- LOOK FOR TENANT AGAINST ALL TENANTS REGISTERED AT THIS PROPERTY
				  DECLARE @MatchedTenantId INT
				  SET @MatchedTenantId = (
										SELECT TOP 1 TenantId
										FROM Property.Tenant
										WHERE PropertyId = @PropertyId
										AND (
											   FirstName = @TenantFirstName
											   AND
											   LastName = @TenantLastName
											)
										OR (
											   Email = @TenantEmail
											)
									)
				

				  IF(@MatchedTenantId > 0)
					 BEGIN
					   
						-- UPDATE TenantId TO LINK TO MATCHED TENANT
						SET @TenantId = @MatchedTenantId

						/************************************
								  LOG EVENT
						************************************/
						SET @LogMessage = 'New tenant details, successfully matched to existing tenant record: ' + CAST(@TenantId AS VARCHAR(10))

						EXEC [Log].LogEvent 
							   @ProcessName = @ProcessName
							   , @InspectionId = @InspectionId
							   , @Message = @LogMessage

					 END
				  ELSE
					 BEGIN
					   
						-- INSERT INTO TENANT TABLE, GET NEW TenantId
						INSERT INTO [Property].[Tenant](
									[FirstName]
								  , [LastName]
								  , [Telephone]
								  , [Email]
								  , [PropertyId]
								  , [IsDangerous]
							   ) OUTPUT INSERTED.TenantId INTO @NewTenantTable(Id)
						VALUES(
									@TenantFirstName
								  , @TenantLastName
								  , @TenantTelephone
								  , @TenantEmail
								  , @PropertyId
								  , @TenantIsDangerous
							   )

						SET @TenantId = (SELECT TOP 1 Id FROM @NewTenantTable)


						/************************************
								  LOG EVENT
						************************************/
						SET @LogMessage = 'New tenant details, successfully created new tenant record: ' + CAST(@TenantId AS VARCHAR(10))

						EXEC [Log].LogEvent 
							   @ProcessName = @ProcessName
							   , @InspectionId = @InspectionId
							   , @Message = @LogMessage

					 END
			   END
			ELSE
			   BEGIN
				
				  UPDATE Property.Tenant
				  SET FirstName = @TenantFirstName
					 , LastName = @TenantLastName
					 , Telephone = @TenantTelephone
					 , Email = @TenantEmail
					 , LastUpdated = @Now
					 , IsDangerous = @TenantIsDangerous
				  WHERE TenantId = @TenantId

			   END


			/**************************************************************
							BEGIN TRANSACTION
			**************************************************************/
			--BEGIN TRAN


				/**************************************************************
					   GET FOLLOW UP DATE AND AMPM IF APPLICABLE
				**************************************************************/
				DECLARE @FollowUpId INT
						, @FollowUpNotes VARCHAR(2000)
						, @AltBookingId INT
						, @PestsString VARCHAR(100)
		
				SELECT @FollowUpId = FollowUpId
						, @FollowUpNotes = FollowUpNotes
				FROM @Form

				IF(@FollowUpId > 0 AND COALESCE(@FollowUpInspectionId, 0) = 0)
				BEGIN


					/************************************
							 LOG EVENT
					************************************/
					 EXEC [Log].LogEvent 
							@ProcessName = @ProcessName
						  , @InspectionId = @InspectionId
						  , @Message = 'Retrieving follow-up date and slot.'



					/************************************
							 GET PESTS FOUND
					************************************/
					SET @PestsString = (
							SELECT DISTINCT TOP 1 LTRIM(RTRIM(SUBSTRING(
								(
									SELECT DISTINCT ', ' + P.PestName AS [text()]
									FROM @PestTreatment AS PT1
									INNER JOIN [Lookup].Pest AS P ON PT1.PestId = P.PestId
									WHERE PT1.PestId <> 0
									FOR XML PATH ('')
								), 2, 500))) [Pest]
							FROM @PestTreatment AS PT
						)


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

			/**************************************************************
							BEGIN TRANSACTION
			**************************************************************/
			BEGIN TRAN

			/**************************************************************
							SAVE INSPECTION
			**************************************************************/
			IF(@InspectionId > 0)
			   BEGIN
				  UPDATE Inspection.[Inspection]
					SET    [TenantId] = @TenantId
						, [VisitTypeId] = NULLIF(f.VisitTypeId, 0)
						, [InspectionStartTime] = f.StartTime
						, [InspectionEndTime] = f.EndTime
						, [InsectMonitorsFound] = f.InsectMonitorsFound
						, [BaitPointsFound] = f.BaitPointsFound
						, [HygieneLevelId] = NULLIF(f.HygieneLevelId, 0)
						, [FollowUpDate] = @FollowUpDate
						, [FollowUpAmPm] = @FollowUpAmPm
						, [FollowUpNotes] = f.FollowUpNotes
						, [FollowUpId] = NULLIF(f.FollowUpId, 0)
						, [FollowUpInspectionId] = @FollowUpInspectionId
						, [JobClosed] = f.JobClosed
						, [JobClosedDate] = CASE
												WHEN f.JobClosed = 1 THEN CURRENT_TIMESTAMP
												ELSE NULL
											END
						, [AmountPaid] = f.PaymentAmount
						, [PaymentTypeId] = NULLIF(f.PaymentTypeId, 0)
						, [Notes] = f.Notes
						, [TenantSignature] = f.TenantSignature
						, [OfficerSignature] = f.UserSignature
						, [LastUpdated] = CURRENT_TIMESTAMP
						, [LastUpdatedBy] = -1
						, [StatusId] = @StatusId
				   FROM @Form AS f
				   WHERE Inspection.Inspection.InspectionId = @InspectionId

				   /************************************
						  LOG EVENT
				  ************************************/
				  EXEC [Log].LogEvent 
						@ProcessName = @ProcessName
					   , @InspectionId = @InspectionId
					   , @Message = 'Successfully updated inspection record.'

			   END
			ELSE
			   BEGIN
				  -- INSERT THE TENANT, PROPERTY?, AND INSPECTION DETAILS HERE. DONT FORGET TO OUTPUT THE INSPECTIONID INTO THE @InspectionId VARIABLE

				  /**************************************************************
						DO SOMETHING WITH THE ADDRESS IF AD HOC INSPECTION
				  **************************************************************/



				  /************************************
							LOG EVENT
				  ************************************/
				  EXEC [Log].LogEvent 
						@ProcessName = @ProcessName
						, @InspectionId = @InspectionId
						, @Message = 'InspectionId does not exists. Successfully created a new inspection record.'


			   END



			/**************************************************************
					LOOP THROUGH PestTreatments AND SAVE
			**************************************************************/
			DECLARE @ResultTable TABLE(
			   Id INT
			)

			DECLARE @Counter INT
				  , @Max INT
				  , @NewPestTreatmentId INT
				  , @a XML
				  , @t XML

			SET @Max = (SELECT COUNT(*) FROM @PestTreatment)
			SET @Counter = 1

			WHILE @Counter <= @Max
			   BEGIN

				  SET @NewPestTreatmentId = 0

				  -- GET AREA AND TREATMENT XMLs
				  SELECT @a = Areas
						, @t = Treatments
				  FROM @PestTreatment
				  WHERE PestTreatmentId = @Counter

				  -- INSERT TREATMENT AND CAPTURE NEW PestTreatmentId
				  INSERT INTO Inspection.PestTreatment(
					   InspectionId
					 , PestId
					 , InfestationLevelId
					 , InsectMonitorCount
					 , BaitPointCount
					 , RefrainForHours
				  ) OUTPUT INSERTED.PestTreatmentId INTO @ResultTable(Id)
				  SELECT @InspectionId
						, PestId
						, InfestationLevelId
						, MonitorsUsed
						, BaitPointsUsed
						, RefrainUsingFor
				  FROM @PestTreatment
				  WHERE PestTreatmentId = @Counter

				  -- UPDATE THE TABLE VARIABLE WITH THE NEW PestTreatmentId
				  SET @NewPestTreatmentId = (SELECT TOP 1 Id FROM @ResultTable)

				  --UPDATE @PestTreatment
				  --SET [NewId] = @NewPestTreatmentId
				  --WHERE PestTreatmentId = @Counter


				  -- INSERT AREAS
				  INSERT INTO Inspection.TreatedArea(
					   PestTreatmentId
					 , AreaId
				  )
				  SELECT @NewPestTreatmentId
						, T.m.value('.', 'INT')
				  FROM @a.nodes('/AreaIds/int') T(m)
				  --WHERE T.m.value('.', 'INT') NOT IN (SELECT AreaId FROM Inspection.TreatedArea WHERE PestTrea)

				  -- INSERT TREATMENTS
				  INSERT INTO Inspection.TreatmentUsed(
					   PestTreatmentId
					 , TreatmentId
				  )
				  SELECT @NewPestTreatmentId
						, T.m.value('.', 'INT')
				  FROM @t.nodes('/TreatmentIds/int') T(m)

				  -- REMOVE ID's FROM RESULTS TABLE VARIABLE
				  DELETE FROM @ResultTable

				  -- UPDATE COUNTER
				  SET @Counter = @Counter + 1

			   END


			   /************************************
					   LOG EVENT
			   ************************************/
			   EXEC [Log].LogEvent 
					 @ProcessName = @ProcessName
					, @InspectionId = @InspectionId
					, @Message = 'Successfully saved PestTreatments.'


			/**************************************************************
							SAVE CONDITIONS
			**************************************************************/

			-- SAVE RISK ASSESSMENTS
			INSERT INTO Inspection.RiskAssessment(
				InspectionId
			   , RiskAssessmentId
			)
			SELECT @InspectionId
				  , ConditionId
			FROM @Conditions
			WHERE ConditionType = 'RiskAssessment'
			AND ConditionId NOT IN (SELECT RiskAssessmentId FROM Inspection.RiskAssessment WHERE InspectionId = @InspectionId)


			-- SAVE STANDARD COMMENTS
			INSERT INTO Inspection.StandardComment(
				InspectionId
			   , StandardCommentId
			)
			SELECT @InspectionId
				  , ConditionId
			FROM @Conditions
			WHERE ConditionType = 'StandardComment'
			AND ConditionId NOT IN (SELECT StandardCommentId FROM Inspection.StandardComment WHERE InspectionId = @InspectionId)

			-- SAVE HYGIENE COMMENTS
			INSERT INTO Inspection.HygieneComment(
				InspectionId
			   , HygieneCommentId
			)
			SELECT @InspectionId
				  , ConditionId
			FROM @Conditions
			WHERE ConditionType = 'HygieneComment'
			AND ConditionId NOT IN (SELECT HygieneCommentId FROM Inspection.HygieneComment WHERE InspectionId = @InspectionId)


			   /************************************
					   LOG EVENT
			   ************************************/
			   EXEC [Log].LogEvent 
					 @ProcessName = @ProcessName
					, @InspectionId = @InspectionId
					, @Message = 'Successfully saved conditions.'



			/**************************************************************
							   SAVE IMAGES
			**************************************************************/
			IF EXISTS(SELECT 1 FROM @Images)
			   BEGIN
				  INSERT INTO Inspection.Images(
					   InspectionId
					 , [Image]
				  )
				  SELECT @InspectionId
					 , [Image]
				  FROM @Images
				  WHERE [Image] NOT IN (SELECT [Image] FROM Inspection.Images WHERE InspectionId = @InspectionId)
			   END


			   /************************************
					   LOG EVENT
			   ************************************/
			   EXEC [Log].LogEvent 
					 @ProcessName = @ProcessName
					, @InspectionId = @InspectionId
					, @Message = 'Successfully saved images.'


			/**************************************************************
							COMMIT TRANSACTION :)
			**************************************************************/
			COMMIT TRAN

    
			/**************************************************************
						PRODUCE SUMMARY PDF AND SEND EMAIL :)
			**************************************************************/
			DECLARE @ExportConfigName VARCHAR(100)
					, @DocumentPath VARCHAR(255)
					, @TenantFullName NVARCHAR(200)
					, @execution_id BIGINT

			SET @ExportConfigName = 'PestControlGenerateSummaryPDF'
			SET @DocumentPath = (SELECT DestinationPath FROM [Lookup].ExportConfig WHERE ExportConfigName = @ExportConfigName)
			SET @DocumentPath = @DocumentPath + '\' + CAST(@InspectionId AS VARCHAR(10)) + '_Summary.pdf'
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
					, @EmailTemplateName = 'InspectionSummary'
					, @ExportConfigName = @ExportConfigName
					, @execution_id = @execution_id OUTPUT
				END
			ELSE
				BEGIN
					DECLARE @DocFileName VARCHAR(255)
					SET @DocFileName = CAST(@InspectionId AS VARCHAR(10)) + '_Summary.pdf'

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

			/************************************
					LOG EVENT
			************************************/
			EXEC [Log].LogEvent 
					@ProcessName = @ProcessName
				, @InspectionId = @InspectionId
				, @Message = 'Inspection already complete, skipped processing.'

		END
    /**************************************************************
				    RETURN SUCCESS :)
    **************************************************************/
    RETURN @Result
    
END TRY
BEGIN CATCH

	SET @Result = 0

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