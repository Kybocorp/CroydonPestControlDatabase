CREATE TABLE [Inspection].[HygieneComment] (
    [InspectionId]     INT NOT NULL,
    [HygieneCommentId] INT NOT NULL,
    CONSTRAINT [PK_InspectionHygieneComment] PRIMARY KEY CLUSTERED ([InspectionId] ASC, [HygieneCommentId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InspectionHygieneComment_HygieneCommentId] FOREIGN KEY ([HygieneCommentId]) REFERENCES [Lookup].[HygieneComment] ([HygieneCommentId]),
    CONSTRAINT [FK_InspectionHygieneComment_InspectionId] FOREIGN KEY ([InspectionId]) REFERENCES [Inspection].[Inspection] ([InspectionId])
);

