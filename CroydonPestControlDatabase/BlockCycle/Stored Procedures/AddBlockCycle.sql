
CREATE PROC [BlockCycle].[AddBlockCycle](
      @StartDate DATETIME
    , @EndDate DATETIME = NULL
)
AS
BEGIN TRY
    
    DECLARE @BlockCycleId TABLE(
	   BlockCycleId INT
    )
    
    DECLARE @NewId INT

    INSERT INTO Inspection.BlockCycle(
	     StartDate
	   , EndDate
	   , StatusId
    ) OUTPUT INSERTED.BlockCycleId INTO @BlockCycleId(BlockCycleId)
    VALUES(
	     CAST(@StartDate AS DATE)
	   , CAST(@EndDate AS DATE)
	   , 1
    )


    -- RETURN NEWLY CREATED BLOCK CYCLE ID
    SET @NewId = (SELECT TOP 1 BlockCycleId FROM @BlockCycleId)

    SELECT BlockCycleId
		  , StartDate
		  , EndDate
    FROM Inspection.BlockCycle
    WHERE BlockCycleId = @NewId
    
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



/****** Object:  StoredProcedure [dbo].[AddBlockToBlockCycle]    Script Date: 15/05/2017 16:00:57 ******/
SET ANSI_NULLS ON
