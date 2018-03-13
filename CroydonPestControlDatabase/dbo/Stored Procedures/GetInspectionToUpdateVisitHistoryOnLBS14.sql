CREATE PROC [dbo].[GetInspectionToUpdateVisitHistoryOnLBS14]
AS
SELECT I.PropertyId AS [uid]
		, '' AS laref
		, 'PCV' AS typecode
		, CASE
				WHEN D.DocumentPath IS NULL THEN DNA.DocumentPath
				ELSE D.DocumentPath + COALESCE(', ' + DNA.DocumentPath, '')
			END [filename]
		, I.InspectionDate AS opendate
		, CASE
				WHEN I.VisitTypeId = 1 THEN 'PV5'
				WHEN I.VisitTypeId = 2 THEN 'PV6'
				WHEN I.VisitTypeId = 3 THEN 'PV7'
				WHEN I.VisitTypeId = 4 THEN 'PV8'
				WHEN I.VisitTypeId = 5 THEN 'PV9'
				ELSE ''
			END visit_type
		, CURRENT_TIMESTAMP AS date_modified
		, I.InspectionStartTime AS ResponseDate
		, P.HouseNo AS HouseNumber
		, P.Street AS VHStreet
		, P.Postcode AS VHPostCode
		, P.PropertyName AS Name
		, NULL AS TimeReceived
		, I.InspectionStartTime AS TimeResponded
		, '' AS UDWstring1
		, '' AS UDWstring5
		, 'WA' + CAST(I.NoAccessId AS VARCHAR) AS UDWCode1
		, CASE
				WHEN I.PaymentTypeId = 1 THEN 'WC4'
				WHEN I.PaymentTypeId = 2 THEN 'WC3'
				WHEN I.PaymentTypeId = 3 THEN 'WC2'
				ELSE 'WC1'
			END UDWCode2 -- Charge Type
		, CASE
				WHEN I.NoAccessId > 0 THEN 'NOO'
				ELSE 'yes'
			END UDWCode3
		, CASE
				WHEN I.JobClosed = 1 THEN 'JBC'
				ELSE 'FUP'
			END UDWCode4
		, CASE
				WHEN PT.InfestationLevelId = 1 THEN 'L'
				WHEN PT.InfestationLevelId = 2 THEN 'M'
				WHEN PT.InfestationLevelId = 3 THEN 'H'
				ELSE ''
			END UDWflag3
		, '' AS UDWflag5
		, CASE
				WHEN COALESCE(PT.InfestationLevelId, 0) > 0 THEN 'T'
				ELSE 'M'
			END UDWflag6
		, CASE
				WHEN I.HygieneLevelId = 1 THEN 'B'
				WHEN I.HygieneLevelId = 2 THEN 'F'
				WHEN I.HygieneLevelId = 3 THEN 'G'
				ELSE ''
			END UDWflag7
		, HC.FlatWarmAndHumid AS UDWflag8
		, HC.FlatCluttured AS UDWflag9
		, HC.TenantGardenOvergrown AS UDWflag10 -- A
		, HC.KitchenDirty AS UDWflag11 -- Kitchen Dirty
		, HC.AdvisedToClean AS UDWflag12 -- Advised Tenant
		, PT.Monitors AS UDWreal1 -- No of Monitors
		, PT.Baits AS UDWreal2 -- No of Baits
		, I.InsectMonitorsFound AS UDWreal3 -- No of IM Found
		, I.BaitPointsFound AS UDWreal4 -- No of BP Found
		, 1 AS UDWreal6 -- Visit No				-------------------------- THIS NEEDS TO BE THE ACTUAL Visit Number
		, I.AmountPaid AS UDWmoney1 -- Charge Amount
		, NULL AS ChaplinFormId
		, I.OfficerId AS userId
		, I.InspectionId AS API_UID
		, NULL AS [signature]
		, P.HouseName AS HouseName
		, P.AddressLine1 AS Add1
		, P.AddressLine2 AS Add2
		, I.Notes AS Notes
FROM Inspection.Inspection AS I
LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
LEFT OUTER JOIN Inspection.Document AS D ON I.InspectionId = D.InspectionId AND D.DocumentTypeId = 1
LEFT OUTER JOIN Inspection.Document AS DNA ON I.InspectionId = DNA.InspectionId AND DNA.DocumentTypeId = 2
LEFT OUTER JOIN (
		SELECT InspectionId
				, MAX(InfestationLevelId) AS InfestationLevelId
				, SUM(InsectMonitorCount) AS Monitors
				, SUM(BaitPointCount) AS Baits
		FROM Inspection.PestTreatment
		GROUP BY InspectionId
	) AS PT ON I.InspectionId = PT.InspectionId
LEFT OUTER JOIN (
		SELECT InspectionId
				, MAX(CASE
						WHEN HygieneCommentId = 1 THEN 'Y'
						ELSE ''
					END) AS FlatWarmAndHumid
				, MAX(CASE
						WHEN HygieneCommentId = 2 THEN 'Y'
						ELSE ''
					END) AS FlatCluttured
				, MAX(CASE
						WHEN HygieneCommentId = 3 THEN 'Y'
						ELSE ''
					END) AS TenantGardenOvergrown
				, MAX(CASE
						WHEN HygieneCommentId = 4 THEN 'Y'
						ELSE ''
					END) AS KitchenDirty
				, MAX(CASE
						WHEN HygieneCommentId = 5 THEN 'Y'
						ELSE ''
					END) AS AdvisedToClean
		FROM Inspection.HygieneComment
		GROUP BY InspectionId
	) AS HC ON I.InspectionId = HC.InspectionId
WHERE I.StatusId IN (2, 4)
AND I.InspectionId NOT IN (
		SELECT API_UID
		FROM [LBS14].PCC_Croydon.dbo.tblVisitHistory
		WHERE API_UID IS NOT NULL
	)