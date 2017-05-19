-- View Logical Reads for a Query


-- What are COLUMNSTORE indexes > 2012
	--In memory, Compressed data pages based on Columns instead of rows
	-- Fundamentally a column store index is a differnet way of SQL, serving the table in a table effectively
	-- thats the tradiontional way that that SQL Server workds and stored pages --in this kind of warehousing scenario,
		-- large scale reporting and large tables we have denotmalized the table construct and we tend to have very wide tables
		-- when we do reporting we then to do reporting on really a subset of the columns in the table so we're not returning
		-- all of the columnsm we're returning a subset and we're returning a subset of columns, row store isnt the mores efficient way of
		-- storing those rows, **hence column stores
		-- So on right- each page contains data for a single columns
			-- Alll 8K pages (if you think how many the number of rows you can store on a page will depend on;
				-- what columns you have
				-- and what data type, cause influence is the size of the row
				-- Whre as with a column store if you take a single column, 
					--you can store many many more rows for that one column on a single page than you could if you have all the columns.
		--** That is the first principle behind this column store technology
			-- because if we are reporting of a subset of Columns,  say order dates reading a single 8k pages I can read 4 times many values
				--that I could if I had to read it traditionally
			-- savings in reading lots of data at once
		--** Second is Compression, uses advantage of that susch as wiht things like Power Pivot (tech for excel, tos tore huge amount of data in memory by using in-memory compression)
			-- So as well as storing column level data, we also compressing the data 
			-- alot more volume of data we can read from a single 8K page - about speed of reading
				--(can read so much we can do aggregation of data on the fly)				

		--ROW STORE									--COLUMN Store
	--ProdID  OrderDate  Cost		 |-		--ProdID	 OrderDate  Cost		
	--310	  20010701    2171.00	 |		--310		20010701    2171.00
	--311	  20010701    1912.12	 |		--311			...	      1912.12		
	--312     20010702	  2171.00	 |		--312		20010702	  2171.00
	--313	  20010702	  413.14	<		--313			...		   413.14
		--DATA Page 1000			 |		--314			...		   333.42			
	--ProdID  OrderDate  Cost	     |      --315		20010703	  1295.00
	--314	  20010702    333.42	 |		--316		 ...		  4233.14	 
	--315	  20010703	  1295.00    |      --317		 ...           641.22 
	--316	  20010702		641.22   |_     --318		20010704       777.00
		--DATA Page1001				  --DATA Page2000	DataPage2001  Page2002

		--SCENARIOs
		--Columntore Index Scenarios
			--** Columnstore indexes are most suitable for; (data warehouse scenarios)
				--Databases that have star or snowflake schemas
					--In computing, the star schema is the simplest style of data mart schema and is the approach most widely used to develop
					-- data warehouses and dimensional data marts.[1] The star schema consists of one or more fact tables referencing any number of dimension tables.
					-- The star schema is an important special case of the snowflake schema, and is more effective for handling simpler queries.[2]
					--In computing, a snowflake schema is a logical arrangement of tables in a multidimensional database such that the entity relationship
					-- diagram resembles a snowflake shape. The snowflake schema is represented by centralized fact tables which are connected to multiple dimensions.
					--more in BI world -Microsoft made two business intelligence (BI) announcements regarding Mobile BI and Power BI, a new Cloud Business Intelligence offering
					-- for Office 365 customers, noting a Public Preview would be available later this summer. That Public Preview will be available soon for anyone interested in evaluating Office 365 Power BI.
					--  You can get access to the Public Preview by registering at PowerBI.com. 
				--Tables that have large number of rows (if not large rows ..not likely to gain from the fact)
				--Tables that contain data that responds well to Compression (lots of repeatable data- text data)
					-- if you have a table full of GUIDs it's not going to compress it very well
						-- A GUID (global unique identifier) is a term used by Microsoft for a number that its programming generates to create a unique identity for an entity 
						--such as a Word document. GUIDs are widely used in Microsoft products to identify interfaces, replica sets, records, and other objects.
							--UUID   universally unique identifier  (UUID) is a 128-bit number used to identify information in computer system

		-- Column Store Index Types
			--Clustered ColumnStore Indexes
				--Can be created in sql 2014 Enterprise, Developer and Evaluation editions only
					--2012 limitation they were read only
					-- now we can read and write to it a real boost to this technology
					-- Same rules apply an in Clustered index you can have one column store indes as it happens you can have a column clustered store index
						-- no additional must include all the columns
				--Include all columns in the table
				--Must be the only index on the table
				--Are Updatable
			--NonClustered ColumnStore Indexes
				--Include some or all columns in the table (subset)
				--Can be combined with other indexes
				--Make the table read-only - limitation - to get around create nightly table loads and then crete the clustered index, nonclustered columns tored index- use for read workloads
				--remember read-only can be usefull, and thing you can use like partitioning
					-- and update and insert to make effective use of nonclustered environment, but yes simpler in clustered index



USE AdventureWorksDW2014
GO

-- Execute the query once... to get data into cache
SELECT p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear,
		AVG(fpi.UnitCost),
		SUM(fpi.UnitsOut)
FROM dbo.FactProductInventory as fpi
INNER JOIN dbo.DimProduct as p ON
fpi.ProductKey = p.ProductKey
INNER JOIN dbo.DimDate as d ON
fpi.DateKey = d.DateKey
GROUP BY p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear
ORDER BY p.EnglishProductName,
		d.CalendarYear,
		d.WeekNumberOfYear


-- ** Now execute and log statistics -- we want to compare and contrast the execution time for this
--** want to compare and contrast the execution time for this

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear,
		AVG(fpi.UnitCost),
		SUM(fpi.UnitsOut)
FROM dbo.FactProductInventory as fpi
INNER JOIN dbo.DimProduct as p ON
fpi.ProductKey = p.ProductKey
INNER JOIN dbo.DimDate as d ON
fpi.DateKey = d.DateKey
GROUP BY p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear
ORDER BY p.EnglishProductName,
		d.CalendarYear,
		d.WeekNumberOfYear


--Take a measure on the messages tab so what we're looking for;
----SQL Server parse and compile time: 
----   CPU time = 15 ms, elapsed time = 55 ms.

----(94248 row(s) affected)
----Table 'DimProduct'. Scan count 5, logical reads 810, physical reads 1, read-ahead reads 251, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
----Table 'DimDate'. Scan count 5, logical reads 172, physical reads 1, read-ahead reads 57, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
----Table 'FactProductInventory'. Scan count 5, logical reads 4229, physical reads 3, read-ahead reads 3854, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
----Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
----Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

---- SQL Server Execution Times:
----   CPU time = 2517 ms,  elapsed time = 2092 ms.



-- Create a non-clustered columnstore index
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

USE AdventureWorksDW2014
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_NCS_FactProductInventory]
ON dbo.FactProductInventory
(
	ProductKey,
	DateKey,
	UnitCost,
	UnitsIn,
	UnitsOut,
	UnitsBalance
);


