--Temporary table common useful topic within SQL server
--here we use to compare and contrast;	
		-- temporary tables and
		-- table variables

	--TEMPORARY TABLES hold temporary results sets in a users session
		--Created in tempdb and deleted automatically
				--(effectively if you wanted a loading table --put that within tempDB (which will use a scratch db)
				-- when ssql server restarts tempdb is recreated so all tmp tables gone, not persist beyond reboot -thus for workspace
				
				CREATE TABLE #tmpProducts
				(
					ProductID integer,
					productname varchar(50),
				);
		-- # Created with a # prefix (creates locally scoped temporary table)
		-- ## Created with a ## prefix (creates  Global scoped temporary table) any session would be able to access not just session youre in
	--TABLES VARIABLES (for small datasets as server does not maintain statistics -moslty used in practice
		--Introduced because temporary tables can cause recomplications	
			--like normal tables, sql server maintains a;
				-- set of statistics (contained data, a distribution of data within a table)
				-- as data changes, distribution of data changes - stats updated - can generate a recompilation of the code - 
				--can give you different execution plan thus can cause performace problems (adding additional workload)
		--used similary to TEMPORARY tables but scoped to batch -so scoped to piece of code youre running rather thatn whole session
		--key is not statistic variables on table variables
			--Estimates are always 1 row (very effective for small datasets)
		--only use on small datasets

				DECLARE @tmpProducts table
				(
					ProductID integer,
					productname varchar(50),
				);

				--demo with db called people
use master
go
create database people
go
--drop database people
--get table from resources
		
-- Step 1: Open a new query window to the tempdb database

USE people;
GO

-- Step 2: Create a temporary table
--drop table #people
CREATE TABLE #People
( 
personid UNIQUEIDENTIFIER,
firstname VARCHAR(80),
lastname VARCHAR(80),
dob DATETIME,
dod DATETIME,
sex CHAR(1)
);
GO

-- Step 3: Populate the table

INSERT #People
SELECT TOP(250)*
FROM dbo.people



-- Step 4: Query the table and show actual row estimates

SELECT count(*) FROM #People;
GO

-- Step 5: Disconnect and reconnect 
--         (right-click the query window and choose Connection then Disconnect,
--          then right-click the query window and choose Connection then Connect,
--          in the Connect to Server window, click Connect)

-- Step 6: Attempt to query the table again (this will fail)

USE tempdb;
GO

SELECT count(*) FROM #People;
GO

-- notice when disconneting and reconnecting table gone

DROP TABLE #People

-- Do the same with a Table Variable

DECLARE @people TABLE 
( 
personid UNIQUEIDENTIFIER,
firstname VARCHAR(80),
lastname VARCHAR(80),
dob DATETIME,
dod DATETIME,
sex CHAR(1)
)
INSERT @people
SELECT TOP(250)*
FROM dbo.people


-- Now run the select. It will fail. Run it all as a batch
SELECT count(*) FROM @people

--if run execution plan - estimated of rows - should be 1
