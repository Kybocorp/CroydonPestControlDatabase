CREATE TABLE [Lookup].[EmailTemplate] (
    [EmailTemplateName] VARCHAR (100)  NOT NULL,
    [EmailHTML]         VARCHAR (7000) NOT NULL,
    [EmailSubject]      VARCHAR (255)  NOT NULL,
    [Enabled]           BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([EmailTemplateName] ASC) WITH (FILLFACTOR = 90)
);

