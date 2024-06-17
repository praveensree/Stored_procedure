USE [wgc-development]

GO
 
--EXEC #EmployeeDetails_Update_InActive 'tm@gmail.com', 1269,'pr test','PKUMAR@WITTERN.COM';
 
EXEC #EmployeeDetails_Update_InActive 'hanumanarv@yahoo.com', 234,'PR-WOLF','WOLFMAN','WOLF STREET','PPRAVEEN@WITTERN.COM';
 
CREATE OR ALTER PROC #EmployeeDetails_Update_InActive

(

	@empEmailId NVARCHAR(MAX), -- Employee Email Id

	@employeeNumber  NVARCHAR(10),--Employee Number	

	@managingOrgName NVARCHAR(100),--Managing Organization Level

	@OrganazationName NVARCHAR(100), --Organization Level

	@AccountName NVARCHAR(100),--Account Level

	@ModifiedBy NVARCHAR(100) -- Admin Username

)

AS

	Declare @newFirstName NVARCHAR(100)

	Declare @newLastName NVARCHAR(100)

	Declare @newEmail NVARCHAR(100)

	DECLARE @orgAccName VARCHAR (100)

	DECLARE @accountId uniqueidentifier
 
BEGIN
 
	SET @newFirstName = 'nobody'

	SET @newLastName = 'nobody'

	SET @NewEmail = 'nobody@nobody.nul'

	--set @EmployeeNumber  = (SELECT TOP 1 EmployeeNumber FROM Employees nolock WHERE email = @EmpEmailId)
 
	Set @accountId = (Select acc.Id from organizations acc

			 inner join Organizations org

			 on acc.ParentOrgId=org.id 

			 inner join Organizations morg 

			 on org.ParentOrgId=morg.Id 

			 where morg.[Name] =@managingOrgName

			 and org.Name=@OrganazationName

			 and acc.Name=@AccountName

			);
 
	--select @OrgAccName = name, @AccountId = ID FROM ORGANIZATIONS nolock WHERE ID IN (SELECT accountid FROM Employees nolock where EmployeeNumber = @EmployeeNumber) -- Using Join

 
	select @AccountId AS AccountID ,@EmployeeNumber as EmployeeNumber, @OrgAccName as OrgAccountName
 
	--BEGIN TRAN
 
		SET NOCOUNT ON; 

		IF EXISTS (SELECT COUNT(1) FROM Employees nolock WHERE email = @EmpEmailId AND EmployeeNumber = @EmployeeNumber AND ACCOUNTID = @AccountId)

			BEGIN

			PRINT 'EMPOLYEE EMAIL & Employee Number:' + @EmpEmailId +  '& ' + @EmployeeNumber ;

			SELECT FirstName,LastName,EmployeeNumber, Email, Active, AccountId, ModifiedBy, ModifiedDate 

				FROM Employees nolock 

				WHERE email = @EmpEmailId 

					AND EmployeeNumber = @EmployeeNumber 

					AND ACCOUNTID = @AccountId;
 
			-------------------------------------------------------------

				UPDATE Employees 

				SET 

					Active = 0,

					Email = @NewEmail, 

					FirstName = @NewFirstName,

					LastName = @NewLastName,

					ModifiedBy = (SELECT top 1 ID FROM ASPNETUSERS NOLOCK WHERE USERNAME = @ModifiedBy),

					ModifiedDate = GETUTCDATE()

				WHERE email = @EmpEmailId AND EmployeeNumber = @EmployeeNumber AND ACCOUNTID = @AccountId;

			-------------------------------------------------------------

			PRINT 'Employee Details has been updated into InActive' + @EmployeeNumber;

			SELECT FirstName,LastName,EmployeeNumber, Email, Active, AccountId, ModifiedBy, ModifiedDate 

				FROM Employees nolock WHERE EmployeeNumber = @EmployeeNumber AND AccountId = @AccountId;
 
			END

		ELSE

			BEGIN

				PRINT 'NO EMPLOYEE FOUND'

				RETURN 

			END

	--ROLLBACK

	--COMMIT

END;
 
 
 
 