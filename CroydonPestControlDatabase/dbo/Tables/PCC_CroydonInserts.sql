CREATE TABLE [dbo].[PCC_CroydonInserts] (
    [InspectionId]    INT            NULL,
    [AltInspectionId] INT            NULL,
    [InspectionDate]  DATETIME       NULL,
    [AmPm]            CHAR (2)       NULL,
    [OfficerId]       INT            NULL,
    [PropertyId]      INT            NULL,
    [AltPropertyId]   INT            NULL,
    [BlockId]         INT            NULL,
    [HouseName]       VARCHAR (100)  NULL,
    [HouseNo]         VARCHAR (100)  NULL,
    [Street]          VARCHAR (100)  NULL,
    [AddressLine1]    VARCHAR (100)  NULL,
    [AddressLine2]    VARCHAR (100)  NULL,
    [Postcode]        VARCHAR (20)   NULL,
    [UPRN]            VARCHAR (20)   NULL,
    [Easting]         INT            NULL,
    [Northing]        INT            NULL,
    [DiaryId]         INT            NULL,
    [Telephone]       VARCHAR (20)   NULL,
    [Comments]        VARCHAR (2000) NULL,
    [Pest]            VARCHAR (100)  NULL
);

