

/****** Object:  StoredProcedure [dbo].[UpdateBlockCycle]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[UpdateBlockCycle](
      @BlockCycleId INT
    , @StartDate DATE
    , @EndDate DATE
    , @StatusId INT
)
AS
BEGIN TRY

    IF EXISTS(SELECT 1 FROM Inspection.BlockCycle WHERE BlockCycleId = @BlockCycleId)
	   BEGIN
		 
		  UPDATE Inspection.BlockCycle
		  SET EndDate = @EndDate
			 , StatusId = @StatusId
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
