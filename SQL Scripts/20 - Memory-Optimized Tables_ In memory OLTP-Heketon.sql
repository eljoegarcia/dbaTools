--Enable Memory-Optimized Tables in a Database	
Select @@version

--Code name: ** Heketon
 --to use In-Memory OLTP:
--SQL Server 2016 SP1 (or later), any edition. For SQL Server 2014 and SQL Server 2016 RTM (pre-SP1) you need Enterprise, Developer, or Evaluation edition.

	
--OLTP online transaction processing
https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/survey-of-initial-areas-in-in-memory-oltp
-- In-Memory OLTP
	--NEw in SQL Server 2014
	--HIgh Performance OLTP feATURE -online transaction processing IS THE TARGET SCENARIO
	--Consiste of two parts:
		--1. Memory Optimized tables
		--2. Natively compiled Stored Procedures (to access memory optimized tables)
		
--Memory Optimized tables (in-meory feature had to bepart of the product itself and to be integrated)
	--What are memory optimized tables?
			--When you make an optimized memory table, sql will actually take that definition as a C structure and compile it;
		-- Defined as C structs, compiled into DLLs and loaded into memory
			-- so each time you INSERT into that table - sql server will be using DLLs to interface with that data
			-- So actually converting your transact SQL  you used to create table - converted to C, which is compiled to a DLL,...
			-- and that DLL as loaded, thats what in memory
			-- ** so very very high performance and efficient
		-- Can be persisted as FILESTREAM data, or nondurable
		-- Do not apply any locking semantics - so no locking and blocking problems
			-- everything will be using snapshot based isolation levels
		-- Can be indexed by using hash indexes
		-- Can coexist with disk-based tables
			-- **Key thing for integrating this technology into existing applications - do not need seperate databases / application that youre rewriting 
		-- Can be queried by using T-SQL
		-- Do not support identity columns or foreign key FK constraints
	--Scenarios for memory optimized tables;
		-- ** most benefit where you have Optimistic concurrency optimizes latch-bound workloads
				--reaced the scalability limitations for the traditional architecture  around SQL Server and this is this limitation around locking and latching
				--regardless of how fast memory on disk, still bound to fundemental structure of latching pages in memory and associated blocking
			--Multiple concurrent transactions moduify large number of rows
			--A table contains "hot" pages
				--Hot page; Imagine table of orders,with incrimenting orderID with a clustered index on that key, meaning inserts will occur on the last page
						--So you have lots and lots of client-applications trying to insert data at the same time on that last page. At some point we're ..
						--going to escalate the page level and start blocking any new orders being taken, so those kind of structures can lead to you having pages
						--that are particularly commonly accessed and become your hot pages and lead to a lot of blocking.. so this type of technology
						--is really designed to deal with when you have an application that gives you this hot page and leads to a lot of concurrency.
				--targeted at massive scale.
			--The scenario that this fixes is not that product doesnt work, its that youre trying to do so much against these tables and SQL server will manage
			--concurrency on those pages with latching which is lightweight locking mechanism, so through-put is much much higher.

	-- TO CREATE MEMORY-OPIMIZED TABLES
	--Add a filegroup for memory-optimized data
	ALTER DATABSE MyDb
	ADD FILEGROUP mem_data CONTAINS MEMORY_OPTIMIZED_DATA; --filegroups effectively a placeholder for metadata that defines that table persisted to disk
	GO

	ALTER DATABSE MyDb
	ADD FILE (NAME = 'MemData'
		FILENAME = 'C:\Ttemp\MyDV_MemData.ndf')
	TO FILEGROUP mem_data;	

	--CREATE MEMORY-OPIMIZED TABLE itself
	CREATE TABLE dbo.MemoryTable
	(OrderID INTEGER NOT NUL PRIMARY KEY NONCLUSTERED HASH
			WITH (BUCKET_COUNT = 1000000), -- number of hash buckets were going to make available for this, number of buckets should be ideally the 
											--number of unique values that you will have in that column, flexible enough that you can have non-unique values
											-- Traditional indexes is disk based themselves, these pages are stored on disk and maybe cached, fundemetaly stored on disk
											-- With memory-optimized tables we have two types;
												-- ** hash index this variant;  - key or keys columns/s hash alorythm applied to them to generate unique value -that determines which location in memory this row is going to be stored
													--if same may be placed in same location for same value, then first value put there will have a pointer to the second one, to the third... end up with linked list structure
													-- very effecient if queries are searhing on equality predicates - eg;all sale malcolm
												-- ** Range Index - similar to traditionsal (binary type structure) - again in memory - more effective for ranges of values eg find all values transactions between jan and july
	 OrderDate DATETIME NOT NULL.
	 Quatity INTEGER NULL)
	 WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

	 --MEMORY-OPTIMIZED TABLES
		--Hash Indexes
			-- Assign rows to buckets based on hashing alorythm
			-- Multiple rows in the same bucket for a linked list
		--Range Indexes
			--Use a latch-free BW-Tree structure

	--Querying Memory-optimized Tables
		-- Query Interop   (combine two together)
			--Interpret T-SQL
			--Enables queries that combime memory optimized and disk based tables
		-- Another way is through Native Compilation
			--Stored Procedure converted to C and Compiled
			--Access to momery optimized tables only!

			--NAtive Compilation		--Transact SQL:
			   CREATE PROCEDURE			    Select t1.col1, t3.col2
				Translate to C				FROM Tabl1 t1
		#define __in HRESULT hkp_(...    	JOIN Tabl2 t2
			Compile to DLL 				ON t1.Col1 = t2.col1
				0110101101
