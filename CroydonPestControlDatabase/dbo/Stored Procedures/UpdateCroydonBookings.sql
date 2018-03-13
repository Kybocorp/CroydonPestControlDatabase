CREATE PROC [dbo].[UpdateCroydonBookings]
AS
UPDATE I
SET   I.AltInspectionId = U.AltInspectionId
	, I.DiaryId = U.DiaryId
	, I.InspectionDate = U.InspectionDate
	, I.AMPM = U.AMPM
	--, I.OfficerId = U.OfficerId
	, I.FollowUpNotes = U.FollowUpNote
	, I.Telephone = U.Telephone
	, I.PropertyId = U.PropertyId
	, I.LastUpdated = U.LastUpdated
	, I.StatusId = U.StatusId
FROM Inspection.Inspection AS I
INNER JOIN dbo.Staging_CroydonBookingUpdates AS U ON I.InspectionId = U.InspectionId
WHERE Allocated <> 'N'


-- UPDATE CANCELLATION AND CHANGED APPOINTMENTS
UPDATE I
SET   I.LastUpdated = U.LastUpdated
	, I.StatusId = 3 -- CANCELLATION
FROM Inspection.Inspection AS I
INNER JOIN dbo.Staging_CroydonBookingUpdates AS U ON I.InspectionId = U.InspectionId
WHERE Allocated = 'N'