CREATE TABLE [Lookup].[OffDay] (
    [OffDayDate] DATE          NOT NULL,
    [OffDayDesc] VARCHAR (100) NOT NULL,
    PRIMARY KEY CLUSTERED ([OffDayDate] ASC) WITH (FILLFACTOR = 90)
);

