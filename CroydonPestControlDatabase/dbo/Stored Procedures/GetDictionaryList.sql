
CREATE PROC [dbo].[GetDictionaryList](
    @EnabledOnly BIT = 1
    , @Result XML OUTPUT
)
AS
BEGIN TRY

    SET @Result = (

	   SELECT (
			 SELECT 'Area' [DictionaryType],(
				SELECT AreaId AS Id
				    , AreaDesc AS [Description]
				FROM [Lookup].Area
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
		  ), 
		  (
			 SELECT 'Diary' [DictionaryType],(
				SELECT DiaryId AS Id
				    , DiaryDesc AS [Description]
				FROM [Lookup].Diary
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
		  ),
		  (
			 SELECT 'HygieneComment' [DictionaryType],(
				SELECT HygieneCommentId AS Id
				    , HygieneCommentDesc AS [Description]
				FROM [Lookup].HygieneComment
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'HygieneLevel' [DictionaryType],(
				SELECT HygieneLevelId AS Id
				    , HygieneLevelDesc AS [Description]
				FROM [Lookup].HygieneLevel
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'InfestationLevel' [DictionaryType],(
				SELECT InfestationLevelId AS Id
				    , InfestationLevelDesc AS [Description]
				FROM [Lookup].InfestationLevel
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY Id
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'NoAccess' [DictionaryType],(
				SELECT NoAccessId AS Id
				    , NoAccessDesc AS [Description]
				FROM [Lookup].NoAccess
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'PaymentType' [DictionaryType],(
				SELECT PaymentTypeId AS Id
				    , PaymentTypeDesc AS [Description]
				FROM [Lookup].PaymentType
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'Pest' [DictionaryType],(
				SELECT PestId AS Id
				    , PestName AS [Description]
				FROM [Lookup].Pest
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'RiskAssessment' [DictionaryType],(
				SELECT RiskAssessmentId AS Id
				    , RiskAssessmentDesc AS [Description]
				FROM [Lookup].RiskAssessment
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'StandardComment' [DictionaryType],(
				SELECT StandardCommentId AS Id
				    , StandardCommentDesc AS [Description]
				FROM [Lookup].StandardComment
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  ), 
		  (
			 SELECT 'VisitType' [DictionaryType],(
				SELECT VisitTypeId AS Id
				    , VisitTypeDesc AS [Description]
				FROM [Lookup].VisitType
				WHERE [Enabled] >= @EnabledOnly
				ORDER BY [Description]
				FOR XML PATH('DictionaryItem'), ROOT('DictionaryItems'), ELEMENTS, TYPE)
			 FOR XML PATH('DictionaryList'), TYPE
    		  )
	   FOR XML PATH('Config')
    )

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
