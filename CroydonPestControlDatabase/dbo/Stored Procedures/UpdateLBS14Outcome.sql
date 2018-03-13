CREATE PROC [dbo].[UpdateLBS14Outcome]
AS
UPDATE RV
SET RV.Outcome_UID =  CASE
			WHEN I.StatusId = 4 THEN 2 -- NO ACCESS
			WHEN I.StatusId = 2 AND I.JobClosed = 1 THEN 1  -- COMPLETE - JOB CLOSED
			WHEN I.StatusId = 2 AND I.JobClosed = 0 THEN 10 -- COMPLETE - FOLLOW-UP
		END
	, RV.Telephone = I.Telephone
	, RV.UPRN = P.UPRN
	, RV.Comments = LEFT(COALESCE(LTRIM(RTRIM(I.FollowUpNotes)), ''), 200)
	, RV.AddedBy = LEFT(COALESCE(COALESCE(LEFT(O.FirstName, 1), '') + COALESCE(O.LastName, ''), LTRIM(RTRIM(RV.AddedBy))), 50)
FROM [LBS14].PCC_Croydon.dbo.Pest_ReactiveVisits AS RV
INNER JOIN Inspection.Inspection AS I ON RV.[UID] = I.AltInspectionId AND I.StatusId IN (2, 4) AND COALESCE(RV.Outcome_UID, 0) = 0
INNER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
WHERE I.AltInspectionId IS NOT NULL