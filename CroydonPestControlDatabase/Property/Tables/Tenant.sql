CREATE TABLE [Property].[Tenant] (
    [TenantId]     INT           IDENTITY (1, 1) NOT NULL,
    [AltTenantId]  INT           NULL,
    [FirstName]    VARCHAR (100) NULL,
    [LastName]     VARCHAR (100) NOT NULL,
    [Telephone]    VARCHAR (20)  NULL,
    [Email]        VARCHAR (255) NULL,
    [PropertyId]   INT           NOT NULL,
    [IsDangerous]  BIT           DEFAULT ((0)) NOT NULL,
    [DateInserted] DATETIME      DEFAULT (getdate()) NULL,
    [LastUpdated]  DATETIME      DEFAULT (getdate()) NULL,
    [Deleted]      BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([TenantId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Tenant_PropertyId] FOREIGN KEY ([PropertyId]) REFERENCES [Property].[Property] ([PropertyId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Tenant_PropertyId]
    ON [Property].[Tenant]([PropertyId] ASC) WITH (FILLFACTOR = 90);

