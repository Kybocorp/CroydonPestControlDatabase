CREATE TABLE [Lookup].[Pest] (
    [PestId]   INT           IDENTITY (1, 1) NOT NULL,
    [PestName] VARCHAR (100) NOT NULL,
    [Enabled]  BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([PestId] ASC) WITH (FILLFACTOR = 90)
);

