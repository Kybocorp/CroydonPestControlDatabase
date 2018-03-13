CREATE TABLE [dbo].[Staging_ImportTenants] (
    [InspectionId] INT           NULL,
    [FirstName]    VARCHAR (100) NULL,
    [LastName]     VARCHAR (100) NULL,
    [Telephone]    VARCHAR (20)  NULL,
    [Email]        VARCHAR (255) NULL,
    [IsDangerous]  BIT           NULL,
    [IsNewTenant]  BIT           NULL,
    [PropertyId]   INT           NULL,
    [TenantId]     INT           NULL
);

