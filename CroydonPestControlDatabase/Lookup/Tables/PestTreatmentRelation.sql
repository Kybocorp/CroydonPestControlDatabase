CREATE TABLE [Lookup].[PestTreatmentRelation] (
    [PestId]      INT NOT NULL,
    [TreatmentId] INT NOT NULL,
    CONSTRAINT [PK_PestTreatmentRelation] PRIMARY KEY CLUSTERED ([PestId] ASC, [TreatmentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PestTreatmentRelation_PestId] FOREIGN KEY ([PestId]) REFERENCES [Lookup].[Pest] ([PestId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_PestTreatmentRelation_TreatmentId] FOREIGN KEY ([TreatmentId]) REFERENCES [Lookup].[Treatment] ([TreatmentId]) ON UPDATE CASCADE
);

