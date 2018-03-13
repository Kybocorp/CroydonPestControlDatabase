
CREATE PROC [dbo].[GetOfficers](
    @EnabledOnly INT = 1
)
AS
BEGIN TRY

    SELECT OfficerId
		  , FirstName
		  , LastName
		  , COALESCE(LTRIM(RTRIM(FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(LastName)), '') AS OfficerDisplayName
		  , Username
		  , Email
		  , TeamId
    FROM dbo.Officer
    WHERE [Enabled] >= @EnabledOnly
    ORDER BY OfficerDisplayName
    
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

