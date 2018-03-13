

/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [ssrs].[GetSummaryByInspectionId](
      @InspectionId INT
)
AS
BEGIN TRY
    
    SELECT I.InspectionId
		  , CONVERT(VARCHAR(20), I.InspectionDate, 103) AS InspectionDate
		  , LEFT(CAST(I.InspectionStartTime AS TIME(0)), 5) AS StartTime
		  , LEFT(CAST(I.InspectionEndTime AS TIME(0)), 5) AS EndTime
		  , DATEDIFF(MI, I.InspectionStartTime, I.InspectionEndTime) AS [Duration(Min)]
		  , COALESCE(O.FirstName + ' ', '') + COALESCE(O.LastName, '') AS Officer
		  , LTRIM(RTRIM(COALESCE(P.PropertyName, ''))) AS PropertyName
		  , LTRIM(RTRIM(COALESCE(P.HouseName, ''))) AS HouseName
		  , LTRIM(RTRIM(COALESCE(P.HouseNo, ''))) AS HouseNo
		  , LTRIM(RTRIM(COALESCE(P.Street, ''))) AS Street
		  , LTRIM(RTRIM(COALESCE(P.AddressLine1, ''))) AS AddressLine1
		  , LTRIM(RTRIM(COALESCE(P.AddressLine2, ''))) AS AddressLine2
		  , LTRIM(RTRIM(COALESCE(P.Postcode, ''))) AS Postcode
		  , COALESCE(T.FirstName + ' ', '') + COALESCE(T.LastName, '') AS TenantName
		  , VT.VisitTypeDesc AS VisitType
		  , HL.HygieneLevelDesc AS HygieneLevel
		  , COALESCE(CONVERT(VARCHAR(20), FollowUpDate, 103), '') AS FollowUpDate
		  , COALESCE(I.FollowUpAmPm, '') AS FollowUpAmPm
		  , CASE I.JobClosed
				WHEN 0 THEN 'No'
				WHEN 1 THEN 'Yes'
			 END [JobClosed]
		  , CAST(I.AmountPaid AS VARCHAR(10)) AS AmountPaid
		  , PT.PaymentTypeDesc AS PaymentType
		  , STUFF((SELECT ', ' + RAL.RiskAssessmentDesc
				FROM Inspection.RiskAssessment AS RA
				INNER JOIN [Lookup].RiskAssessment AS RAL ON RA.RiskAssessmentId = RAL.RiskAssessmentId
				WHERE RA.InspectionId = I.InspectionId
				FOR XML PATH('')), 1, 1, '') AS RiskAssessment
		  , STUFF((SELECT ', ' + SCL.StandardCommentDesc
				FROM Inspection.StandardComment AS SC
				INNER JOIN [Lookup].StandardComment AS SCL ON SC.StandardCommentId = SCL.StandardCommentId
				WHERE SC.InspectionId = I.InspectionId
				FOR XML PATH('')), 1, 1, '') AS StandardComment
		  , STUFF((SELECT ', ' + HCL.HygieneCommentDesc
				FROM Inspection.HygieneComment AS HC
				INNER JOIN [Lookup].HygieneComment AS HCL ON HC.HygieneCommentId = HCL.HygieneCommentId
				WHERE HC.InspectionId = I.InspectionId
				FOR XML PATH('')), 1, 1, '') AS HygieneComment
		  , COALESCE(I.Notes, '') AS Notes
		  , I.TenantSignature
		  , I.OfficerSignature
    FROM Inspection.Inspection AS I
    LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
    LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
    LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
    LEFT OUTER JOIN [Lookup].VisitType AS VT ON I.VisitTypeId = VT.VisitTypeId
    LEFT OUTER JOIN [Lookup].NoAccess AS NA ON I.NoAccessId = NA.NoAccessId
    LEFT OUTER JOIN [Lookup].Diary AS D ON I.DiaryId = D.DiaryId
    LEFT OUTER JOIN [Lookup].HygieneLevel AS HL ON I.HygieneLevelId = HL.HygieneLevelId
    LEFT OUTER JOIN [Lookup].PaymentType AS PT ON I.PaymentTypeId = PT.PaymentTypeId
    LEFT OUTER JOIN [Lookup].[Status] AS S ON I.StatusId = S.StatusId
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
