CREATE TABLE [Lookup].[HygieneComment] (
    [HygieneCommentId]   INT           IDENTITY (1, 1) NOT NULL,
    [HygieneCommentDesc] VARCHAR (100) NOT NULL,
    [Enabled]            BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([HygieneCommentId] ASC) WITH (FILLFACTOR = 90)
);

