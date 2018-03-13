CREATE TABLE [dbo].[syncConfig] (
    [configName]  VARCHAR (50) NOT NULL,
    [lastRunTime] DATETIME     NULL,
    [lastRunId]   INT          NULL
);

