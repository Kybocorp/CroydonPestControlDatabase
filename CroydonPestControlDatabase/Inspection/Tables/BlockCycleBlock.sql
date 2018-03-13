CREATE TABLE [Inspection].[BlockCycleBlock] (
    [BlockCycleId] INT  NOT NULL,
    [BlockId]      INT  NOT NULL,
    [StartDate]    DATE NOT NULL,
    [EndDate]      DATE NULL,
    [StatusId]     INT  NULL,
    CONSTRAINT [PK_BlockCycleBlock] PRIMARY KEY CLUSTERED ([BlockCycleId] ASC, [BlockId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BlockCycleBlock_BlockCycleId] FOREIGN KEY ([BlockCycleId]) REFERENCES [Inspection].[BlockCycle] ([BlockCycleId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_BlockCycleBlock_BlockId] FOREIGN KEY ([BlockId]) REFERENCES [Property].[Block] ([BlockId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_BlockCycleBlock_StatusId] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[Status] ([StatusId])
);

