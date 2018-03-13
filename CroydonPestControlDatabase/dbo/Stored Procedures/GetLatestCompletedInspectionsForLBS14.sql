


/****** Object:  StoredProcedure [dbo].[ProcessInspectionUpdates]    Script Date: 15/05/2017 16:00:57 ******/
CREATE PROC [dbo].[GetLatestCompletedInspectionsForLBS14](
    @LastRunTime DATETIME
)
AS
BEGIN TRY

    SELECT P.AltPropertyId AS [UID]
		  , 'PCV' AS Typecode
		  , '' AS [Filename]
		  , I.InspectionDate AS Opendate
		  , VT.PCC_CroydonId AS VisitType -- PV2 FollowUp, PV5 Reactive
		  , I.LastUpdated AS date_modified
		  , I.InspectionStartTime AS ResponseDate
		  , P.HouseNo AS HouseNumber
		  , P.Street AS VHStreet
		  , P.Postcode AS VHPostCode
		  , COALESCE(T.FirstName + ' ', '') + COALESCE(T.LastName, '') AS Name
		  , CAST(DATEPART(HOUR, I.InspectionStartTime) AS CHAR(2)) + ':' + CAST(DATEPART(MINUTE, I.InspectionStartTime) AS CHAR(2)) AS TimeReceived
		  , CAST(DATEPART(HOUR, I.InspectionEndTime) AS CHAR(2)) + ':' + CAST(DATEPART(MINUTE, I.InspectionEndTime) AS CHAR(2)) AS TimeResponded
		  , COALESCE(O.FirstName + ' ', '') + COALESCE(O.LastName, '') AS UDWstring1 -- Technicians Name
		  , '' AS UDWstring5 -- Refrain from using
		  , NA.PCC_CroydonId AS UDWCode1 -- Reason No Access
		  , '' AS UDWCode2 -- Charge
		  , '' AS UDWCode3 -- Access? (Yes or Noo)
		  , CASE
				WHEN I.JobClosed = 1 THEN 'JBC'
				WHEN I.FollowUpId IS NOT NULL THEN 'FUP'
				ELSE ''
		    END UDWCode4 -- Job Closed? (Follow-Up or JC)
		  , NULL AS UDWflag3 -- Infestation Level
		  , NULL AS UDWflag5 -- H ORders Only
		  , NULL AS UDWflag6 -- Access To Dwelling
		  , LEFT(HL.HygieneLevelDesc, 1) AS UDWflag7 -- Hygiene Level
		  , NULL AS UDWflag8 -- Flat Warm and Humid
		  , NULL AS UDWflag9 -- Flat Cluttured
		  , NULL AS UDWflag10 -- Area Overgrown
		  , NULL AS UDWflag11 -- Kitchen Dirty
		  , NULL AS UDWflag12 -- Advised Tenant
		  , NULL AS UDWreal1 -- No of Monitors
		  , NULL AS UDWreal2 -- No of Baits
		  , I.InsectMonitorsFound AS UDWreal3 -- No of Monitors Found
		  , I.BaitPointsFound AS UDWreal4 -- No of Baits Found
		  , NULL AS UDWreal6 -- Visit No
		  , I.AmountPaid AS UDWmoney1 -- Charge Amount
		  , NULL AS ChaplinFormId
		  , I.OfficerId AS userId
		  , I.InspectionId AS API_UID
		  , I.Notes AS Notes
    FROM Inspection.Inspection AS I
    LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
    LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
    LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
    LEFT OUTER JOIN [Lookup].CodeConversion AS VT ON VT.PestControlHeading = 'VisitType' AND I.VisitTypeId = VT.PestControlId
    LEFT OUTER JOIN [Lookup].CodeConversion AS NA ON NA.PestControlHeading = 'NoAccess' AND I.NoAccessId = NA.PestControlId
    LEFT OUTER JOIN [Lookup].HygieneLevel AS HL ON I.HygieneLevelId = HL.HygieneLevelId
    WHERE I.StatusId > 1
    AND I.LastUpdated > @LastRunTime

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
