
CREATE PROC [dbo].[GetTreatmentConfig](
    @EnabledOnly BIT = 1
	, @Config XML OUTPUT
)
AS
BEGIN TRY

	SET @Config = (
			SELECT (
				  SELECT TreatmentId
						, TreatmentDesc
						, ActiveIngredient
						, RegistrationNo
				  FROM [Lookup].Treatment
				  WHERE [Enabled] >= @EnabledOnly
				  ORDER BY TreatmentDesc
				  FOR XML PATH('Treatment'), ROOT('Treatments'), ELEMENTS, TYPE
			   ),
			   (
				  SELECT PestId
						, TreatmentId
				  FROM [Lookup].PestTreatmentRelation
				  WHERE TreatmentId IN (SELECT TreatmentId FROM [Lookup].Treatment WHERE [Enabled] = 1)
				  AND PestId IN (SELECT PestId FROM [Lookup].Pest WHERE [Enabled] = 1)
				  FOR XML PATH('PestTreatment'), ROOT('PestTreatmentRelations'), ELEMENTS, TYPE
			   )
			FOR XML PATH('Config')
		)
			
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

