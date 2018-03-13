
CREATE PROC [dbo].[GetAllPendingInspections](
      @UserId INT
    , @InspectionDate DATETIME = NULL
)
AS
BEGIN TRY

    DECLARE @ProcessName VARCHAR(255)
    SET @ProcessName = OBJECT_NAME(@@PROCID)

    --IF(@UserId > 0)
	   --BEGIN

		  /*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			   ADD SOME FILTERING USING THE USERID, THEY SHOULD ONLY SEE TEHIR TEAMS INSPECTIONS
		  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/


	   IF (ISDATE(@InspectionDate) = 1)
		  BEGIN
			 /************************************
					   RETURN DATA
			 ************************************/
    
			 SELECT InspectionId
				    , I.InspectionDate
				    , LOWER(S.StatusDesc) AS [Status]
				    , I.AmPm
				    , COALESCE(NULLIF(LTRIM(RTRIM(P.HouseName)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.HouseNo)), '') + ', ', '') + COALESCE(NULLIF(LTRIM(RTRIM(P.Street)), ''), '') AS InspectionTitle
				    , COALESCE(LTRIM(RTRIM(T.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(T.LastName)), '') + ' (' + LEFT(O.FirstName, 1) + '.' + O.LastName + ')' AS InspectionSubTitle
				    , I.OfficerId
				    , COALESCE(LTRIM(RTRIM(O.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(O.LastName)), '') AS OfficerDisplayName
				    , CAST(1 AS BIT) AS PestControlForm
				    , T.TenantId
				    , COALESCE(LTRIM(RTRIM(T.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(T.LastName)), '') AS TenantDisplayName
				    , T.FirstName
				    , T.LastName
				    , T.Telephone
				    , T.Email
				    , T.IsDangerous
				    , P.PropertyId
				    , P.HouseName
				    , P.HouseNo
				    , P.Street
				    , P.AddressLine1
				    , P.AddressLine2
				    , P.PostCode
				    , P.Longitude
				    , P.Latitude
			 FROM Inspection.Inspection AS I
			 LEFT OUTER JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
			 LEFT OUTER JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
			 LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
			 LEFT OUTER JOIN [Lookup].[Status] AS S ON I.StatusId = S.StatusId
			 WHERE CAST(I.InspectionDate AS DATE) = CAST(@InspectionDate AS DATE)
			 AND S.StatusDesc IN ('Pending', 'NoAccess')
			 ORDER BY OfficerDisplayName, P.Street, P.HouseNo, P.HouseName

		  END
	   ELSE
		  BEGIN

			 /************************************
					   RETURN DATA
			 ************************************/
    
			 SELECT InspectionId
				    , I.InspectionDate
				    , LOWER(S.StatusDesc) AS [Status]
				    , I.AmPm
				    , COALESCE(LTRIM(RTRIM(P.HouseName)) + ', ', '') + COALESCE(LTRIM(RTRIM(P.HouseNo)) + ', ', '') + COALESCE(LTRIM(RTRIM(P.Street)), '') AS InspectionTitle
				    , COALESCE(LTRIM(RTRIM(T.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(T.LastName)), '') + ' (' + LEFT(O.FirstName, 1) + '.' + O.LastName + ')' AS InspectionSubTitle
				    , I.OfficerId
				    , COALESCE(LTRIM(RTRIM(O.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(O.LastName)), '') AS OfficerDisplayName
				    , CAST(1 AS BIT) AS PestControlForm
				    , T.TenantId
				    , COALESCE(LTRIM(RTRIM(T.FirstName)) + ' ', '') + COALESCE(LTRIM(RTRIM(T.LastName)), '') AS TenantDisplayName
				    , T.FirstName
				    , T.LastName
				    , T.Telephone
				    , T.Email
				    , T.IsDangerous
				    , P.PropertyId
				    , P.HouseName
				    , P.HouseNo
				    , P.Street
				    , P.AddressLine1
				    , P.AddressLine2
				    , P.PostCode
				    , P.Longitude
				    , P.Latitude
			 FROM Inspection.Inspection AS I
			 LEFT JOIN Property.Property AS P ON I.PropertyId = P.PropertyId
			 LEFT JOIN Property.Tenant AS T ON I.TenantId = T.TenantId
			 LEFT OUTER JOIN dbo.Officer AS O ON I.OfficerId = O.OfficerId
			 LEFT OUTER JOIN [Lookup].[Status] AS S ON I.StatusId = S.StatusId
			 WHERE S.StatusDesc IN ('Pending', 'NoAccess')
			 ORDER BY OfficerDisplayName, P.Street, P.HouseNo, P.HouseName

		  END
		  --WHERE OfficerId = @UserId
	   --END
    --ELSE
	   --BEGIN
		  /*
			 /************************************
					 LOG EVENT
			 ************************************/
			 EXEC [Log].LogEvent 
				   @ProcessName = @ProcessName
				 , @OfficerId = @UserId
				 , @Message = 'Error retrieveing all pending inspections. Invalid UserId supplied'
				 , @IsError = 1

		  */
	   --END

END TRY
BEGIN CATCH

    -- ROLLBACK TRANSACTION
	   IF @@TRANCOUNT > 0 ROLLBACK TRAN

    -- DECLARE AND SET VARIABLES
	   DECLARE @ErrorMessage VARCHAR(2000)
		  , @ErrorSeverity TINYINT
		  , @ErrorState TINYINT
		  , @ErrorLine INT

	   SET @ErrorMessage  = ERROR_MESSAGE()
	   SET @ErrorSeverity = ERROR_SEVERITY()
	   SET @ErrorState    = ERROR_STATE()
	   SET @ErrorLine	  = ERROR_LINE()

    -- LOG ERROR
	   EXEC [Log].LogEvent 
		    @ProcessName = @ProcessName
		  , @OfficerId = @UserId
		  , @Message = @ErrorMessage
		  , @IsError = 1
		  , @ErrorLineNumber = @ErrorLine
		
    -- RAISE FAILURE ERROR --
	   RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH
