CREATE TABLE [Inspection].[TreatedArea] (
    [PestTreatmentId] INT NOT NULL,
    [AreaId]          INT NOT NULL,
    CONSTRAINT [PK_TreatedArea] PRIMARY KEY CLUSTERED ([PestTreatmentId] ASC, [AreaId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TreatedArea_AreaId] FOREIGN KEY ([AreaId]) REFERENCES [Lookup].[Area] ([AreaId]),
    CONSTRAINT [FK_TreatedArea_PestTreatmentId] FOREIGN KEY ([PestTreatmentId]) REFERENCES [Inspection].[PestTreatment] ([PestTreatmentId])
);

