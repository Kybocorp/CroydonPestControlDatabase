CREATE TABLE [Lookup].[PaymentType] (
    [PaymentTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [PaymentTypeDesc] VARCHAR (100) NOT NULL,
    [Enabled]         BIT           DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([PaymentTypeId] ASC) WITH (FILLFACTOR = 90)
);

