CREATE TABLE [Inspection].[StandardComment] (
    [InspectionId]      INT NOT NULL,
    [StandardCommentId] INT NOT NULL,
    CONSTRAINT [PK_InspectionStandardComment] PRIMARY KEY CLUSTERED ([InspectionId] ASC, [StandardCommentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InspectionStandardComment_InspectionId] FOREIGN KEY ([InspectionId]) REFERENCES [Inspection].[Inspection] ([InspectionId]),
    CONSTRAINT [FK_InspectionStandardComment_StandardCommentId] FOREIGN KEY ([StandardCommentId]) REFERENCES [Lookup].[StandardComment] ([StandardCommentId])
);

