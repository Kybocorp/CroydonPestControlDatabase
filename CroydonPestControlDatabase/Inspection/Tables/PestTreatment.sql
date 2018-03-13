CREATE TABLE [Inspection].[PestTreatment] (
    [PestTreatmentId]    INT      IDENTITY (1, 1) NOT NULL,
    [InspectionId]       INT      NOT NULL,
    [PestId]             INT      NOT NULL,
    [InfestationLevelId] INT      NOT NULL,
    [InsectMonitorCount] INT      NULL,
    [BaitPointCount]     INT      NULL,
    [RefrainForHours]    INT      NULL,
    [DateInserted]       DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([PestTreatmentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PestTreatment_InfestationLevelId] FOREIGN KEY ([InfestationLevelId]) REFERENCES [Lookup].[InfestationLevel] ([InfestationLevelId]),
    CONSTRAINT [FK_PestTreatment_InspectionId] FOREIGN KEY ([InspectionId]) REFERENCES [Inspection].[Inspection] ([InspectionId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_PestTreatment_PestId] FOREIGN KEY ([PestId]) REFERENCES [Lookup].[Pest] ([PestId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_PestTreatment_InspectionId]
    ON [Inspection].[PestTreatment]([InspectionId] ASC) WITH (FILLFACTOR = 90);

