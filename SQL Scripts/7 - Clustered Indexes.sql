
-- Demonstration 7 - Clustered Indexes

--INDEX fundamentals 
	-- SQL sever accesses data using a table scan or via an index ( on eg a simple select statement)
		-- In a table scan SQL reads all the pages (because they are unordered)
		-- When using an index, SQL sever wil use the index pages to find the required rows
		--						010101								[root node]
		--				01011					10100	
		--		01001			0100     10100				10100	[Leaf node]
		--**Like a book - read it cover to cover or lookup what you want to find

	-- Indexes can be Clustered (ref to a table) or non-clustered (or a heap)
		-- Can create indexes directly with CREATE INDEX statements or by specifying a PRIMARY KEY	 (Clustered index)
			--if specify a PRIMARY KEY SQL Server support that key as by creating a CLUSTERED index
		-- Clustered index: rows a re stored in a logical order
				-- therefore only one clustered index per table
				-- a table without a clustered index is known as a HEAP (heap of data--unordered data)
					--eg a heap of unordered resumes
				-- All data is stored in leaf nodes
				-- Clustered index - Analogous to contents of a book
					-- defines physical ordering of the contents
				--Operations on Clustered indexes (CRUD)
					--INSERT (create)
						--each new ro must be placed into the correct logical postion
							--**Like a book - say an addressbook..find the pages where a's or b's are and insert right place
						--May invlove splitting pages of the table
							--**Like a book - say an addressbook..if B's are full we have to insert a page (sql calls splitting the page)
					--UPDATE (update)
						--The new row can either remain in the same place if it still fits (could be updated fomr varchar 3 to varchar 50) and clustering key value still the same
						--if the row no longer fits the page, page needs to be split
						--if the clustering key has changed - row needs to be removed and place in the correct position
					--DELETE (delete)
						--Frees up space by flagging the data as unused
					--SELECT (read)  (seeks & scans)
						-- Queries related to the clustering key can "seek"
						-- Queries related to the clustering key can "scan" and void sorts

						--**Like a book Non-Clustered index similar to the index at the back of the book- find the page number of where to find information on aa subject


-- Step 1: Open a new query window against the tempdb database


USE tempdb;
GO

-- Create a table without a primary key (so no index created - so this is a HEAP - sql accesses data as a table scan (unordered data)
CREATE TABLE dbo.PhoneLog
( PhoneLogID int IDENTITY(1,1),
  LogRecorded datetime2 NOT NULL,
  PhoneNumberCalled nvarchar(100) NOT NULL,
  CallDurationMs int NOT NULL
);
GO

-- Show execution plan for a scan (sql sservers optimized plan decides which way to go(only way) - table scan
SELECT * FROM dbo.PhoneLog

-- Drop table
DROP TABLE dbo.PhoneLog


-- Step 2: Create a table with a primary key specified (Clustered now so execution plan is Clustered index scan)
			-- can create a non-clsutered if specify ; PRIMARY KEY NON CLUSTERED
CREATE TABLE dbo.PhoneLog
( PhoneLogID int IDENTITY(1,1) PRIMARY KEY,
  LogRecorded datetime2 NOT NULL,
  PhoneNumberCalled nvarchar(100) NOT NULL,
  CallDurationMs int NOT NULL
);
GO

-- Show execution plan for a scan
SELECT * FROM dbo.PhoneLog


-- Step 3: Query sys.indexes to view the structure
-- (note also the name chosen by SQL Server for the constraint and index)

SELECT * FROM sys.indexes WHERE OBJECT_NAME(object_id) = N'PhoneLog';
GO --automatically creted a Primary key based on the clustered index and also listed as constraint
SELECT * FROM sys.key_constraints WHERE OBJECT_NAME(parent_object_id) = N'PhoneLog';
GO
-- Drop table
DROP TABLE dbo.PhoneLog


