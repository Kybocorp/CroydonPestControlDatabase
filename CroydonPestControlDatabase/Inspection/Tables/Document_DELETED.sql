CREATE TABLE [Inspection].[Document_DELETED] (
    [InspectionId]   INT            NOT NULL,
    [DocumentTypeId] INT            NULL,
    [DocumentPath]   VARCHAR (1000) NULL,
    [DateInserted]   DATETIME       DEFAULT (getdate()) NOT NULL,
    [Attempt]        INT            DEFAULT ((1)) NOT NULL,
    [LastUpdated]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [IsSuccessful]   BIT            DEFAULT ((0)) NOT NULL
);

