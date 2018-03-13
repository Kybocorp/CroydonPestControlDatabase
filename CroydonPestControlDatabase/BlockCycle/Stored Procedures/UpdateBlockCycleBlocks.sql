

/****** Object:  StoredProcedure [dbo].[UpdateBlockCycleBlocks]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [BlockCycle].[UpdateBlockCycleBlocks](
      @BlockList XML
    , @Result INT OUTPUT
)
AS
BEGIN TRY

    DECLARE @Blocks TABLE(
	     BlockId INT
	   , StartDate DATETIME
    )
    
    DECLARE @BlockCycleId INT
		  , @Valid BIT
		  , @ValidationMessage VARCHAR(255)

    SET @Valid = 1
    -- SET @BlockCycleId = SOMETHING FROM THE XML


    /**************************************************
				VALIDATION CHECKS
    **************************************************/

    IF NOT EXISTS (SELECT 1 FROM Inspection.BlockCycle WHERE BlockCycleId = @BlockCycleId)
	   BEGIN
		  SET @Valid = 0
		  SET @ValidationMessage = 'Invalid Block Cycle'
	   END

    IF EXISTS (SELECT 1 FROM @Blocks WHERE BlockId NOT IN (SELECT BlockId FROM Property.Block))
	   BEGIN
		  SET @Valid = 0
		  SET @ValidationMessage = 'Invalid Block'
	   END

    IF EXISTS (SELECT 1 FROM @Blocks WHERE ISDATE(StartDate) <> 1)
	   BEGIN
		  SET @Valid = 0
		  SET @ValidationMessage = 'Invalid Start Date'
	   END

    /**************************************************
		  DO SOMETHING HERE TO EXTRACT THE
			 BLOCKIDS FROM THE XML
    **************************************************/

    IF @Valid = 1
	   BEGIN
		 
		  -- ADD BLOCKS TO BLOCK CYCLE
		  INSERT INTO Inspection.BlockCycleBlock(
			   BlockCycleId
			 , BlockId
			 , StartDate
			 , StatusId
		  )
		  SELECT @BlockCycleId
				, BlockId
				, StartDate
				, 1
		  FROM @Blocks
		  WHERE BlockId NOT IN (SELECT BlockId FROM Inspection.BlockCycleBlock WHERE BlockCycleId = @BlockCycleId)

		  
		  --ADD PROPERTIES TO BLOCK CYCLE
		  INSERT INTO Inspection.BlockCycleProperty(
			   [BlockCycleId]
			 , [PropertyId]
			 , [StatusId]
			 , [AmPm]
			 , [NextInspectionDate]
			 , [Comments]
			 , [LastUpdated]
			 , [LastUpdatedBy]
		  )
		  SELECT @BlockCycleId
			 , P.PropertyId
			 , 1 -- StatusId
			 , NULL -- AMPM
			 , B.StartDate
			 , NULL -- COMMENTS
			 , CURRENT_TIMESTAMP
			 , NULL -- LastUpdatedBy
		  FROM @Blocks AS B
		  INNER JOIN Property.Property AS P ON B.BlockId = P.BlockId

	   END
    
    SET @Result = @Valid

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

