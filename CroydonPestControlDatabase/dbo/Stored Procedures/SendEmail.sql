CREATE PROC [dbo].[SendEmail]
	  @InspectionId INT
	, @ContactName NVARCHAR(100)
	, @AttachmentPath NVARCHAR(1000)
	, @EmailAddress VARCHAR(255)
	, @EmailTemplateName VARCHAR(100)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
			, @EmailHTML VARCHAR(7000)
			, @EmailSubject VARCHAR(255)

    SET @ProcessName = OBJECT_NAME(@@PROCID)

	SELECT @EmailHTML = EmailHTML
			, @EmailSubject = EmailSubject
	FROM [Lookup].EmailTemplate
	WHERE EmailTemplateName = @EmailTemplateName

	SET @EmailSubject = @EmailSubject + ' - ' + CONVERT(VARCHAR, CURRENT_TIMESTAMP, 103)

	EXEC [Monitor].[dbo].[SendEmail]
      @MailTo = @EmailAddress
      , @MailCC = ''
      , @EmailSub = @EmailSubject
      , @MessageBody = @EmailHTML
	  , @AttachmentPath = @AttachmentPath

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
		  , @InspectionId = @InspectionId
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH
