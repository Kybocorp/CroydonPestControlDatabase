CREATE TABLE [Inspection].[BlockCycle] (
    [BlockCycleId] INT  IDENTITY (1, 1) NOT NULL,
    [StartDate]    DATE NOT NULL,
    [EndDate]      DATE NULL,
    [StatusId]     INT  NULL,
    PRIMARY KEY CLUSTERED ([BlockCycleId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_BlockCycle_StatusId] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[Status] ([StatusId]) ON UPDATE CASCADE
);

