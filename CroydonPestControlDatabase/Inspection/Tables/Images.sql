CREATE TABLE [Inspection].[Images] (
    [ImageId]      INT             IDENTITY (1, 1) NOT NULL,
    [InspectionId] INT             NOT NULL,
    [Image]        VARBINARY (MAX) NULL,
    [DateInserted] DATETIME        DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ImageId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Images_InspectionId] FOREIGN KEY ([InspectionId]) REFERENCES [Inspection].[Inspection] ([InspectionId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Images_InspectionId]
    ON [Inspection].[Images]([InspectionId] ASC) WITH (FILLFACTOR = 90);

