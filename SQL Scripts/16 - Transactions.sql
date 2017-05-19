-- Demonstration 16 - Transactions

--We've looked a t tables, indexes and Sp and functions - no learn..
	-- how we can encapsulate programing logic and functions in sp, we want to take it to the next level...
	-- and talk about using that logic to manage transactions an make sure our modifications to the data is done in an atomic ..
	-- and secure fashion and make sure transactions go through.
	https://technet.microsoft.com/en-us/library/jj856598(v=sql.110).aspx
-- MANAGING TRANSACTIONS (fundemental concept)
	-- A Transcation is a group opf tasks defining a unit of work (doesnt have to be a group) 
	-- The entire Unit must succeed or fail together -no partial completion permitted
	-- Idividual data modification statements are automatically treated as standalone transactions
		--Implicit transactions (eg ;single update statement - all or none - no partial
			-- Dont have to make it explicit cause ot is implicit in what youre trying to do
				--eg
			--PArtial success is possible, even with structured handling
				BEGIN TRY
					INSERT INTO sales.Orders... --Transaction
					INSERT INTO sales.OrderDetails... --Transaction
				END TRY
					SELECT ERROR_NUMBER()
				END CATCH
				GO
				--So, if pass on first insert and fails on second, first will not rollback, but second would

	--** Explicit transactions - USer can transactions can be managed with T-SQL
		--BEGIN (to begin transaction)/COMMIT(to finish transaction/ROLLBACK TRANSACTION(rollback)GitHUGitHuib Markb
		--Explicit transaction
			--Transaction commands identify blocks of code that must succeed or fail together and provide
			-- points where the database engine can roll back operations
				BEGIN TRY
				  BEGIN TRANSACTION --<
					INSERT INTO sales.Orders... --Transaction
					INSERT INTO sales.OrderDetails... --Transaction
				  COMMIT TRANSACTION --<
				END TRY
				BEGIN CATCH
				  ROLLBACK TRANSACTION		
				  SELECT ERROR_NUMBER()
				END CATCH
				GO
			Transaction Basics
----A transaction is a sequence of operations performed as a single logical unit of work. A logical unit of work must exhibit four properties, called the atomicity, consistency, isolation, and durability (ACID) properties, to qualify as a transaction.
----Atomicity
------A transaction must be an atomic unit of work; either all of its data modifications are performed, or none of them are performed.
----Consistency
------When completed, a transaction must leave all data in a consistent state. In a relational database, all rules must be applied to the transaction's modifications to maintain all data integrity. All internal data structures, such as B-tree indexes or doubly-linked lists, must be correct at the end of the transaction.
----Isolation
------Modifications made by concurrent transactions must be isolated from the modifications made by any other concurrent transactions. A transaction either recognizes data in the state it was in before another concurrent transaction modified it, or it recognizes the data after the second transaction has completed, but it does not recognize an intermediate state. This is referred to as serializability because it results in the ability to reload the starting data and replay a series of transactions to end up with the data in the same state it was in after the original transactions were performed.
----Durability
------After a transaction has completed, its effects are permanently in place in the system. The modifications persist even in the event of a system failure.	

-- Step 1: Open a new query window to the TSQL database
USE TSQL;
GO

-- Step 2: Create a table to support the demonstrations
-- Clean up if the tables already exists
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;
GO
CREATE TABLE dbo.SimpleOrders(
	orderid int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	custid int NOT NULL FOREIGN KEY REFERENCES Sales.Customers(custid),
	empid int NOT NULL FOREIGN KEY REFERENCES HR.Employees(empid),
	orderdate datetime NOT NULL
);
GO
CREATE TABLE dbo.SimpleOrderDetails(
	orderid int NOT NULL FOREIGN KEY REFERENCES dbo.SimpleOrders(orderid),
	productid int NOT NULL FOREIGN KEY REFERENCES Production.Products(productid),
	unitprice money NOT NULL,
	qty smallint NOT NULL,
 CONSTRAINT PK_OrderDetails PRIMARY KEY (orderid, productid)
);
GO

-- Step 3: Execute a multi-statement batch with error 
-- NOTE: THIS STEP WILL CAUSE AN ERROR

BEGIN TRY
	INSERT INTO dbo.SimpleOrders(custid, empid, orderdate) VALUES (68,9,'2006-07-12');
	INSERT INTO dbo.SimpleOrders(custid, empid, orderdate) VALUES (88,3,'2006-07-15');
	INSERT INTO dbo.SimpleOrderDetails(orderid,productid,unitprice,qty) VALUES (1, 2,15.20,20);
	INSERT INTO dbo.SimpleOrderDetails(orderid,productid,unitprice,qty) VALUES (999,77,26.20,15);
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

-- Step 4: Show that even with exception handling, 
-- partial success occurred and some rows were inserted 
SELECT  orderid, custid, empid, orderdate
FROM dbo.SimpleOrders;
SELECT  orderid, productid, unitprice, qty
FROM dbo.SimpleOrderDetails;


-- Step N: Clean up demonstration tables
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;
GO

CREATE TABLE dbo.SimpleOrders(
	orderid int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	custid int NOT NULL FOREIGN KEY REFERENCES Sales.Customers(custid),
	empid int NOT NULL FOREIGN KEY REFERENCES HR.Employees(empid),
	orderdate datetime NOT NULL
);
GO
CREATE TABLE dbo.SimpleOrderDetails(
	orderid int NOT NULL FOREIGN KEY REFERENCES dbo.SimpleOrders(orderid),
	productid int NOT NULL FOREIGN KEY REFERENCES Production.Products(productid),
	unitprice money NOT NULL,
	qty smallint NOT NULL,
 CONSTRAINT PK_OrderDetails PRIMARY KEY (orderid, productid)
);
GO

-- Step 3: Create a transaction to wrap around insertion statements
-- to create a single unit of work
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO dbo.SimpleOrders(custid, empid, orderdate) VALUES (68,9,'2006-07-12');
		INSERT INTO dbo.SimpleOrderDetails(orderid,productid,unitprice,qty) VALUES (1, 2,15.20,20);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	ROLLBACK TRANSACTION
END CATCH;

-- Step 4: Verify success
SELECT  orderid, custid, empid, orderdate
FROM dbo.SimpleOrders;
SELECT  orderid, productid, unitprice, qty
FROM dbo.SimpleOrderDetails;

-- Step 5: Clear out rows from previous tests
DELETE FROM dbo.SimpleOrderDetails;
GO
DELETE FROM dbo.SimpleOrders;
GO

--Step 6: Execute with errors in data to test transaction handling
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO dbo.SimpleOrders(custid, empid, orderdate) VALUES (68,9,'2006-07-15');
		INSERT INTO dbo.SimpleOrderDetails(orderid,productid,unitprice,qty) VALUES (99, 2,15.20,20);
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
	ROLLBACK TRANSACTION
END CATCH;

-- Step 7: Verify that no partial results remain
SELECT  orderid, custid, empid, orderdate
FROM dbo.SimpleOrders;
SELECT  orderid, productid, unitprice, qty
FROM dbo.SimpleOrderDetails;


-- Step N: Clean up demonstration tables
IF OBJECT_ID('dbo.SimpleOrderDetails','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrderDetails;
IF OBJECT_ID('dbo.SimpleOrders','U') IS NOT NULL
	DROP TABLE dbo.SimpleOrders;


	


