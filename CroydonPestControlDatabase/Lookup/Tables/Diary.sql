CREATE TABLE [Lookup].[Diary] (
    [DiaryId]   INT           IDENTITY (1, 1) NOT NULL,
    [DiaryDesc] VARCHAR (100) NOT NULL,
    [Enabled]   BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([DiaryId] ASC) WITH (FILLFACTOR = 90)
);

