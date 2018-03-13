CREATE TABLE [Lookup].[StandardComment] (
    [StandardCommentId]   INT           IDENTITY (1, 1) NOT NULL,
    [StandardCommentDesc] VARCHAR (200) NOT NULL,
    [Enabled]             BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([StandardCommentId] ASC) WITH (FILLFACTOR = 90)
);

