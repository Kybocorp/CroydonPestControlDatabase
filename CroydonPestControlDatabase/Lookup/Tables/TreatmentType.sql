CREATE TABLE [Lookup].[TreatmentType] (
    [TreatmentTypeId]    INT           IDENTITY (1, 1) NOT NULL,
    [TreatementTypeDesc] VARCHAR (100) NOT NULL,
    [Enabled]            BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TreatmentTypeId] ASC) WITH (FILLFACTOR = 90)
);

