CREATE TABLE [Inspection].[Summary] (
    [InspectionId] INT            NOT NULL,
    [SummaryPath]  VARCHAR (1000) NOT NULL,
    [DateInserted] DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([InspectionId] ASC) WITH (FILLFACTOR = 90)
);

