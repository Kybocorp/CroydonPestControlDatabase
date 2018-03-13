CREATE TABLE [Property].[Leaseholder] (
    [LeaseholderId] INT           IDENTITY (1, 1) NOT NULL,
    [FirstName]     VARCHAR (100) NULL,
    [LastName]      VARCHAR (100) NOT NULL,
    [Telephone]     VARCHAR (20)  NULL,
    [Email]         VARCHAR (255) NULL,
    [PropertyId]    INT           NOT NULL,
    [HouseName]     VARCHAR (100) NULL,
    [HouseNo]       VARCHAR (100) NULL,
    [Street]        VARCHAR (100) NULL,
    [AddressLine1]  VARCHAR (100) NULL,
    [AddressLine2]  VARCHAR (100) NULL,
    [Postcode]      VARCHAR (20)  NULL,
    [Uprn]          VARCHAR (20)  NULL,
    [DateInserted]  DATETIME      DEFAULT (getdate()) NULL,
    [LastUpdated]   DATETIME      DEFAULT (getdate()) NULL,
    [Deleted]       BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([LeaseholderId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Leaseholder_PropertyId] FOREIGN KEY ([PropertyId]) REFERENCES [Property].[Property] ([PropertyId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Leaseholder_PropertyId]
    ON [Property].[Leaseholder]([PropertyId] ASC) WITH (FILLFACTOR = 90);

