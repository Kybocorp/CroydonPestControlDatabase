CREATE PROC [dbo].[DeleteInspection](
	@InspectionId INT
)
AS
DECLARE @PestTreatments TABLE(
	PestTreatmentId INT
)

-- GET PEST TREATMENT IDs
INSERT INTO @PestTreatments(PestTreatmentId)
SELECT PestTreatmentId
FROM Inspection.PestTreatment
WHERE InspectionId = @InspectionId

-- DELETE INSPECTION DATA
DELETE FROM Inspection.[TreatedArea] WHERE PestTreatmentId IN (SELECT PestTreatmentId FROM @PestTreatments)
DELETE FROM Inspection.[TreatmentUsed] WHERE PestTreatmentId IN (SELECT PestTreatmentId FROM @PestTreatments)
DELETE FROM Inspection.[PestTreatment] WHERE PestTreatmentId IN (SELECT PestTreatmentId FROM @PestTreatments)
DELETE FROM [Inspection].[Document] WHERE InspectionId = @InspectionId
DELETE FROM [Inspection].[HygieneComment] WHERE InspectionId = @InspectionId
DELETE FROM [Inspection].[Images] WHERE InspectionId = @InspectionId
DELETE FROM [Inspection].[RiskAssessment] WHERE InspectionId = @InspectionId
DELETE FROM [Inspection].[StandardComment] WHERE InspectionId = @InspectionId
DELETE FROM Inspection.Inspection WHERE InspectionId = @InspectionId
DELETE FROM Property.Tenant WHERE TenantId IN (SELECT TenantId FROM Inspection.Inspection WHERE InspectionId = @InspectionId)