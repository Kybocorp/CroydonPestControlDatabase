
/****** Object:  StoredProcedure [dbo].[GetUnassignedBlocksByBlockCycleId]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[GetUnassignedBlocksByBlockCycleId](
    @BlockCycleId INT
)
AS
BEGIN TRY

    SELECT B.BlockId
		  , B.BlockName
    FROM Property.Block AS B
    WHERE B.BlockId NOT IN (SELECT BlockId FROM Inspection.BlockCycleBlock WHERE BlockCycleId = @BlockCycleId)
    AND [Enabled] = 1
    ORDER BY B.BlockName
    
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
