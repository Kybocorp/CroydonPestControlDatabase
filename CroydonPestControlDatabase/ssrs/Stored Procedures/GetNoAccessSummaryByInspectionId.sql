CREATE PROC [ssrs].[GetNoAccessSummaryByInspectionId](
      @InspectionId INT
)
AS
BEGIN TRY
    
    SELECT I.InspectionId
		  , CONVERT(VARCHAR(20), I.InspectionDate, 103) AS InspectionDate
		  , CONVERT(VARCHAR, I.NoAccessTime, 106) + ' ' + LEFT(CAST(I.NoAccessTime AS TIME(0)), 5) AS NoAccessTime
		  , COALESCE(O.FirstName + ' ', '') + COALESCE(O.LastName, '') AS Officer
		  , LTRIM(RTRIM(COALESCE(P.PropertyName, ''))) AS PropertyName
		  , LTRIM(RTRIM(COALESCE(P.HouseName, ''))) AS HouseName
		  , LTRIM(RTRIM(COALESCE(P.HouseNo, ''))) AS HouseNo
		  , LTRIM(RTRIM(COALESCE(P.Street, ''))) AS Street
		  , LTRIM(RTRIM(COALESCE(P.AddressLine1, ''))) AS AddressLine1
		  , LTRIM(RTRIM(COALESCE(P.AddressLine2, ''))) AS AddressLine2
		  , LTRIM(RTRIM(COALESCE(P.Postcode, ''))) AS Postcode
		  , COALESCE(T.FirstName + ' ', '') + COALESCE(T.LastName, '') AS TenantName
		  , COALESCE(CONVERT(VARCHAR(20), FollowUpDate, 103), '') AS FollowUpDate
		  , COALESCE(I.FollowUpAmPm, '') AS FollowUpAmPm
		  , NA.NoAccessDesc AS ReasonNoAccess
    FROM Inspection.Inspection AS I
    LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
    LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
    LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
    LEFT OUTER JOIN [Lookup].NoAccess AS NA ON I.NoAccessId = NA.NoAccessId
    WHERE I.InspectionId = @InspectionId

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
