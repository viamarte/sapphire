----------------------------------------------------------------------
-- This T-SQL script was created for use on Microsoft SQL Server 2005+
-- SQL that creates the SP for test purposes, optional stuff.
-- We encourage using this if you are interested in contributing.
-- Created on June, 10th 2013 
-- Functionality: accepts the most various types of arguments and returns the value given back to the user.
-- Returns: CR = 1, MR = the given data if CR equals 1. Otherwise this should return an error string. 

CREATE PROCEDURE [dbo].[sp_NODE_With_P]
@DataTypeVarChar VARCHAR(MAX)=NULL,
@DataTypeText TEXT=NULL,
@DataTypeNVarChar NVARCHAR(MAX)=NULL,
@DataTypeBigInt BIGINT=NULL,
@DataTypeInt INT=NULL,
@DataTypeSmallInt SMALLINT=NULL,
@DataTypeTinyInt TINYINT=NULL,
@DataTypeBit BIT=NULL,
@DataTypeDateTime DATETIME=NULL,
@DataTypeDate DATE=NULL,
@DataTypeTime TIME=NULL,
@DataTypeFloat FLOAT=NULL,
@DataTypeNumeric NUMERIC(12,3)=NULL,
@DataTypeMoney MONEY=NULL,
@DataTypeUniqueIdentifier UNIQUEIDENTIFIER=NULL
AS
BEGIN TRY

	SET NOCOUNT ON

	DECLARE @qty INT
	SET @qty = 0

	--By convention, the tests should call with only one argument each time
	--This checks if only one argument is given
	IF @DataTypeVarChar IS NOT NULL SET @qty = @qty + 1
	IF @DataTypeText IS NOT NULL SET @qty = @qty + 1
	IF @DataTypeNVarChar IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeBigInt IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeInt IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeSmallInt IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeTinyInt IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeBit IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeDateTime IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeDate IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeTime IS NOT NULL  SET @qty = @qty + 1
	IF @DataTypeFloat IS NOT NULL SET @qty = @qty + 1
	IF @DataTypeNumeric IS NOT NULL SET @qty = @qty + 1
	IF @DataTypeMoney IS NOT NULL SET @qty = @qty + 1
	IF @DataTypeUniqueIdentifier IS NOT NULL SET @qty = @qty + 1

	IF @qty = 1

		BEGIN

			--OK, just on argument. CONTINUE
			--CR = CODE OF RETURN
			--MR = MESSAGE OF RETURN
			IF @DataTypeVarChar IS NOT NULL SELECT 1 AS CR, @DataTypeVarChar AS MR
			IF @DataTypeText IS NOT NULL SELECT 1 AS CR, @DataTypeText AS MR
			IF @DataTypeNVarChar IS NOT NULL SELECT 1 AS CR, @DataTypeNVarChar AS MR
			IF @DataTypeBigInt IS NOT NULL SELECT 1 AS CR, @DataTypeBigInt AS MR
			IF @DataTypeInt IS NOT NULL SELECT 1 AS CR, @DataTypeInt AS MR
			IF @DataTypeSmallInt IS NOT NULL SELECT 1 AS CR, @DataTypeSmallInt AS MR
			IF @DataTypeTinyInt IS NOT NULL SELECT 1 AS CR, @DataTypeTinyInt AS MR
			IF @DataTypeBit IS NOT NULL SELECT 1 AS CR, @DataTypeBit AS MR
			IF @DataTypeDateTime IS NOT NULL SELECT 1 AS CR, @DataTypeDateTime AS MR
			IF @DataTypeDate IS NOT NULL SELECT 1 AS CR, @DataTypeDate AS MR
			IF @DataTypeTime IS NOT NULL SELECT 1 AS CR, @DataTypeTime AS MR
			IF @DataTypeFloat IS NOT NULL SELECT 1 AS CR, @DataTypeFloat AS MR
			IF @DataTypeNumeric IS NOT NULL SELECT 1 AS CR, @DataTypeNumeric AS MR
			IF @DataTypeMoney IS NOT NULL SELECT 1 AS CR, @DataTypeMoney AS MR
			IF @DataTypeUniqueIdentifier IS NOT NULL SELECT 1 AS CR, @DataTypeUniqueIdentifier AS MR

		END

	ELSE

		BEGIN
			--More than one argument received, halt execution and return error
			SELECT -1 AS CR,'invalid execution' AS MR
		END

END TRY


BEGIN CATCH

	--Error during execution
	SELECT -1 AS CR,'invalid execution' AS MR

END CATCH


/*

Some examples to test calling directly from SQL Server Management Studio or similar software:

EXEC dbo.sp_NODE_With_P @DataTypeVarChar = 'MICROSOFT'
EXEC dbo.sp_NODE_With_P @DataTypeText = 'GOOGLE'
EXEC dbo.sp_NODE_With_P @DataTypeNVarChar = 'FACEBOOK'
EXEC dbo.sp_NODE_With_P @DataTypeBigInt = 9223372036854775807 
EXEC dbo.sp_NODE_With_P @DataTypeInt = 2147483647 
EXEC dbo.sp_NODE_With_P @DataTypeSmallInt = 32767
EXEC dbo.sp_NODE_With_P @DataTypeTinyInt = 255 
EXEC dbo.sp_NODE_With_P @DataTypeBit = 1 
EXEC dbo.sp_NODE_With_P @DataTypeDateTime = 'December 31, 9999 23:59:59.997'  
EXEC dbo.sp_NODE_With_P @DataTypeDate = 'December 31, 9999 23:59:59.9999999' 
EXEC dbo.sp_NODE_With_P @DataTypeTime = 'December 31, 9999 23:59:59.9999999' 
EXEC dbo.sp_NODE_With_P @DataTypeFloat = 123.123456 
EXEC dbo.sp_NODE_With_P @DataTypeNumeric = 987654321.123 
EXEC dbo.sp_NODE_With_P @DataTypeMoney = 922337203685477.5807
EXEC dbo.sp_NODE_With_P @DataTypeUniqueIdentifier = '6F9619FF-8B86-D011-B42D-00C04FC964FF' 

Note that the max precision on Datetime is .997 in SQL Server.

*/

GO
