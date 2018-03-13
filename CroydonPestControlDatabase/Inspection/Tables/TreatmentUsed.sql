CREATE TABLE [Inspection].[TreatmentUsed] (
    [PestTreatmentId] INT NOT NULL,
    [TreatmentId]     INT NOT NULL,
    CONSTRAINT [PK_TreatmentUsed] PRIMARY KEY CLUSTERED ([PestTreatmentId] ASC, [TreatmentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TreatmentUsed_PestTreatmentId] FOREIGN KEY ([PestTreatmentId]) REFERENCES [Inspection].[PestTreatment] ([PestTreatmentId]),
    CONSTRAINT [FK_TreatmentUsed_TreatmnentId] FOREIGN KEY ([TreatmentId]) REFERENCES [Lookup].[Treatment] ([TreatmentId])
);

