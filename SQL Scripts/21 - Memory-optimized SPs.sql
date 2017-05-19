-- Use the MemDemo database
Select @@version

-- Natively Compiled Stored Procedures
CREATE PROCEDURE dbo.Delete Customer @CustomerID INT
	WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH 
	(TRANSACTION ISOLATION LEVEL = SNAPSHOT;
	LANGUAGE = 'us_english')
	DECLARE @Memid int = 1
	DELETE dbo.OpenOrders WHERE CustomerID = @CustomerID
	DELETE dbo.Cuistomer WHERE CustomerID = @CustomerID
END;
GO

-- Written in T-SQL and compiled to native code as cretion time
-- Access memory-optimized tables
-- Contain an atomic block

use master
create database MemoryTable
drop  database MemDemo
sp_detach_db 'MemDemo'

USE MemoryTable

-- Create a native stored proc
CREATE PROCEDURE dbo.InsertData
	WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = 'us_english')
	DECLARE @Memid int = 1
	WHILE @Memid <= 500000
	BEGIN
		INSERT INTO dbo.MemoryTable VALUES (@Memid, GETDATE())
		SET @Memid += 1
	END
END;
GO

-- Use the native stored proc. 
/* Note how long it has taken for the stored procedure to execute. 
This should be significantly lower than the time that it takes to 
insert data into the memory-optimized table by using a Transact-SQL INSERT statement.
*/

EXEC dbo.InsertData;

 
1. 	
Which two tools can be used to query a memory-optimized table?

--A.	native C code

--B.	Transact-SQL

C.	C# managed code

D.	JavaScript

 
2. 	
Which two features are used to implement in-memory OLTP (online transaction processing)?

--A.	natively compiled stored procedures

B.	columnstore indexes

C.	buffer pool extensions

--D.	memory-optimized tables


 
3. 	
What are two features of a non-clustered columnstore index?

A.	The tables are updatable.

--B.	The tables are read-only.

C.	The non-clustered columnstore index must be the only index on the table.

--D.	The non-clustered columnstore index can be combined with other indexes.


4. 	
What are two features of a clustered columnstore index?

--A.	The tables are updatable.

B.	The tables are read-only.

--C.	The clustered columnstore index must be the only index on the table.

D.	The clustered columnstore index can be combined with other indexes.


5. 	
Where should you store data in the buffer pool extension?

--A.	solid state storage

B.	system RAM

C.	hard drives

D.	CPU memory cache














