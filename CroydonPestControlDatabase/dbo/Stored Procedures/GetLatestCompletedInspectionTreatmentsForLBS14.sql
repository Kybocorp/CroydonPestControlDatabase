

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[GetLatestCompletedInspectionTreatmentsForLBS14](
    @LastRunTime DATETIME
)
AS
BEGIN TRY

    DECLARE @Inspections TABLE(
	   InspectionId INT
    )

    DECLARE @PestTreatment TABLE(
	     PestTreatmentId INT
	   , InspectionId INT
	   , PestId INT
    )

    DECLARE @Result TABLE(
	     InspectionId INT
	   , PCC_CroydonId VARCHAR(10)
    )

    -- GET INSPECTIONS
    INSERT INTO @Inspections(InspectionId)
    SELECT InspectionId
    FROM Inspection.Inspection
    WHERE StatusId IN (SELECT StatusId FROM [Lookup].[Status] WHERE StatusDesc IN ('Complete', 'NoAccess'))
    AND LastUpdated > @LastRunTime

    -- GET PEST TREATMENTS
    INSERT INTO @PestTreatment(PestTreatmentId, InspectionId, PestId)
    SELECT PestTreatmentId
		  , InspectionId
		  , PestId
    FROM Inspection.PestTreatment
    WHERE InspectionId IN (SELECT InspectionId FROM @Inspections)
    
    
    /********************************************
				GET SCHEDULES
    ********************************************/
    
    -- GET PEST
    INSERT INTO @Result(InspectionId, PCC_CroydonId)
    SELECT T.InspectionId
		  , P.PCC_CroydonId
    FROM @PestTreatment AS T
    LEFT OUTER JOIN [Lookup].CodeConversion AS P ON P.PestControlHeading = 'Pest' AND T.PestId = P.PestControlId
    
    -- GET AREA
    INSERT INTO @Result(InspectionId, PCC_CroydonId)
    SELECT PT.InspectionId
		  , AR.PCC_CroydonId
    FROM @PestTreatment AS PT
    INNER JOIN Inspection.TreatedArea AS TA ON PT.PestTreatmentId = TA.PestTreatmentId
    LEFT OUTER JOIN [Lookup].CodeConversion AS AR ON AR.PestControlHeading = 'Area' AND TA.AreaId = AR.PestControlId

    -- GET RISK ASSESSMENT
    INSERT INTO @Result(InspectionId, PCC_CroydonId)
    SELECT RA.InspectionId
		  , R.PCC_CroydonId
    FROM Inspection.RiskAssessment AS RA
    INNER JOIN [Lookup].CodeConversion AS R ON R.PestControlHeading = 'RiskAssessment' AND RA.RiskAssessmentId = R.PestControlId

    -- GET STANDARD COMMENTS
    INSERT INTO @Result(InspectionId, PCC_CroydonId)
    SELECT SC.InspectionId
		  , S.PCC_CroydonId
    FROM Inspection.StandardComment AS SC
    INNER JOIN [Lookup].CodeConversion AS S ON S.PestControlHeading = 'StandardComments' AND SC.StandardCommentId = S.PestControlId

    -- GET TREATMENT
    INSERT INTO @Result(InspectionId, PCC_CroydonId)
    SELECT PT.InspectionId
		  , T.PCC_CroydonId
    FROM @PestTreatment AS PT
    INNER JOIN Inspection.TreatmentUsed AS TM ON PT.PestTreatmentId = TM.PestTreatmentId
    LEFT OUTER JOIN [Lookup].CodeConversion AS T ON T.PestControlHeading = 'Area' AND TM.TreatmentId = T.PestControlId



    /********************************************
				RETURN RESULTS
    ********************************************/

    SELECT InspectionId
		  , PCC_CroydonId
    FROM @Result


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
