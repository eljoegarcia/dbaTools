-- Demonstration 12 - Stored Procedure Parameters

--USING INPUT PARAMETERS
	--parameters have @ prefixand datatype specified, and can have a default value
	--Can be passed either in order or by name but not in combination of the two

		CREATE PROCEDURE sales.OrderDateStatus
			@DueDate datetime, @Status tinyint = 5
		AS 
		SELEcT SalesOrderID, OrderDate,CustomerID
		FROM Sales.SalesOrderHeader as soh
		where soh.DueDate =@DueDate and soh.[Status] = @Status;
		GO
--USING OUTPUT PARAMETERS
	--PUTPUT must be specified
		--when declaring the parameter
		--When executing the Stored Procedure
			--when coding you would specify in your ADO.net class you are building..
			--to connect to the database, whats the direction of th aparameter

				CREATE PROC SALES GetOrderCountByDueDate
				@Duedate datetime, @orderCount int OUTPUT
				AS
					SELECT (OrderCount = COUNT(1) --executing get order count by duedate
					FROM Sales.SalesorderHeader as soh
					WHERE soh.Duedate = @Duedate;
				GO

				DECLARE @DueDate datetime '200507713';
				DECLARE @ordercount int;
				EXEC sales.GetOrderCountByDueDate @Duedate,
												@ordercount OUTPUT; --specify ordercount as output
				SELECT @OrderCount;

-- Step 1: Open a new query window to the AdventureWorks database

USE AdventureWorks2014;
GO

--get sp

SELECT SCHEMA_NAME(schema_id) AS SchemaName,
       name AS ProcedureName
FROM sys.procedures;
GO
-- Step 2: Drop the Production.GetBlueProducts and 
--         Production.GetBlueProductsAndModels stored procedures

DROP PROC Production.GetBlueProducts;
DROP PROC Production.GetBlueProductsAndModels;
GO

-- Step 3: Replace the Production.GetBlueProductsAndModels with
--         a new stored procedure that takes a color parameter
--         Note that we can't use ALTER as we really also need to
--         change the name of the procedure

CREATE PROC Production.GetProductsAndModelsByColor
@Color nvarchar(15)
AS
BEGIN
  SELECT p.ProductID,
         p.Name,
         p.Size,
         p.ListPrice 
  FROM Production.Product AS p
  WHERE p.Color = @Color 
  ORDER BY p.ProductID;
  
  SELECT p.ProductID,
         pm.ProductModelID,
         pm.Name AS ModelName
  FROM Production.Product AS p
  INNER JOIN Production.ProductModel AS pm
  ON p.ProductModelID = pm.ProductModelID 
  WHERE p.Color = @Color 
  ORDER BY p.ProductID, pm.ProductModelID;
END;
GO

-- Step 4: Execute the new procedure

EXEC Production.GetProductsAndModelsByColor 'Red';
GO

-- Step 5: Now another bug report has come in saying
--         that the procedure works fine except for 
--         products that don't have a color. We need 
--         to test that situation

EXEC Production.GetProductsAndModelsByColor NULL;
GO

-- Step 6: We notice that no rows come back. Many products
--         do not have a color. Ask students how we 
--         could fix the problem.

-- Step 7: The issue is that we can't equate NULL values
--         as they need IS NULL instead. So let's fix the
--         procedure.

ALTER PROC Production.GetProductsAndModelsByColor
@Color nvarchar(15)
AS
BEGIN
  SELECT p.ProductID,
         p.Name,
         p.Size,
         p.ListPrice 
  FROM Production.Product AS p
  WHERE (p.Color = @Color) OR (p.Color IS NULL AND @Color IS NULL)
  ORDER BY p.ProductID;
  
  SELECT p.ProductID,
         pm.ProductModelID,
         pm.Name AS ModelName
  FROM Production.Product AS p
  INNER JOIN Production.ProductModel AS pm
  ON p.ProductModelID = pm.ProductModelID 
  WHERE (p.Color = @Color) OR (p.Color IS NULL AND @Color IS NULL)
  ORDER BY p.ProductID, pm.ProductModelID;
END;
GO

-- Step 8: Now test the procedure again

EXEC Production.GetProductsAndModelsByColor 'Red';
GO
EXEC Production.GetProductsAndModelsByColor NULL;
GO

-- Step 9: Drop the stored procedure

DROP PROC Production.GetProductsAndModelsByColor;
GO