-- Try to insert a row (this will fail) because it is a non clustered index---read only
INSERT INTO dbo.FactProductInventory
VALUES (214, 20101231, '2010-12-31', 9.54, 2, 0, 4);

-- Now execute and log statistics
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear,
		AVG(fpi.UnitCost),
		SUM(fpi.UnitsOut)
FROM dbo.FactProductInventory as fpi
INNER JOIN dbo.DimProduct as p ON
fpi.ProductKey = p.ProductKey
INNER JOIN dbo.DimDate as d ON
fpi.DateKey = d.DateKey
GROUP BY p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear
ORDER BY p.EnglishProductName,
		d.CalendarYear,
		d.WeekNumberOfYear

-- On the Messages tab, note the elapsed time in the last line of the statistics report
	-- with colmnindex - CPU time reduces from 2564 ms to 483ms, elapsed from 2990ms to 518ms

-- Drop the non-clustered columnstore index, existing clustered index, and foreign keys
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
DROP INDEX [IX_NCS_FactProductInventory] ON [dbo].[FactProductInventory];
GO
ALTER TABLE dbo.FactProductInventory DROP CONSTRAINT PK_FactProductInventory
GO
ALTER TABLE [dbo].[FactProductInventory] DROP CONSTRAINT [FK_FactProductInventory_DimDate];
GO
ALTER TABLE [dbo].[FactProductInventory] DROP CONSTRAINT [FK_FactProductInventory_DimProduct];
GO


-- Create a clustered columnstore index
CREATE CLUSTERED COLUMNSTORE INDEX [IX_CS_FactProductInventory]
ON dbo.FactProductInventory;

-- Insert a row - table is updatable - clustered
INSERT INTO dbo.FactProductInventory
VALUES (214, 20101231, '2010-12-31', 9.54, 2, 0, 4);


-- Now execute and log statistics
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear,
		AVG(fpi.UnitCost),
		SUM(fpi.UnitsOut)
FROM dbo.FactProductInventory as fpi
INNER JOIN dbo.DimProduct as p ON
fpi.ProductKey = p.ProductKey
INNER JOIN dbo.DimDate as d ON
fpi.DateKey = d.DateKey
GROUP BY p.EnglishProductName,
		d.WeekNumberOfYear,
		d.CalendarYear
ORDER BY p.EnglishProductName,
		d.CalendarYear,
		d.WeekNumberOfYear

-- On the Messages tab, note the elapsed time in the last line of the statistics report

---> More than 2/3 rds faster - significant gain


 --I do want to add to all of this, we talked about the fact that 
 --a clustered index is updatable and a non-clustered other than 
 --using various techniques makes the table non-updatable. I just 
 --want to explain a little bit how that works under the covers 
 --because when you use a non-clustered column store index, one 
 --technique that is quite often used is you have your table which 
 --contains your data. But you may create something that goes along 
 --with that table, another table that has the same structure which 
 --you use as a temporary writable space and when you query your 
 --table that contains the non-clustered cluster store index, you 
 --union the results with what's called a delta table which contains 
 --the changes and periodically you marriage those in. So there's 
 --a technique where you can implement some logic to effectively 
 --combine two tables into one logical view of the data and then 
 --merge the changes in. 
 --Actually under the covers, that's how clustered column store 
 --index works. Internally SQL Server maintains a traditional rule-based 
 --delta table portion of that table plus the column store in-memory 
 --part so when you do an insert or an update, what happens is that 
 --delta store table is modified, stored on disk, until we reach 
 --a threshold where a certain number of pages have been updated 
 --and at that point under the covers SQL Server will take those 
 --and absorb them into the column store area so there's a certain 
 --amount of additional complexity under the covers when you use 
 --these things that you might not immediately be aware of. 
 --There are a number of views you can use to see what's currently 
 --in the delta store versus what's been absorbed into the table itself. 
 --But it's worth being aware of that. 