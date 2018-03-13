CREATE TABLE [Property].[Block] (
    [BlockId]     INT           IDENTITY (1, 1) NOT NULL,
    [AltBlockId]  INT           NULL,
    [UPRN]        VARCHAR (20)  NULL,
    [BlockName]   VARCHAR (100) NOT NULL,
    [StreetNo]    VARCHAR (100) NULL,
    [Street]      VARCHAR (100) NOT NULL,
    [IWorldRef]   VARCHAR (20)  NULL,
    [Enabled]     BIT           CONSTRAINT [DF__Block__Enabled__6C390A4C] DEFAULT ((1)) NOT NULL,
    [LastUpdated] DATETIME      CONSTRAINT [DF__Block__LastUpdat__6D2D2E85] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__Block__144215F1B75AF2EC] PRIMARY KEY CLUSTERED ([BlockId] ASC) WITH (FILLFACTOR = 90)
);

