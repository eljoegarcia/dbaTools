--FUNCTION
-- A Routine that is used to encapsulate frequently performed logic
	--RULES;
		--Must return a value
		--NO execution Plan re-use
		--Types of Functions
			--Scalar Functions
			--Table-Valued Functions
				--Inline
				--Multistatement
	--EXAMPLE SCALAR FUNCTION 
		--returns a single value, and will ussually include parameters
			CREATE FUNCTION dbo.EtractProtocolFromURL
			( @URL nvarchar(1000))
			RETURNS nvarchar(1000)
			AS BEGIN
			RETURN CASE WHEN CHARINDEX (N':',@URL,1) -1)
			END;

			SELECT
			dbo.EtractProtocolFromURL(N'http://www.microsoft.com');
			IF (dbo.EtractProtocolFromURL(@URL) = N'http')
			...			

-- Demonstration 14 - Scalar Function



-- Step 1 - Open a new query window against the tempdb database.

USE tempdb;
GO

-- Step 2 - Create a function
--          Note that SQL Server 2012 now includes a new function
--          for calculating the end of the current month (EOMONTH)

CREATE FUNCTION dbo.EndOfPreviousMonth (@DateToTest date)
RETURNS date
AS BEGIN
  RETURN DATEADD(day, 0 - DAY(@DateToTest), @DateToTest);
END;
GO

-- Step 3 - Query the function. The first query will return
--          the date of the end of last month. The second
--          query will return the date of the end of the
--          year 2009.

SELECT dbo.EndOfPreviousMonth(SYSDATETIME());
SELECT dbo.EndOfPreviousMonth('2010-01-01');
GO

-- Step 4 - Determine if the function is deterministic. The function
--          is not deterministic.

SELECT OBJECTPROPERTY(OBJECT_ID('dbo.EndOfPreviousMonth'),'IsDeterministic');
GO
	--0 being not deterministic - cant determine the value..we need a parameter coming in
	--deterministci meaning you can determine ahead of time if you are going to get a vlaue back

-- Step 5 Question for students: SQL Server now includes
--        an EOMONTH function. How could you modify the function
--        above to use that new function?

-- Step 6 - Drop the function

DROP FUNCTION dbo.EndOfPreviousMonth;
GO



 
1. 	
Where would you specify the option (recompile) statement?

A.	 before a select statement in a stored procedure

--B.	after a select statement in a stored procedure

C.	in the command to run a stored procedure

D.	in the command to create a stored procedure

 
2. 	
Where are Transact-SQL statements that are in a stored procedure saved and run?

--A.	They are saved on the server and run on the client. WRONG

B.	They are both saved and run on the client.

C.	 They are saved on the client and run on the server.

D.	They are both saved and run on the server.

 
3. 	
True or false: It is a best practice to prefix the name of a stored procedure with 'sp_'.

--A.	False

B.	True

4. 	
Which two ways does using a stored procedure improve performance?

A.	Data access is improved because stored procedures always use indexes.

--B.	Round trips between the client and the server are reduced because stored procedures are run on the server.

--C.	Stored procedures run more quickly because SQL Server compiles and optimizes them.

D.	The load on the server is reduced because stored procedures are run on the client.

5. 	
Which character is used to prefix the name of a parameter?

--A.	@ (at sign)

B.	$ (dollar sign)

C.	# (pound sign)

D.	! (exclamation point)





