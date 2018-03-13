
CREATE PROC [dbo].[AddBlockToBlockCycle](
      @BlockCycleId INT
    , @BlockId INT
    , @StartDate DATETIME
)
AS
BEGIN TRY

    DECLARE @Valid BIT = 1

    -- VALIDATE PARAMETERS RECEIVED
    IF (@BlockCycleId <= 0) SET @Valid = 0
    IF (@BlockId <= 0) SET @Valid = 0
    IF (ISDATE(@StartDate) <> 1) SET @Valid = 0

    IF (@Valid = 1)
    BEGIN
    
	   -- INSERT BLOCKS TO BLOCK CYCLE
	   INSERT INTO Inspection.BlockCycleBlock(
		    BlockCycleId
		  , BlockId
		  , StartDate
	   )
	   VALUES(
		    @BlockCycleId
		  , @BlockId
		  , @StartDate
	   )


	   -- INSERT PROPERTIES FOR BLOCKS
	   INSERT INTO Inspection.BlockCycleProperty(
		    BlockCycleId
		  , PropertyId
		  , StatusId
	   )
	   SELECT @BlockCycleId
			 , PropertyId
			 , 1 -- ACTIVE
	   FROM Property.Property
	   WHERE BlockId = @BlockId
	   AND [Enabled] = 1

	   /************************************************************************
			 DO SOME STUFF HERE TO CREATE INSPECTIONS FOR PROPERTIES
			 ONCE CREATED, UPDATE THE BlockCycleProperty TABLE WITH THE NEW ID
	   ************************************************************************/


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