CREATE PROC dbo.GetImportedBookings
AS
SELECT AltInspectionId, InspectionId
FROM Inspection.Inspection
WHERE AltInspectionId IS NOT NULL
ORDER BY AltInspectionId