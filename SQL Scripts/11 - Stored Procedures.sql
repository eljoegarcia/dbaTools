-- Demonstration 11 - Stored Procedures

--STORED PRODCEDURES AND FUNCTIONS

--STORED PROCEDURES
	--When applications interact with SQL Server there are two basic ways to execute T-SQL code;	
		-- Every Statement can be issued by the application
		-- Group of Statements can be stored on the server as store procedure and given a name
	--Stored Procedures can:
		-- Have input Parameters
		-- Have Ouut Paramaetrs
		-- Can return sets of Rows

	--** BEnefits of Stored Procedures
		--They are a security Boundary
			--Users can be givern permission ro execute a SP without permission to the underlying objects
		-- Enable modular programming - helps develop applications against SQL server
		-- Can also improve performance
			--A single statement requested accross the network can execute hundreds of line of code - 
				--also rather this SP thatn all these lines of code - less fragile if db changes
			--Better opportunities for excecution plan reuse (optimizer)

	-- Example sp in sales schema
	--CREATE PROCEDURE
	--If the procedure already exists use alter
	CREATE PROCEDURE Sales.GetSalespersonsNames
	AS
	BEGIN
		Select sp.SalesPersonID, c.Lastname,c.Firstname
		FROM Sales.salesperson as sp
		INNER JOIN Person.Contact AS c
		on sp.SalesPersonID - =c.ContactID
		WHERE sp.TerritoryID IS NOT NULL
		ORDER BY sp.SalesPersonID
	END;
	--EXECUTE SP
		--USE EXECUTE statement to execute SP and other objects such as dynamic SQL statements stored in a string
			-- Commonly abbreviated as EXEC
			EXEC
		--ALWaYs use two-part naming when executing local sp's (as stated before alwasys when refering to objects) 
		  --otherwise SQL Server will have to search
			-- In the sys schema of the current database
			-- In th Callers Default schema in the current database
			-- In the dbo schema of the current datatabse
				--eg  exec Sales.GetSalespersonsNames
		--Stored Procedure GUIDELINES
			--Qualify onject names inside stored Procedures - two part naming
				--Objects will default to the stored procedure Schema
				--**Apply a consistent naming convention and dont use the sp_prefix (sp more for persistent stored procedure, think of as Special Procedure)
					-- ratehr use usp - User sp  -eg uspGet...  uspUdate
				--Keep to one procedure for each task
					-- Procedures that do everything create execution plans that are difficult to use
							--** eg on website with lots of tcick boxes if use same usp - dont try to do much within a single construct
		--With Encryption
			-- as with views
			-- Encrypts sp functions
			-- Most often used by 3rd parties to try protect Intellectual Property (IP)
			-- generally not recommended - really hard to troubleshoot, if code lost no can fix

				CREATE PROCEDURE 
					Sales.GetSalespersonsNames
				WITH ENCRYPTION
				AS
					Select SalesPersonID. Lastname,Firstname
					FROM Humanresources . Emloyee;



-- Demonstration 11 - Stored Procedures


-- Step 1: Open a new query window to the AdventureWorks database

USE AdventureWorks2012;
GO

-- Step 2: Create the GetBlueProducts stored procedure

CREATE PROC Production.GetBlueProducts
AS
BEGIN
  SELECT p.ProductID,
         p.Name,
         p.Size,
         p.ListPrice 
  FROM Production.Product AS p
  WHERE p.Color = N'Blue'
  ORDER BY p.ProductID;
END;
GO

-- Step 3: Execute the stored procedure

EXEC Production.GetBlueProducts;
GO

-- Step 4: Create the GetBlueProductsAndModels stored procedure

CREATE PROC Production.GetBlueProductsAndModels
AS
BEGIN
  SELECT p.ProductID,
         p.Name,
         p.Size,
         p.ListPrice 
  FROM Production.Product AS p
  WHERE p.Color = N'Blue'
  ORDER BY p.ProductID;
  
  SELECT p.ProductID,
         pm.ProductModelID,
         pm.Name AS ModelName
  FROM Production.Product AS p
  INNER JOIN Production.ProductModel AS pm
  ON p.ProductModelID = pm.ProductModelID 
  ORDER BY p.ProductID, pm.ProductModelID;
END;
GO

-- Step 5: Execute the GetBlueProductsAndModels stored procedure
--         Note in particular that multiple rowsets can be 
--         returned from a single stored procedure execution

EXEC Production.GetBlueProductsAndModels;
GO

-- Step 6: Now tell the students that a bug has been
--         reported in the GetBlueProductsAndModels 
--         stored procedure. See if they can find the 
--         problem

-- Step 7: The problem is that the 2nd query doesn't also
--         check that the product is blue so let's alter
--         the stored procedure to fix this

ALTER PROC Production.GetBlueProductsAndModels
AS
BEGIN
  SELECT p.ProductID,
         p.Name,
         p.Size,
         p.ListPrice 
  FROM Production.Product AS p
  WHERE p.Color = N'Blue'
  ORDER BY p.ProductID;
  
  SELECT p.ProductID,
         pm.ProductModelID,
         pm.Name AS ModelName
  FROM Production.Product AS p
  INNER JOIN Production.ProductModel AS pm
  ON p.ProductModelID = pm.ProductModelID 
  WHERE p.Color = N'Blue'
  ORDER BY p.ProductID, pm.ProductModelID;
END;
GO

-- Step 8: And re-execute the GetBlueProductsAndModels stored procedure

EXEC Production.GetBlueProductsAndModels;
GO

-- Step 9: Query sys.procedures to see the list of procedures

SELECT SCHEMA_NAME(schema_id) AS SchemaName,
       name AS ProcedureName
FROM sys.procedures;
GO



