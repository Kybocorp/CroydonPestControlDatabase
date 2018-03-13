CREATE TABLE [Inspection].[Inspection] (
    [InspectionId]         INT             IDENTITY (1, 1) NOT NULL,
    [AltInspectionId]      INT             NULL,
    [JobId]                INT             CONSTRAINT [DF_Inspection_JobId] DEFAULT ((0)) NOT NULL,
    [InspectionDate]       DATETIME        NULL,
    [AmPm]                 CHAR (2)        NULL,
    [OfficerId]            INT             NULL,
    [AssignedBy]           INT             NULL,
    [DateAssigned]         DATETIME        NULL,
    [PropertyId]           INT             NULL,
    [TenantId]             INT             NULL,
    [BlockCycleId]         INT             NULL,
    [VisitTypeId]          INT             NULL,
    [NoAccessId]           INT             NULL,
    [NoAccessTime]         DATETIME        NULL,
    [DiaryId]              INT             NULL,
    [InspectionStartTime]  DATETIME        NULL,
    [InspectionEndTime]    DATETIME        NULL,
    [Telephone]            VARCHAR (20)    NULL,
    [InsectMonitorsFound]  INT             NULL,
    [BaitPointsFound]      INT             NULL,
    [HygieneLevelId]       INT             NULL,
    [FollowUpDate]         DATETIME        NULL,
    [FollowUpAmPm]         CHAR (2)        NULL,
    [FollowUpId]           INT             NULL,
    [FollowUpNotes]        VARCHAR (2000)  NULL,
    [FollowUpInspectionId] INT             NULL,
    [JobClosed]            BIT             CONSTRAINT [DF__Inspectio__JobCl__17236851] DEFAULT ((0)) NOT NULL,
    [JobClosedDate]        DATETIME        NULL,
    [AmountPaid]           MONEY           NULL,
    [PaymentTypeId]        INT             NULL,
    [Notes]                VARCHAR (2000)  NULL,
    [TenantSignature]      VARBINARY (MAX) NULL,
    [OfficerSignature]     VARBINARY (MAX) NULL,
    [LastUpdated]          DATETIME        CONSTRAINT [DF__Inspectio__LastU__18178C8A] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]        INT             NULL,
    [StatusId]             INT             NOT NULL,
    [Deleted]              BIT             CONSTRAINT [DF__Inspectio__Delet__190BB0C3] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__Inspecti__30B2DC087D899A34] PRIMARY KEY CLUSTERED ([InspectionId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Inspection_BlockCycleId] FOREIGN KEY ([BlockCycleId]) REFERENCES [Inspection].[BlockCycle] ([BlockCycleId]),
    CONSTRAINT [FK_Inspection_DiaryId] FOREIGN KEY ([DiaryId]) REFERENCES [Lookup].[Diary] ([DiaryId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_HygieneLevelId] FOREIGN KEY ([HygieneLevelId]) REFERENCES [Lookup].[HygieneLevel] ([HygieneLevelId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_NoAccessId] FOREIGN KEY ([NoAccessId]) REFERENCES [Lookup].[NoAccess] ([NoAccessId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_PaymentTypeId] FOREIGN KEY ([PaymentTypeId]) REFERENCES [Lookup].[PaymentType] ([PaymentTypeId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_Property] FOREIGN KEY ([PropertyId]) REFERENCES [Property].[Property] ([PropertyId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_Status] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[Status] ([StatusId]) ON UPDATE CASCADE,
    CONSTRAINT [FK_Inspection_TenantId] FOREIGN KEY ([TenantId]) REFERENCES [Property].[Tenant] ([TenantId]),
    CONSTRAINT [FK_Inspection_VisitTypeId] FOREIGN KEY ([VisitTypeId]) REFERENCES [Lookup].[VisitType] ([VisitTypeId]) ON UPDATE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_Inspection_PropertyId]
    ON [Inspection].[Inspection]([PropertyId] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Inspection_TenantId]
    ON [Inspection].[Inspection]([TenantId] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Inspection_OfficerId]
    ON [Inspection].[Inspection]([OfficerId] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Inspection_BlockCycleId]
    ON [Inspection].[Inspection]([BlockCycleId] ASC) WITH (FILLFACTOR = 90);

