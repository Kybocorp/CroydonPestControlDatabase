


/****** Object:  StoredProcedure [BlockCycle].[GetPropertiesByBlockId]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[GetPropertiesByBlockId](
        @BlockCycleId INT
	 , @BlockId INT
)
AS
BEGIN TRY

    IF EXISTS(SELECT 1 FROM [Inspection].[BlockCycleBlock] WHERE BlockId = @BlockId)
	   BEGIN

		  SELECT P.PropertyId
				, COALESCE(NULLIF(LTRIM(RTRIM(P.HouseName)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.HouseNo)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.Street)), ''), '') AS [Address]
				, BP.AmPm
				, BP.NextInspectionDate
				, BP.Comments
				, BP.StatusId
		  FROM Inspection.BlockCycleProperty AS BP
		  INNER JOIN Property.Property AS P ON P.BlockId = @BlockId AND BP.PropertyId = P.PropertyId
		  WHERE BlockCycleId = @BlockCycleId		  

	   END

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
