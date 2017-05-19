-- Demonstration 15 - Table-Valued Function

--IMPLEMENTING TABLE-VALUED FUNCTIONS
	--  returns a TABLE data type
	-- two types;
		--INLINE TVFs which has a single SELCT statement
		--Mumtistatement TVFs that will allow to Construct, Populate and reurn a table within the Function
			--Can Be used to replace views where more complex logic is needed to achieve those results


-- Step 1 - Open a new query window against the AdventureWorks database

USE AdventureWorks2014;
GO

-- Step 2 - create a table-valued function

CREATE FUNCTION Sales.GetLastOrdersForCustomer 
(@CustomerID int, @NumberOfOrders int)
RETURNS TABLE
AS
RETURN (SELECT TOP(@NumberOfOrders)
                              soh.SalesOrderID,
                              soh.OrderDate,
                              soh.PurchaseOrderNumber
                FROM Sales.SalesOrderHeader AS soh
                WHERE soh.CustomerID = @CustomerID
                ORDER BY soh.OrderDate DESC
               );
GO

-- Step 3 - Query that function. It will return the last two 
--          orders for customer 17288.

SELECT * FROM Sales.GetLastOrdersForCustomer(17288,2);
GO

-- Step 4 - Now show how CROSS APPLY could be used to call this 
--          function
	--** Good for trouble shooting  and for views as well and evaluating some of those dynamic management functions

SELECT c.CustomerID,
             c.AccountNumber,
             glofc.SalesOrderID,
             glofc.OrderDate 
FROM Sales.Customer AS c
CROSS APPLY Sales.GetLastOrdersForCustomer(c.CustomerID,3) AS glofc
ORDER BY c.CustomerID,glofc.SalesOrderID;

-- Step 5 - Drop the function

DROP FUNCTION Sales.GetLastOrdersForCustomer;
GO