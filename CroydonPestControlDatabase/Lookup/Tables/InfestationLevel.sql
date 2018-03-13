CREATE TABLE [Lookup].[InfestationLevel] (
    [InfestationLevelId]   INT           IDENTITY (1, 1) NOT NULL,
    [InfestationLevelDesc] VARCHAR (100) NOT NULL,
    [Enabled]              BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([InfestationLevelId] ASC) WITH (FILLFACTOR = 90)
);

