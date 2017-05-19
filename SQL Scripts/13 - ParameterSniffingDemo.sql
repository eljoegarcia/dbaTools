-- Demonstration 13 - Parameter Sniffing

-- Parameter sniffing AND performance	
	--Execution plans can be expensive to create so generally we want to re-use them as much as possible
	-- If your data has an un-even distribution (**lumpy data) it can cause problems with plan re-use
			--few values of some data but lots and lots of values of another within the same table so distribution is uneven..causes
			-- problem we call parameter sniffing
	--Parmater sniffing is this processof executing the SP and sql Server would sniff the parameter and bases the execution plan based ..
		--on that parameter and ecery every subsequent execution wil be based on that plan
		-- eg 200,000 producst, 50k blue, 49k red , 1 white..execution plan different for white than blue or red, exe baswed on which was cashed
	-- ** Options for resolving
		-- CREATE PROCEDURE xyz WITH RECOMPILE --similar to modify SP itself
		-- EXEC xyz WITH RECOMPILE
		-- OPTION(OPTIMIZE FOR)  -- to tell the optimizer which value to design this execution
			--so optimize for the 90% or larger quantity


--DEmo paramter sniffing causing poor Performance
-- get db and look at nested loops and proprty and parameter list under properties

USE peopleSQLNexus
GO
-- Show query and run to reset demo
Alter procedure [dbo].[usp_countrysearch]
@country varchar(80)
AS
SELECT p.lastname, p.dob, p.sex, c.country
FROM people p join country c
ON p.personid = c.personid
WHERE c.country = @country
GO

-- Show query plan for UK
DBCC FREEPROCCACHE  --not going to be reused
GO
EXEC usp_countrysearch 'UK'
GO

-- Show query plan for US
DBCC FREEPROCCACHE
GO
EXEC usp_countrysearch 'US'
GO

-- Don't clear plan cache. Show bad plan and parameter sniffing
EXEC usp_countrysearch 'UK'
GO


-- Options to fix
-- 1 Run stored procedure with recompile
EXEC usp_countrysearch 'UK' WITH RECOMPILE
GO

EXEC usp_countrysearch 'US' WITH RECOMPILE
GO

-- 2 changed stored procedure and use statement level recompile
ALTER procedure [dbo].[usp_countrysearch]
@country varchar(80)
AS
SELECT p.lastname, p.dob, p.sex, c.country
FROM people p join country c
ON p.personid = c.personid
WHERE c.country = @country
OPTION (RECOMPILE);
GO

EXEC usp_countrysearch 'UK'
GO

EXEC usp_countrysearch 'US'
GO

-- 3 changed stored procedure and use optimize for
ALTER procedure [dbo].[usp_countrysearch]
@country varchar(80)
AS
SELECT p.lastname, p.dob, p.sex, c.country
FROM people p join country c
ON p.personid = c.personid
WHERE c.country = @country
OPTION (OPTIMIZE FOR (@country = 'UK') );
GO

DBCC FREEPROCCACHE
GO
EXEC usp_countrysearch 'US'
GO

DBCC FREEPROCCACHE
GO
EXEC usp_countrysearch 'UK'
GO


