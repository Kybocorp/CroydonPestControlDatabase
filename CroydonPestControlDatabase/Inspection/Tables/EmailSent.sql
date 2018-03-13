CREATE TABLE [Inspection].[EmailSent] (
    [EmailSentId]    INT            IDENTITY (1, 1) NOT NULL,
    [EmailAddress]   VARCHAR (255)  NOT NULL,
    [TenantId]       INT            NULL,
    [DocumentTypeId] INT            NULL,
    [DocumentPath]   VARCHAR (1000) NULL,
    [InspectionId]   INT            NULL,
    [IsSuccessful]   BIT            CONSTRAINT [DF_EmailSent_IsSuccessful] DEFAULT ((0)) NOT NULL,
    [Attempt]        INT            CONSTRAINT [DF_EmailSent_Attempt] DEFAULT ((1)) NOT NULL,
    [LastUpdated]    DATETIME       CONSTRAINT [DF_EmailSent_LastUpdated] DEFAULT (getdate()) NOT NULL,
    [DateInserted]   DATETIME       CONSTRAINT [DF__EmailSent__DateI__1BB31344] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__EmailSen__456E5F9BB1F95586] PRIMARY KEY CLUSTERED ([EmailSentId] ASC) WITH (FILLFACTOR = 90)
);

