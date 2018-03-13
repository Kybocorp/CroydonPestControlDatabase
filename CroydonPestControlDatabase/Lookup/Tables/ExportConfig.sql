CREATE TABLE [Lookup].[ExportConfig] (
    [ExportConfigId]   INT            IDENTITY (1, 1) NOT NULL,
    [ExportConfigName] VARCHAR (100)  NOT NULL,
    [FolderName]       VARCHAR (100)  NOT NULL,
    [ProjectName]      VARCHAR (100)  NOT NULL,
    [PackageName]      VARCHAR (100)  NOT NULL,
    [ReportServerPath] VARCHAR (1000) NULL,
    [Enabled]          BIT            DEFAULT ((1)) NOT NULL,
    [DestinationPath]  VARCHAR (500)  NULL,
    PRIMARY KEY CLUSTERED ([ExportConfigId] ASC) WITH (FILLFACTOR = 90)
);

