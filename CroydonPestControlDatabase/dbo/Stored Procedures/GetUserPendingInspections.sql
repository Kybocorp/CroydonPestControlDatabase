
CREATE PROC [dbo].[GetUserPendingInspections](
    @UserId INT
    , @Inspections XML OUTPUT
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

    --IF(@UserId > 0)
	   --BEGIN

		  /************************************
				    RETURN DATA
		  ************************************/
	   SET @Inspections = (
		  SELECT I.InspectionId
				, I.InspectionDate
				, LOWER(S.StatusDesc) AS [Status]
				, I.AmPm
				, I.FollowUpNotes
				, COALESCE(NULLIF(LTRIM(RTRIM(P.HouseName)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.HouseNo)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.Street)), ''), '') AS InspectionTitle
				, 'ID:' + CAST(I.InspectionId AS VARCHAR(10)) + ' - ' + COALESCE(I.AmPm, '') + COALESCE(' - ' + I.FollowUpNotes, '') AS InspectionSubTitle
				, I.OfficerId AS [Officer/OfficerId]
				, COALESCE(LTRIM(RTRIM(O.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(O.LastName)), '') AS [Officer/OfficerDisplayName]
				, CAST(1 AS BIT) AS PestControlForm
				, T.TenantId AS [Tenant/TenantId]
				, COALESCE(LTRIM(RTRIM(T.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(T.LastName)), '') AS [Tenant/TenantDisplayName]
				, T.FirstName AS [Tenant/FirstName]
				, T.LastName AS [Tenant/LastName]
				, T.Telephone AS [Tenant/Telephone]
				, T.Email AS [Tenant/Email]
				, T.IsDangerous AS [Tenant/IsDangerous]
				, P.PropertyId AS [Address/PropertyId]
				, P.HouseName AS [Address/HouseName]
				, P.HouseNo AS [Address/HouseNo]
				, P.Street AS [Address/Street]
				, P.AddressLine1 AS [Address/AddressLine1]
				, P.AddressLine2 AS [Address/AddressLine2]
				, P.PostCode AS [Address/PostCode]
				, P.Longitude AS [Address/Longitude]
				, P.Latitude AS [Address/Latitude]
				, 'Inspection Date' AS [PreviousInspection/HistoryItem/Title]
				, CONVERT(VARCHAR, LI.InspectionDate) AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Technician' AS [PreviousInspection/HistoryItem/Title]
				, COALESCE(LIO.FirstName + ' ', '') + COALESCE(LIO.LastName, '') AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Pests Found' AS [PreviousInspection/HistoryItem/Title]
				, LIT.Pests AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Areas' AS [PreviousInspection/HistoryItem/Title]
				, LIT.Areas AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Treatment Used' AS [PreviousInspection/HistoryItem/Title]
				, LIT.Treatments AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Monitors' AS [PreviousInspection/HistoryItem/Title]
				, LIT.InsectMonitorCount AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Bait Points' AS [PreviousInspection/HistoryItem/Title]
				, LIT.BaitPointCount AS [PreviousInspection/HistoryItem/Description]
				, NULL AS [PreviousInspection]
				, 'Notes' AS [PreviousInspection/HistoryItem/Title]
				, LI.Notes AS [PreviousInspection/HistoryItem/Description]
		  FROM Inspection.Inspection AS I
		  LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
		  LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
		  LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
		  LEFT OUTER JOIN [Lookup].[Status] AS S ON I.StatusId = S.StatusId
		  LEFT OUTER JOIN Inspection.Inspection AS LI ON I.InspectionId = LI.FollowUpInspectionId
		  LEFT OUTER JOIN dbo.Officer AS LIO ON LI.OfficerId = LIO.OfficerId
		  LEFT OUTER JOIN (
				    SELECT T.InspectionId
						  , MAX(T.Pest) AS Pests
						  , MAX(T.Area) AS Areas
						  , MAX(T.Treatment) AS Treatments
						  , SUM(T.InsectMonitorCount) AS InsectMonitorCount
						  , SUM(T.BaitPointCount) AS BaitPointCount
				    FROM (
						  SELECT PT.InspectionId
								, SUBSTRING(
								    (
									   SELECT DISTINCT ', ' + P.PestName AS [text()]
									   FROM Inspection.PestTreatment AS PT1
									   INNER JOIN [Lookup].Pest AS P ON PT1.PestId = P.PestId
									   WHERE PT1.InspectionId = PT.InspectionId
									   FOR XML PATH ('')
								    ), 2, 500) [Pest]
								, SUBSTRING(
								    (
									   SELECT DISTINCT ', ' + L.AreaDesc AS [text()]
									   FROM Inspection.PestTreatment AS PT1
									   INNER JOIN Inspection.TreatedArea AS A ON PT1.PestTreatmentId = A.PestTreatmentId
									   INNER JOIN [Lookup].Area AS L ON A.AreaId = L.AreaId
									   WHERE PT1.InspectionId = PT.InspectionId
									   FOR XML PATH ('')
								    ), 2, 500) [Area]
								, SUBSTRING(
								    (
									   SELECT DISTINCT ', ' + L.TreatmentDesc AS [text()]
									   FROM Inspection.PestTreatment AS PT1
									   INNER JOIN Inspection.TreatmentUsed AS T ON PT1.PestTreatmentId = T.PestTreatmentId
									   INNER JOIN [Lookup].Treatment AS L ON T.TreatmentId = L.TreatmentId
									   WHERE PT1.InspectionId = PT.InspectionId
									   FOR XML PATH ('')
								    ), 2, 500) [Treatment]
								, PT.InsectMonitorCount
								, PT.BaitPointCount
						  FROM Inspection.PestTreatment AS PT
					   ) [T]
				    GROUP BY T.InspectionId
			 ) AS LIT ON LI.InspectionId = LIT.InspectionId
		  WHERE I.OfficerId = @UserId
		  AND I.Deleted = 0
		  AND CAST(I.InspectionDate AS DATE) = CAST(GETDATE() AS DATE)
		  AND S.StatusDesc IN ('Pending', 'NoAccess')
		  FOR XML PATH('Inspection'), ROOT('Config'), ELEMENTS
	   )

	   --END
    --ELSE
	   --BEGIN
	   /*
		  /************************************
				  LOG EVENT
		  ************************************/
		  EXEC [Log].LogEvent 
				@ProcessName = @ProcessName
			   , @OfficerId = @UserId
			   , @Message = 'Error retrieving users pending inspections. Invalid UserId supplied'
			   , @IsError = 1
		  */
	   --END

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

