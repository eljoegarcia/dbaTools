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

	--Option 1: REBUILD;
		--Rebuilds the whole index (takes index offline)
		--Needs free space in the database (diskspace)
		--Performed as a single transaction (some environments can take 8-12 hours; if fails it will rollback everything it did)
			--beware of transactionslog space requirements
			ALTER INDEX ix_Contact_lastName
			 ON dbo.Person.Contact
			REBUILD;
	--OPtion2: REORGANIZE
			--Think of it as old win Defrag
			--Sort the pages and similar to rebuild key is; is always online operation
			--Less transaction log space, if stops or fails, still get benefit of whats being reorgnanized up to that point
				-- eg clinet with 10tb clustered database with 99% fragmentation, they dont have the disk space tp do a rebuild,
					--so they can reorganize nightly over a week weeks, then regular maintenance
			A LTER INDEX ix_Contact_lastName
			 ON dbo.Person.Contact
			REORGANIZE;

	--Online INdex operations;
		Alter index is_Contact_EmailAddress
		ON Prson.Contact
		REBUILD
		WITH(ONLINE = ON, MAXDOP=4);
		--*** Enterspise edition ofSQL Server can rebuild indexes online
			-- Enables cioncurrent user access
			--	Slower than taking it online, bigger space requirements, (creates copy of index in background then switches when complete)
			-- Effectively creates a new index in parallel with the old so space in the data file is a consideration (using row versioning_
				--knock-on effect of tempdb
			-- ** Great feaute but has,Lots of overhead associated with it

	--STATISTICS
			--separate object used by the optimizer - to get estimate of how many row would be returned
		--Statistics exists to help the optimizer chooose a good excution plan
		--They are used to help estimate the selectivity of an operation
		use Invoices
		dbcc show_statistics ('accounts_receivable', invo_number)
		--col: Range_hi_KEy - then shows how many rows has the value of col RANGEHIKEY) ; RANGE ROWS
			--between row 1 and 2 we have rows = Range Rows,with x distinct values, with use of that vlaue= avg_range rows
		-- if a bunch of descrete values and searching for an individual valeu probably want to use an index, -
			--if only two discrete values might as well scan all the pages in there

		--STATS; AS DATA CHANGES** we need to keep statistics update
			--As data changes, staticstics become outdated
			-- A flag automatically updaes statistics (or on demand) (autoupdatestats)
			--ON demand;
				AUTO_UPDATE_STATISTICS
				--Database option by default (db property)
				UPDATE STATISTICS
				--Manually trigger an update for a table or specific tasks - take another cut of the distribution of the data
					-- help optimizer better guess for specific stats
				sp_updatestats
				--UPdates all the statistics in the database
				ALTER INDEX REBUILD
				--Also rebuilds the statistics with FULLSCAN
				--As you build index there will be a set of stats asscoiated with that index based on its distribution

			 
		
						
		



	

	use INvoices
-- Check the level of fragmentation again via sys.dm_db_index_physical_stats
--created from previous mod -resulting in 90% fragmenation and 65% avg page space used,258 page count

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.Invoices'),NULL,NULL,'DETAILED');
GO

-- Note the avg_fragmentation_in_percent and avg_page_space_used_in_percent

-- Now we'll go ahead and remove the fragmentation

ALTER INDEX ALL ON dbo.PhoneLog REBUILD;
GO

-- Step 11: Check the level of fragmentation via sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.PhoneLog'),NULL,NULL,'DETAILED');
GO
--now -->created from previous mod -resulting in 53% fragmenation and 98% avg page space used,160 page count

-- Step 12: Note the avg_fragmentation_in_percent and avg_page_space_used_in_percent

-- Step 13: Drop the table

DROP TABLE dbo.PhoneLog;
GO


 
1. 	What occurs when a record is updated in a table that has a clustered index?
A.	The updated record is always moved to the top of the table.

-->B.	The updated record remains in the same position only if the clustered index remains the same.

C.	The updated record is always moved to the end of the table.

D.	The updated record always remains in the same logical position.

 
2. 	What occurs when a record is deleted from a table that has a clustered index?
A.	The data is removed but the space remains allocated.

B.	The space that was occupied by the record does NOT become available.

-->C.	The space that was occupied by the record becomes available.

D.	The record is moved to a recycle table.

3. 	Which data does a leaf node of a clustered index contain when the clustered index belongs to a heap?
-->A.	row IDs

B.	table data

C.	page data

D.	keys


 
4. 	What is a fill factor used for?
A.	 to align data to byte boundaries

-->B.	to avoid page splits

C.	to align data to page boundaries

D.	to avoid disk fragmentation

 
5. 	True or false: A table that does not have a clustered index is known as a heap.
-->A.	True

B.	False

 
2. 	Where are new records stored when they are inserted into a table that has a clustered index?
A.	at the top of the table

B.	at the end of the table

C.	in a separate index table

--D.	in their correct logical positions


 
3. 	Which data does a leaf node of a clustered index contain when the clustered index belongs to a heap?
A.	table data

B.	page data

C.	keys

--D.	row IDs

 
4. 	Which two statements about a clustered index are true?
--A.	A clustered index determines the order that data is stored.

B.	A table can have multiple clustered indexes.

C.	A clustered index causes data to be stored in the order it is entered.

--D.	A table can have only one clustered index.





















