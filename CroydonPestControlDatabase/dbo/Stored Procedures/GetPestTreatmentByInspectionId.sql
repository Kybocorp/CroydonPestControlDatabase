

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[GetPestTreatmentByInspectionId](
      @InspectionId INT
)
AS
BEGIN TRY
    
    SELECT P.PestName AS Pest
		  , I.InfestationLevelDesc AS InfestationLevel
		  , PT.RefrainForHours AS RefrainFor
		  , STUFF((SELECT ', ' + A.AreaDesc
				FROM Inspection.TreatedArea AS TA
				INNER JOIN [Lookup].Area AS A ON TA.AreaId = A.AreaId
				WHERE TA.PestTreatmentId = PT.PestTreatmentId
				FOR XML PATH('')), 1, 1, '') AS AreasTreated
    FROM Inspection.PestTreatment AS PT
    LEFT OUTER JOIN [Lookup].Pest AS P ON PT.PestId = P.PestId
    LEFT OUTER JOIN [Lookup].InfestationLevel AS I ON PT.InfestationLevelId = I.InfestationLevelId
    WHERE PT.InspectionId = @InspectionId
    GROUP BY P.PestName, I.InfestationLevelDesc, PT.RefrainForHours, PestTreatmentId
    ORDER BY Pest

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