--				V		____________________|
				V	   |--QUERY INTEROP-----|
			   	V	   |					|
	--				   V					V
	--     Tab 1	tab2				tab3  tab4
	-- MEMORY OPTIMZED tables		Disk-based Tables


	--DEMO
	use master
	create database memdemo
	use [MemoryTable]
	-- in properties of new database
/*https://docs.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/the-memory-optimized-filegroup
**	On the Filegroups page, in the MEMORY OPTIMIZED DATA section (at bottom_, click Add Filegroup.
**	In the Name box, type MemFG. Note that the filegroups in this section are used to contain FILESTREAM files because memory-optimized tables are persisted as streams.
*/
	ALTER DATABASE [MemoryTable] ADD FILEGROUP MemFG CONTAINS MEMORY_OPTIMIZED_DATA 
/*
**	On the General page, click Add to add a database file. Then add a new file that has the following properties:
****	Logical Name: MemData
****	File Type: FILESTREAM Data   
****	Filegroup: MemFG
**	 In the Script drop-down list, click Script Action to New Query Window.
**	Click Cancel to view the script file that has been generated.
**	Review the script, noting the syntax that has been used to create a filegroup for memory-optimized data. You can use similar syntax to add a filegroup to an existing database.
**	Click Execute to create the database
*/

-- Create a memory-optimized table
Use master
USE MemDemo
GO
DROP TABLE memdemo
GO
CREATE TABLE dbo.MemoryTable
(id INTEGER NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 1000000),
 date_value DATETIME NULL)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);



-- Query Memory-Optimized Tables
-- Create a disk-based table
CREATE TABLE dbo.DiskTable
(id INTEGER NOT NULL PRIMARY KEY NONCLUSTERED,
 date_value DATETIME NULL);


-- Insert 500,000 rows into DiskTable. This code uses a transaction to insert rows into the disk-based table.
-- When code execution is complete, look at the lower right of the query editor status bar and note how long it has taken

BEGIN TRAN
	DECLARE @Diskid int = 1
	WHILE @Diskid <= 500000
	BEGIN
		INSERT INTO dbo.DiskTable VALUES (@Diskid, GETDATE())
		SET @Diskid += 1
	END
COMMIT;

-- Verify DiskTable contents. Confirm that the table now contains 500,000 rows
SELECT COUNT(*) FROM dbo.DiskTable;

-- Insert 500,000 rows into MemoryTable. This code uses a transaction to insert rows into the memory-optimized table.
/* When code execution is complete, look at the lower right of the query editor status bar
   and note how long it has taken. It should be significantly lower than the time that it 
   takes to insert data into the disk-based table.
*/

BEGIN TRAN
	DECLARE @Memid int = 1
	WHILE @Memid <= 500000
	BEGIN
		INSERT INTO dbo.MemoryTable VALUES (@Memid, GETDATE())
		SET @Memid += 1
	END
COMMIT;

-- Verify MemoryTable contents. Confirm that the table now contains 500,000 rows
SELECT COUNT(*) FROM dbo.MemoryTable;

-- Delete rows from DiskTable. Note how long it has taken for this code to execute.
DELETE FROM DiskTable;

-- Delete rows from MemoryTable. 
/* Note how long it has taken for this code to execute. 
It should be significantly lower than the time that it takes to 
delete rows from the disk-based table.
*/

DELETE FROM MemoryTable;

GO

-- View memory-optimized table stats
SELECT o.Name, m.*
FROM
sys.dm_db_xtp_table_memory_stats m
JOIN sys.sysobjects o
ON m.object_id = o.id


--Can view the C -structure in databases - folder called xtp in databases - with file structures-  can view eg used as part of compilation  - view c file in notepad
