CREATE TABLE [dbo].[Staging_CroydonBookingUpdates] (
    [AltInspectionId] INT            NULL,
    [DiaryId]         INT            NULL,
    [InspectionDate]  DATETIME       NULL,
    [AMPM]            CHAR (2)       NULL,
    [UPRN]            VARCHAR (20)   NULL,
    [FollowUpNote]    VARCHAR (2000) NULL,
    [Telephone]       VARCHAR (20)   NULL,
    [PropertyId]      INT            NULL,
    [LastUpdated]     DATETIME       NULL,
    [InspectionId]    INT            NULL,
    [OfficerId]       INT            NULL,
    [StatusId]        INT            NULL,
    [Allocated]       VARCHAR (2)    NULL
);

