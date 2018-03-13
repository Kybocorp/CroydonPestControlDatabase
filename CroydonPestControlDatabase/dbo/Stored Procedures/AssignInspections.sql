
CREATE PROC [dbo].[AssignInspections](
    @UserId INT
    , @AssignedBy INT
    , @Inspections VARCHAR(255)
    , @Result BIT OUTPUT
)
AS
BEGIN TRY

    SET NOCOUNT ON
    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

    /********************************************************
				INSERT INTO AUDIT TABLE
    ********************************************************/
    INSERT INTO [Log].[AssignInspections](
		UserId
	   , AssignedBy
	   , Inspections
    )
    VALUES(
		@UserId
	   , @AssignedBy
	   , @Inspections
    )


    /********************************************************
				UPDATE INSPECTIONS
    ********************************************************/
    SET @Result = 1

    IF(@UserId > 0)
	   BEGIN

		  UPDATE Inspection.Inspection
		  SET OfficerId = @UserId
			 , AssignedBy = @AssignedBy
			 , LastUpdated = CURRENT_TIMESTAMP
			 , LastUpdatedBy = @AssignedBy
			 , DateAssigned = CURRENT_TIMESTAMP
		  WHERE InspectionId IN (SELECT Id FROM dbo.SplitInts(@Inspections, '|'))
		  AND InspectionDate >= CAST(CURRENT_TIMESTAMP AS DATE)


		  /************************************
				    LOG EVENT
		  ************************************/
		  DECLARE @m VARCHAR(100) = 'Successfully assigned inspections: ' + @Inspections

		  EXEC [Log].LogEvent 
			   @ProcessName = @ProcessName
			 , @OfficerId = @UserId
			 , @Message = @m

	   END
    ELSE
	   BEGIN
		  
		  /************************************
				    LOG EVENT
		  ************************************/
		  EXEC [Log].LogEvent 
			   @ProcessName = @ProcessName
			 , @OfficerId = @UserId
			 , @Message = 'Error assigning inspections. Invalid UserId supplied'
			 , @IsError = 1


		  SET @Result = 0

	   END

    RETURN @Result

END TRY
BEGIN CATCH

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
		  , @OfficerId = @UserId
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH

