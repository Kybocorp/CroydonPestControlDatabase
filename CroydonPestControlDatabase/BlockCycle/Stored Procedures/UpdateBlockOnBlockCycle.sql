

/****** Object:  StoredProcedure [dbo].[UpdateBlockOnBlockCycle]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[UpdateBlockOnBlockCycle](
      @BlockCycleId INT
    , @BlockId INT
    , @StartDate DATE
    , @EndDate DATE
    , @StatusId INT
    , @DeleteBlock BIT = 0
)
AS
BEGIN TRY

    IF EXISTS(SELECT 1 FROM Inspection.BlockCycleBlock WHERE BlockCycleId = @BlockCycleId AND BlockId = @BlockId)
	   BEGIN

		  IF @DeleteBlock = 1
			 BEGIN

				DELETE FROM Inspection.BlockCycleBlock
				WHERE BlockCycleId = @BlockCycleId
				AND BlockId = @BlockId

				DELETE FROM Inspection.BlockCycleProperty
				WHERE BlockCycleId = @BlockCycleId
				AND PropertyId  IN (SELECT PropertyId FROM Property.Property WHERE BlockId = @BlockId)

			 END
		  ELSE
			 BEGIN

				UPDATE Inspection.BlockCycleBlock
				SET StartDate = @StartDate
				    , EndDate = @EndDate
				    , StatusId = @StatusId
				WHERE BlockCycleId = @BlockCycleId
				AND BlockId = @BlockId

			 END

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
