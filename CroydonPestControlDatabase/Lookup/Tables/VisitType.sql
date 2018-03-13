CREATE TABLE [Lookup].[VisitType] (
    [VisitTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [VisitTypeDesc] VARCHAR (100) NOT NULL,
    [Enabled]       BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([VisitTypeId] ASC) WITH (FILLFACTOR = 90)
);

