CREATE TABLE [Lookup].[RiskAssessment] (
    [RiskAssessmentId]   INT           IDENTITY (1, 1) NOT NULL,
    [RiskAssessmentDesc] VARCHAR (200) NOT NULL,
    [Enabled]            BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([RiskAssessmentId] ASC) WITH (FILLFACTOR = 90)
);

