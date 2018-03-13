CREATE TABLE [Lookup].[Treatment] (
    [TreatmentId]      INT           IDENTITY (1, 1) NOT NULL,
    [TreatmentDesc]    VARCHAR (100) NOT NULL,
    [TreatmentTypeId]  INT           NOT NULL,
    [ActiveIngredient] VARCHAR (200) NULL,
    [RegistrationNo]   VARCHAR (100) NULL,
    [Enabled]          BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TreatmentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Treatment_TreatmentType] FOREIGN KEY ([TreatmentTypeId]) REFERENCES [Lookup].[TreatmentType] ([TreatmentTypeId]) ON UPDATE CASCADE
);

