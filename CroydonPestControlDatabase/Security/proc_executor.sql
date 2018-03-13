CREATE ROLE [proc_executor]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [proc_executor] ADD MEMBER [LBS-MFS-01\SSRS_User];

