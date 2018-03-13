CREATE TABLE [Lookup].[NoAccess] (
    [NoAccessId]   INT           IDENTITY (1, 1) NOT NULL,
    [NoAccessDesc] VARCHAR (100) NOT NULL,
    [Enabled]      BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([NoAccessId] ASC) WITH (FILLFACTOR = 90)
);

