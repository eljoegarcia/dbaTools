-- Demonstration 3 - Introduction to views

--Views - Virtual table within a database
	--a database object referenced in the same way as a table
	--so select column names from a view name (wouldnt know from query if was a table or a view
	--View is bacically a named SELECT query
	-- eg:
	CREATE VIEW HumanResources.EmployeeList
		(EmployeeID, FamilyName, GivenName)
	AS
	SELECT EmployeeID, FamilyName, GivenName
	FROM HumanResources.Employee;
	--or multiple views like joins

	-- A View doesn not persist data, unless you have an indexed view
	-- Data doesnt exist until when you pull the view it would pull data from underlying table 
	-- WITH SCHEMABINDING option - prevents schema changes to the underlying table
			-- without schema binding if column removed - view would be broken
			--so !! important to use SCHEMABINDING with views
	--If adding a UNIQUE CLUSTERED INDEX to a view it makes it an indexed view - that perists the table independently
			-- so with UNIQUE CLUSTERED INDEX it would generate a new physical table - called an indexed view
			-- DO not overuse
			--Enterprise edition of SQL Server evaluates indexed views - optimizer wil automatically used indexed views to imporve performace of index views
			--So Enterprise is the only edition that would use the index view to maximize performance
		--> can create index views in standard view, simply optimizer
			-- Inserts and updates to views can only affect one underlying table, but NOT if based on multiple tables
				--eg orders and customers, can only effect one of the underlying tables




-- Step 1 - Open a new query window to the AdventureWorks database

USE AdventureWorks2012;
GO

-- Step 2 - Create a new view

CREATE VIEW Person.IndividualsWithEmail
--WITH ENCRYPTION
AS
SELECT p.BusinessEntityID, Title, FirstName, MiddleName, LastName, E.EmailAddress
FROM Person.Person AS p
JOIN Person.EmailAddress as e
on p.BusinessEntityID=e.BusinessEntityID;
GO

-- Step 3 - Query the view

SELECT * FROM Person.IndividualsWithEmail;
GO

-- Step 4 - Again query the view and order the results

SELECT * 
FROM Person.IndividualsWithEmail
ORDER BY LastName;
GO

-- Step 5 - Query the view definition via OBJECT_DEFINITION  (show me the construct of this View)

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Person.IndividualsWithEmail',N'V'));
GO
--Also available under object explorer under views
--CREATE VIEW Person.IndividualsWithEmail  AS  SELECT p.BusinessEntityID, Title, FirstName, MiddleName, LastName, E.EmailAddress  FROM Person.Person AS p  JOIN Person.EmailAddress as e  on p.BusinessEntityID=e.BusinessEntityID;  


-- Step 6 - Alter the view to use WITH ENCRYPTION [Definition of the view gets encrypted](can make troubleshooting difficult

ALTER VIEW Person.IndividualsWithEmail
WITH ENCRYPTION ---hide the definition of the view, stop people from scrypting it out
AS
SELECT p.BusinessEntityID, Title, FirstName, MiddleName, LastName 
FROM Person.Person AS p
JOIN Person.EmailAddress as e
on p.BusinessEntityID=e.BusinessEntityID;

-- Step 7 - Requery the view definition via OBJECT_DEFINITION

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Person.IndividualsWithEmail',N'V'));
GO

-- Step 8 - Drop the view

DROP VIEW Person.IndividualsWithEmail;
GO

-- Step 9 - Script the existing HumanResources.vEmployee view 
--          to a new query window and review its definition. (object explorer

