CREATE TABLE [dbo].[Team] (
    [TeamId]   INT           IDENTITY (1, 1) NOT NULL,
    [TeamName] VARCHAR (100) NOT NULL,
    [Enabled]  BIT           DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([TeamId] ASC) WITH (FILLFACTOR = 90)
);

