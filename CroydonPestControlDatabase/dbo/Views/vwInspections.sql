


-- VIEW FOR ALL INSPECTIONS
CREATE VIEW [dbo].[vwInspections]
AS
SELECT I.InspectionId
	   , CONVERT(VARCHAR(20), I.InspectionDate, 103) AS InspectionDate
	   , CAST(I.InspectionStartTime AS TIME(0)) AS StartTime
	   , CAST(I.InspectionEndTime AS TIME(0)) AS EndTime
	   , DATEDIFF(MI, I.InspectionStartTime, I.InspectionEndTime) AS [Duration(Min)]
	   , AmPm
	   , COALESCE(O.FirstName + ' ', '') + COALESCE(O.LastName, '') AS Officer
	   , LTRIM(RTRIM(COALESCE(P.PropertyName, ''))) AS PropertyName
	   , LTRIM(RTRIM(COALESCE(P.HouseName, ''))) AS HouseName
	   , LTRIM(RTRIM(COALESCE(P.HouseNo, ''))) AS HouseNo
	   , LTRIM(RTRIM(COALESCE(P.Street, ''))) AS Street
	   , LTRIM(RTRIM(COALESCE(P.AddressLine1, ''))) AS AddressLine1
	   , LTRIM(RTRIM(COALESCE(P.AddressLine2, ''))) AS AddressLine2
	   , LTRIM(RTRIM(COALESCE(P.Postcode, ''))) AS Postcode
	   , T.TenantId
	   , T.FirstName AS TenantFirstName
	   , T.LastName AS TenantLastName
	   , VT.VisitTypeDesc AS VisitType
	   , NA.NoAccessDesc AS NoAccess
	   , D.DiaryDesc AS Diary
	   , I.InsectMonitorsFound AS MonitorsFound
	   , I.BaitPointsFound
	   , HL.HygieneLevelDesc AS HygieneLevel
	   , CONVERT(VARCHAR(20), FollowUpDate, 103) AS FollowUpDate
	   , I.FollowUpAmPm
	   , COALESCE(I.FollowUpNotes, '') AS FollowUpNotes
	   , CASE I.JobClosed
			 WHEN 0 THEN 'No'
			 WHEN 1 THEN 'Yes'
		  END [JobClosed]
	   , I.AmountPaid
	   , PT.PaymentTypeDesc AS PaymentType
	   , I.Notes
	   , S.StatusDesc AS [Status]
	   , I.LastUpdated
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


