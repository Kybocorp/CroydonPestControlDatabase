CREATE TABLE [Lookup].[TenureType] (
    [TenureTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [TenureTypeDesc] VARCHAR (100) NOT NULL,
    [Enabled]        BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TenureTypeId] ASC) WITH (FILLFACTOR = 90)
);

