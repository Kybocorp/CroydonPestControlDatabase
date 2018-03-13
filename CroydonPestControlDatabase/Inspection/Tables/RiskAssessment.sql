CREATE TABLE [Inspection].[RiskAssessment] (
    [InspectionId]     INT NOT NULL,
    [RiskAssessmentId] INT NOT NULL,
    CONSTRAINT [PK_InspectionRiskAssessment] PRIMARY KEY CLUSTERED ([InspectionId] ASC, [RiskAssessmentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InspectionRiskAssessment_InspectionId] FOREIGN KEY ([InspectionId]) REFERENCES [Inspection].[Inspection] ([InspectionId]),
    CONSTRAINT [FK_InspectionRiskAssessment_RiskAssessmentId] FOREIGN KEY ([RiskAssessmentId]) REFERENCES [Lookup].[RiskAssessment] ([RiskAssessmentId])
);

