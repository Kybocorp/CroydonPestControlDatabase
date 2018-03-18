ALTER ROLE [db_owner] ADD MEMBER [LBS\TP_AAdel];


GO
ALTER ROLE [db_owner] ADD MEMBER [LBS\TP_MLozada];


GO
ALTER ROLE [db_owner] ADD MEMBER [Pest_Services];


GO
ALTER ROLE [db_datareader] ADD MEMBER [Pest_Services];


--GO
--ALTER ROLE [db_datareader] ADD MEMBER [lbs_user];


GO
ALTER ROLE [db_datareader] ADD MEMBER [LBS-MFS-01\SSRS_User];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [Pest_Services];


--GO
--ALTER ROLE [db_datawriter] ADD MEMBER [lbs_user];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [LBS-MFS-01\SSRS_User];