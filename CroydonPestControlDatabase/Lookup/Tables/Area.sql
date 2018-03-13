CREATE TABLE [Lookup].[Area] (
    [AreaId]   INT           IDENTITY (1, 1) NOT NULL,
    [AreaDesc] VARCHAR (100) NOT NULL,
    [Enabled]  BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([AreaId] ASC) WITH (FILLFACTOR = 90)
);

