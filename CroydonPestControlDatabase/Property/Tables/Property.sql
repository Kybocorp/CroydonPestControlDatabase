CREATE TABLE [Property].[Property] (
    [PropertyId]    INT             IDENTITY (1, 1) NOT NULL,
    [AltPropertyId] INT             NULL,
    [IWorldId]      INT             NULL,
    [BlockId]       INT             NULL,
    [TenureTypeId]  INT             NULL,
    [PropertyName]  VARCHAR (100)   NULL,
    [HouseName]     VARCHAR (100)   NULL,
    [HouseNo]       VARCHAR (100)   NULL,
    [Street]        VARCHAR (100)   NULL,
    [AddressLine1]  VARCHAR (100)   NULL,
    [AddressLine2]  VARCHAR (100)   NULL,
    [Postcode]      VARCHAR (20)    NULL,
    [UPRN]          VARCHAR (20)    NULL,
    [Latitude]      DECIMAL (10, 7) NULL,
    [Longitude]     DECIMAL (10, 7) NULL,
    [Easting]       INT             NULL,
    [Northing]      INT             NULL,
    [Enabled]       BIT             CONSTRAINT [DF__Property__Enable__70099B30] DEFAULT ((1)) NOT NULL,
    [LastUpdated]   DATETIME        CONSTRAINT [DF__Property__LastUp__70FDBF69] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__Property__70C9A735EC6F37D0] PRIMARY KEY CLUSTERED ([PropertyId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Property_BlockId] FOREIGN KEY ([BlockId]) REFERENCES [Property].[Block] ([BlockId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Property_BlockId]
    ON [Property].[Property]([BlockId] ASC) WITH (FILLFACTOR = 90);

