-- Demonstration 8 - nonclustered indexes

--USE ADPCt004;
--GO
SELECT * FROM sys.indexes --WHERE OBJECT_NAME(object_id) = N'PhoneLog';

--NON-CLUSTERED INDEX (index back of book - pointer - RID on a heap)
				--  ((index back of book - pointer -clustered index key KEY - then directly to Clustered index to find info we want)
	--Tables i structured as a heap or a clustered index
		--Heap = Index ID 0
		--Clustered Index = Index ID 1
		--Non-Clustered Index = Index ID 2+
	--Additional indexes can be created
		--These are called non clustered indexes (INdex ID 2+)
		--Separate objects to the table (copied out and stored seperately)
		--Leaf level contains a pointer to the table where the rest of the columns can be found (index at back of book reference to a page number
				-- in sql called a Row IDs - row identifier also called a RID -pointing to a specific row on a heap   )
		--**Like a book Non-Clustered index similar to the index at the back of the book- find the page number of where to find information on aa subject
		--** so a table is either physically careted as a heap or a clustered index, then we can create a a non-clustered index on the same table

--Covering indexes and INCLUDE 
	--A covering index is an index that can provide all the column data required to fulfil a query
		--** Provides better performance as it removes the need to ookup teh data in the tables structure
		-- prior to SQL server 2005 - had to crete a composite index across multiple columns which was expensive
		-- Now the INCLUDE (powerful option to remove lookupswithout overhead of having a very wide index key)
					--clause is used to insert column data into the leaf node of a non-clustered index
			-- eg select lastname(clustered), first name from customers where lastname= malcolm
				-- from root index page (non-clustered -> to index pages -> leaf nodes contains all columns in the SELECT clause 
						--(so no need to look up dat pages in heap or clustered index)
				-- if we had a index on first and lastname - would be a covering index





USE tempdb;
GO

-- Step 2: Create a table

CREATE TABLE dbo.Book
( ISBN nvarchar(20) PRIMARY KEY,
  Title nvarchar(50) NOT NULL,
  ReleaseDate date NOT NULL,
  PublisherID int NOT NULL
);
GO

-- Step 3: Create a nonclustered index on PublisherID and ReleaseDate DESC

CREATE NONCLUSTERED INDEX IX_Book_Publisher
  ON dbo.Book (PublisherID, ReleaseDate DESC);
GO

-- Step 4: Request an estimated execution plan for a query that needs lookups

SELECT PublisherID, Title, ReleaseDate
FROM dbo.Book 
WHERE ReleaseDate > DATEADD(year,-1,SYSDATETIME())
ORDER BY PublisherID, ReleaseDate DESC;
GO

-- Step 5: Replace the index with one that includes the Title column

CREATE NONCLUSTERED INDEX IX_Book_Publisher
  ON dbo.Book (PublisherID, ReleaseDate DESC)
  INCLUDE (Title)--***
  WITH DROP_EXISTING;
GO

-- Step 6: Again, request an estimated execution plan for the query

SELECT PublisherID, Title, ReleaseDate
FROM dbo.Book 
WHERE ReleaseDate > DATEADD(year,-1,SYSDATETIME())
ORDER BY PublisherID, ReleaseDate DESC;
GO

-- Step 7: Use the AdventureWorks Database

USE AdventureWorks2012;
GO

-- Step 8: Query the sys.index_columns system view

SELECT * FROM sys.index_columns;  --includes is_included_column
GO

-- Step 9: Note the is_included_column column, the key_ordinal column
--         and the is_descending_key column

-- Step 10: Combine several system views in a query
--          to locate any included columns in the database

SELECT s.name AS SchemaName,
       OBJECT_NAME(i.object_id) AS TableOrViewName,
       i.name AS IndexName,
       c.name AS ColumnName
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
ON i.object_id = ic.object_id 
INNER JOIN sys.columns AS c
ON ic.object_id = c.object_id
AND ic.column_id = c.column_id 
INNER JOIN sys.objects AS o
ON i.object_id = o.object_id
INNER JOIN sys.schemas AS s
ON o.schema_id = s.schema_id 
WHERE ic.is_included_column <> 0
AND s.name <> 'sys'
ORDER BY SchemaName, TableOrViewName, i.index_id, ColumnName;

-- Step 11: Use object explorer to view the properties of
--          the IX_ProductReview_ProductID_Name index on
--          the Production.ProductReview table. Note the structure
--          of the index and the included column

-- Step 12: Now review the properties of the other index from that 
--          same table that appeared in our list of indexes with 
--          included columns. Note that by definition, included 
--          columns only apply to nonclustered indexes.


