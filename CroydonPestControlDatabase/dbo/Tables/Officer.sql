CREATE TABLE [dbo].[Officer] (
    [OfficerId] INT           IDENTITY (1, 1) NOT NULL,
    [FirstName] VARCHAR (100) NOT NULL,
    [LastName]  VARCHAR (100) NOT NULL,
    [Username]  VARCHAR (100) NOT NULL,
    [Email]     VARCHAR (255) NULL,
    [TeamId]    INT           NULL,
    [IsAdmin]   BIT           DEFAULT ((0)) NOT NULL,
    [Enabled]   BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([OfficerId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Officer_TeamId] FOREIGN KEY ([TeamId]) REFERENCES [dbo].[Team] ([TeamId]) ON UPDATE CASCADE
);

