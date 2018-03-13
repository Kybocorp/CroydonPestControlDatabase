CREATE TABLE [Lookup].[Status] (
    [StatusId]   INT           IDENTITY (1, 1) NOT NULL,
    [StatusDesc] VARCHAR (100) NOT NULL,
    [Enabled]    BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([StatusId] ASC) WITH (FILLFACTOR = 90)
);

