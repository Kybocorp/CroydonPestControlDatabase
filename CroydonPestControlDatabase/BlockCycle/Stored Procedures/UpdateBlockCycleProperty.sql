

/****** Object:  StoredProcedure [dbo].[UpdateBlockCycleProperty]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[UpdateBlockCycleProperty](
      @BlockCycleId INT
    , @PropertyId INT
    , @StatusId INT
    , @AmPm CHAR(2)
    , @NextInspectionDate DATE
    , @Comments VARCHAR(1000)
    , @LastUpdatedBy INT = NULL
)
AS
BEGIN TRY

    IF EXISTS(SELECT 1 FROM Inspection.BlockCycleProperty WHERE BlockCycleId = @BlockCycleId AND PropertyId = @PropertyId)
	   BEGIN

		  UPDATE Inspection.BlockCycleProperty
		  SET   [StatusId] = @StatusId
			 , [AmPm] = @AmPm
			 , [NextInspectionDate] = @NextInspectionDate
			 , [Comments] = @Comments
			 , [LastUpdated] = CURRENT_TIMESTAMP
			 , [LastUpdatedBy] = @LastUpdatedBy
		  WHERE BlockCycleId = @BlockCycleId
		  AND PropertyId = @PropertyId

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
