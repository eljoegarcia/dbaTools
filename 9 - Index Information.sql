-- Demonstration 9 - Index InformationIndex


--INDEX DMVs - SYTEM VIEWS
	--** important for every day use
		sys.dm_db_index_physical_stats
		--index deatails around size and fragmentation statistics (fragmentation occusrs as we do updates and inserts)
		sys.dm_db_index_operational_stats
		-- Curretn index and I/O statistics - volume of reads and writes occurs
		sys.dm_index_usage_stats
		-- INdex usage  statistics by access types - where to use effectivily for managing the environment

-- Step 1: Open a new query window against the tempdb database

--USE tempdb;
--GO
use master
Go
Drop database demodb
go
create database demodb
go
use demodb
go


-- Step 2: Create a table with a primary key specified

CREATE TABLE dbo.PhoneLog
( PhoneLogID int IDENTITY(1,1) PRIMARY KEY,
  LogRecorded datetime2 NOT NULL,
  PhoneNumberCalled nvarchar(100) NOT NULL,
  CallDurationMs int NOT NULL
);
GO
-- Add a non-clustered index for reporting later
CREATE NONCLUSTERED INDEX IX_LogRecorded
  ON dbo.PhoneLog (LogRecorded);
GO


-- Step 4: Insert some data into the table

SET NOCOUNT ON;

DECLARE @Counter int = 0;

WHILE @Counter < 10000 BEGIN
  INSERT dbo.PhoneLog (LogRecorded, PhoneNumberCalled, CallDurationMs)
    VALUES(SYSDATETIME(),'999-9999',CAST(RAND() * 1000 AS int));
  SET @Counter += 1;
END;
GO

-- Step 5: Check the level of fragmentation via sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO
--index level of 0 - leaf level pages
--index level of 1 - root page - the highest index level
--look at fragmentation - 7% on avg_fragmentation on clustered
--look at fragmentation - 17% on avg_fragmentation on nonClustered
--look page count - 56 on clustered -storage unit in sql server which is 8K
--look page count - 23 on non-clustered
--look av_opage_space - 99 - tells me pages pretty well full - so nno much fragmentation here



-- Step 6: Note the avg_fragmentation_in_percent and avg_page_space_used_in_percent

-- Step 7: Modify the data in the table  - shuufle dat around to crte some fragmentations

SET NOCOUNT ON;

DECLARE @Counter int = 0;

WHILE @Counter < 10000 BEGIN
  UPDATE dbo.PhoneLog SET PhoneNumberCalled = REPLICATE('9',CAST(RAND() * 100 AS int))
    WHERE PhoneLogID = @Counter % 10000;
  IF @Counter % 100 = 0 PRINT @Counter;
  SET @Counter += 1;
END;
GO

-- Step 8: Check the level of fragmentation via sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO
--lok at new data especially page count up.

-- We'll remove the fragmentation in the next demo

select * 
FROM   sys.dm_db_index_operational_stats (db_id(),NULL,NULL,NULL ) A 

--raw view of data --how the index being viewed

-- Show writes versus reads to see candidates for unused indexes
--** script to review review a database and and overhead to look for unused indexes
SELECT convert(varchar(120),object_name(ios.object_id)) AS [Object Name], 
       i.[name] AS [Index Name], 
	   SUM (ios.range_scan_count + ios.singleton_lookup_count) AS 'Reads',
       SUM (ios.leaf_insert_count + ios.leaf_update_count + ios.leaf_delete_count) AS 'Writes'
FROM   sys.dm_db_index_operational_stats (db_id(),NULL,NULL,NULL ) ios
       INNER JOIN sys.indexes AS i
         ON i.object_id = ios.object_id 
            AND i.index_id = ios.index_id
WHERE  OBJECTPROPERTY(ios.object_id,'IsUserTable') = 1
GROUP BY object_name(ios.object_id),i.name
ORDER BY Reads ASC, Writes DESC


--**indexin logrecorded not being read from - good candidate for removal
-- **stats will be restarted when you restart sql server .. also reset when doing index maintenance - so a flag -- red flag
--** so we want to capture this information on a regular basis


-- Talk about unique constraints
		-- can be a bit of a caveat there