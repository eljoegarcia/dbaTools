--Demonstration 1 - Implement Table Design

-- Step 1: Open a new query window to tempdb
use master
go
drop database tempdb

USE tempdb;
GO

-- Step 2: Create the Customer and CustomerOrder tables
--         and populate them

CREATE TABLE dbo.Customer
(
	CustomerID int IDENTITY(1,1) PRIMARY KEY,
	CustomerName nvarchar(50) NOT NULL
);
GO
INSERT dbo.Customer
  VALUES ('Marcin Jankowski'),('Darcy Jayne');
GO

CREATE TABLE dbo.CustomerOrder
(
	CustomerOrderID int IDENTITY(1000001,1) PRIMARY KEY,
	CustomerID int NOT NULL
	  FOREIGN KEY REFERENCES dbo.Customer (CustomerID),
	OrderAmount decimal(18,2) NOT NULL
);
GO


-- Step 3: Select the list of customers and 
--         perform a valid insert into the CustomerOrder table

SELECT * FROM dbo.Customer;
GO

INSERT INTO dbo.CustomerOrder (CustomerID, OrderAmount)
  VALUES (1, 12.50), (2, 14.70);
GO
SELECT * FROM dbo.CustomerOrder;
GO

-- Step 4: Try to insert a CustomerOrder row for an invalid customer
--         Note how poor the error messages look when constraints are 
--         not named appropriately

INSERT INTO dbo.CustomerOrder (CustomerID, OrderAmount)
  VALUES (3, 15.50);
GO

-- Step 5: Try to remove a customer that has an order
--         Again note how the poor naming doesn�t help much.

DELETE FROM dbo.Customer WHERE CustomerID = 1;
GO

-- Step 6: Remove the foreign key constraint and 
--         replace it with a named constraint with cascade. 
--         Note that you will need to copy into this code the 
--         name of the constraint returned in the error from the 
--         previous statement. This is part of the problem 
--         when constraints are not named.

ALTER TABLE dbo.CustomerOrder
  DROP CONSTRAINT FK__CustomerO__Custo__164452B1;
GO

ALTER TABLE dbo.CustomerOrder
  ADD CONSTRAINT FK_CustomerOrder_Customer
  FOREIGN KEY (CustomerID) 
  REFERENCES dbo.Customer (CustomerID)
  ON DELETE CASCADE;
GO

-- Step 7: Select the list of customer orders, try a delete again
--         and note that the delete is now possible

SELECT * FROM dbo.CustomerOrder;
GO
DELETE FROM dbo.Customer WHERE CustomerID = 1;
GO

-- Step 8: Note how the cascade option caused the orders for the 
--         deleted customer to also be deleted

SELECT * FROM dbo.Customer;
SELECT * FROM dbo.CustomerOrder;
GO

-- Step 9: Try to drop the referenced table and note the error:
DROP TABLE dbo.Customer;
GO


--Cascade Delete

--Cascade Delete may make sense when the semantics of the relationship can involve an exclusive "is part of" description. For example, an OrderLine record is part of its parent order, and OrderLines will never be shared between multiple orders. If the Order were to vanish, the OrderLine should as well, and a line without an Order would be a problem.
--The canonical example for Cascade Delete is SomeObject and SomeObjectItems, where it doesn't make any sense for an items record to ever exist without a corresponding main record.
--You should not use Cascade Delete if you are preserving history or using a "soft/logical delete" where you only set a deleted bit column to 1/true.
--Cascade Update

--Cascade Update may make sense when you use a real key rather than a surrogate key (identity/autoincrement column) across tables.
--The canonical example for Cascade Update is when you have a mutable foreign key, like a username that can be changed.
--You should not use Cascade Update with keys that are Identity/autoincrement columns.
--Cascade Update is best used in conjunction with a unique constraint.
--When To Use Cascading

--You may want to get an extra strong confirmation back from the user before allowing an operation to cascade, but it depends on your application.
--Cascading can get you into trouble if you set up your foreign keys wrong. But you should be okay if you do that right.
--It's not wise to use cascading before you understand it thoroughly. However, it is a useful feature and therefore worth taking the time to understand.




