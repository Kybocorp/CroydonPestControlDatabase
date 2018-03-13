CREATE TABLE [Lookup].[HygieneLevel] (
    [HygieneLevelId]   INT           IDENTITY (1, 1) NOT NULL,
    [HygieneLevelDesc] VARCHAR (100) NOT NULL,
    [Enabled]          BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([HygieneLevelId] ASC) WITH (FILLFACTOR = 90)
);

