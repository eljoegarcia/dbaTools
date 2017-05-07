-- Demonstration 10 - Maintaining Indexes

--FILTERED INDEXes (for Non-Clsutered indexes only)

	--Filtered indexes use a WHERE clause to limit the rows that the index includes
			 CREATE NONCLUSTERED INDEX
					NC_EMP_Adress
			 ON HR.Address
			 (
				AddressLine1,
				AddressLine2
			 )
			 WHERE City = 'New York '
		-- Cannot create a filtered index on a clsutered inx ..be deleting the rows effectively
		--eg big Orders table but only interested in yesterdays orders 
			-- create filtered index based on time, so just maintaining this index for a very small amount of data
	--BENEFITS of filtered indexes;
		-- Faster response times (1000000 row vs top 100)
		--Small storage requirement 
		--Faster rebuild operations (faster to traverse that index)
	--Shares some similarities with indexed views (create a view which gave me a subset of data then index on that view to persist it down,
		--so filtered indexes is a muh cheaper way of achieving what we could have done with an indexed view

--INdex Fragmentation;
	-- Fragmentation occurs when data changes - cause index pages to split
		--TWO TYPEs;
			-- Internal fragmentation when pages are not full (65% full avg page size)
			-- External fragmetation when pages are not in logical sequence (physical ordering on disk - causes traversing arounf the data file)
		-- ** Detecting fragmentation
			-- INdex Properties in SSMS (not common to do this way -quite expensive operation - big overhead
			-- sys.dm_db_index_physical_stats

		--** FILLFACTOR and PAD_index (be familiar with these concepts in every day usage and maintenance)
			-- FILLFACTOR - I know i have to insert addresbook with more "M's" I need to leave space on the paeg
			-- FILLFACTOR leaves space in index leaf-level pages for new data to avoid page splits i.e. it leaves gaps in order to fill later rows
				-- ** ? Generic BEST PRACTICE - 70% /80 - best is 0 or 100 (means same thing) then have more regular index maintenance
					--**tradeoff; -- yes we are avoiding page splits, but you're also telling SQL Server not to optimize the storage space
					--** Really need to know you are going to get page splits to try and avoid them by using FILLFACTOR
			--PAD_INDEX uses the value specified in FILLFACTOR for the intermediate pages of the index
				-- same as FILLFACTOR but for the non-leaf level pages,
				-- so you will use FILLFACTER and PAD_INDEX together so if you are expecting page splits, so this would leave gaps on the non leaf level pages
					Alter table Person.Contact
					ADD CONSTRAINT PK_Contact_ContactID
					PRIMARY KEY CLUSTERED
					(
					ContactID ASC
					)WITH (PAD_INDEX = ON,FILLFACTOR = 70);
					GO
	
-- REMOVING FRAGMENTATION -
	--_ efectively rebuild the index
	--Option 1: REBUILD;
		--Rebuilds the whole index
		--Needs free space in the database (diskspace)
		--Performed as a single transaction (some environments can take 8-12 hours; if fails it will rollback everything it did)
			--beware of transactionslog space requirements
			ALTER INDEX ix_Contact_lastName
			 ON dbo.Person.Contact
			REBUILD;
	--OPtion2: REORGANIZE
			--Sort the pages and is always online
			--LEss transaction log usage
			Work isnts lost if to
		
			ALTER INDEX ix_Contact_lastName
			 ON dbo.Person.Contact
			REORGANIZE;

						
		



	

	
-- Check the level of fragmentation again via sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO

-- Note the avg_fragmentation_in_percent and avg_page_space_used_in_percent

-- Now we'll go ahead and remove the fragmentation

ALTER INDEX ALL ON dbo.PhoneLog REBUILD;
GO

-- Step 11: Check the level of fragmentation via sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO

-- Step 12: Note the avg_fragmentation_in_percent and avg_page_space_used_in_percent

-- Step 13: Drop the table

DROP TABLE dbo.PhoneLog;
GO

