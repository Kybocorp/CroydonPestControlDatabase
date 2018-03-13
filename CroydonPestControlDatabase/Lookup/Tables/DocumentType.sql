CREATE TABLE [Lookup].[DocumentType] (
    [DocumentTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [DocumentTypeDesc] VARCHAR (100) NOT NULL,
    [ExportConfigName] VARCHAR (100) NULL,
    [Enabled]          BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([DocumentTypeId] ASC) WITH (FILLFACTOR = 90)
);

