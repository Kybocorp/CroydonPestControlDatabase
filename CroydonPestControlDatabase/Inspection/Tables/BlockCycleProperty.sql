CREATE TABLE [Inspection].[BlockCycleProperty] (
    [BlockCycleId]       INT            NOT NULL,
    [PropertyId]         INT            NOT NULL,
    [StatusId]           INT            NOT NULL,
    [AmPm]               CHAR (2)       NULL,
    [NextInspectionDate] DATE           NULL,
    [Comments]           VARCHAR (1000) NULL,
    [LastUpdated]        DATETIME       DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      INT            NULL,
    CONSTRAINT [PK_BlockCycleProperty] PRIMARY KEY CLUSTERED ([BlockCycleId] ASC, [PropertyId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BlockCycleProperty_BlockCycleId] FOREIGN KEY ([BlockCycleId]) REFERENCES [Inspection].[BlockCycle] ([BlockCycleId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_BlockCycleProperty_LastUpdatedBy] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Officer] ([OfficerId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_BlockCycleProperty_PropertyId] FOREIGN KEY ([PropertyId]) REFERENCES [Property].[Property] ([PropertyId]) ON UPDATE CASCADE
);

