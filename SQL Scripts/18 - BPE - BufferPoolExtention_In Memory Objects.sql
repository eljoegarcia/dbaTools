-- Demonstration 18 - BPE

--Features > 2014
--Using BUffer Pool Extention BPE
--Implimenting Column Store INdexex .2012/14
--Deploying IN-Memory OLTP
--	Memory Optimized Tables
--	Memory Optimized Stored Procedures

--Using Buffer Pool Extention BPE
	--eNABLES TO EXTEND sql sERVER BUFFER CASHE TO NON-VOLETILE STORAGE
		--DATAfiles--> Pages--> Buffer Cashe (RAM)<--Clean Pages (clean data sitting in sQl server data cache)--> Buffer Cashe extention(SSD)
			--(smimilar to Windows Paging File)
			--Not as fast as RAM but faster than traditional spinning disks
	--Improves performance for read heavy OLTP workloads
	--Solid-state devices can be more cost-effective than adding physical memory
		-- easy setup 
		--** avaiable in SQL server standard edition
		--Offers  a simple configuration with no changes to existing applications
			--Scenarios;	
				--VM density for on-premise hosts
					-- so if you have a large , Hyper-V host with 256gig of RAM and you knwo you have to host large sql server - give each one 64gig
					-- if you use bPE - you can estend the use to 128gig, lot more buffer space
				--Public cloud virtual machines with SSDs
					--Get a lot more out of SQL Server 2014 Standard Edition
					-- Get MS vm's with SSD storage presented, bigger VM the more the RAm more expensive say 8Gigs , 16gig RAm with SE SE limit is ..
					-- 128gig of RAM but could extend
					-- that onto SSSD provided wiht VVM get massive buffer pools so could extend 128 GIG to 256gig thus get more cretive configuraion option
					-- enable product to do more with those resources
					-- alebit provide a level one and level two styles RAM
				-- Ram is cheap if looking at consolidation better configuration with performance benefit
				

-- Enable buffer pool extension
ALTER SERVER CONFIGURATION
SET BUFFER POOL EXTENSION ON
(FILENAME = 'C:\temp\MyCache.bpe', SIZE = 32GB );
-- was 16gb - so we're going through the disk subsystem and that where (we would get directly onto the motherboard ) get best performance - best storage that you have the fastest storage available


-- View buffer pool extension details **
SELECT * FROM sys.dm_os_buffer_pool_extension_configuration;
-- see its enabled and set to 33GB in size


-- Monitor buffer pool extension
SELECT * FROM sys.dm_os_buffer_descriptors;
--This DMV Returns one row for every page that is held in data cache regardles if RAM cache
-- show new col 2014>; is-in buffer pool extentio - is_in_bpool_extention
-- ** When we writing queries to anyalyze the configuration of the server, shows amount of dta pages here which databases..
	-- theyre form and their file ID, can write complicated queries to pull out how much cache a particular daatabse has in RAM how much of that
	-- is bein gmoved to BPE - whole aim is you would be able to enable it and SQL Server would use it in background if it thinks it would benefit 
	-- so you wouldnt need to do anymore configuration than that

-- Disable buffer pool extension
ALTER SERVER CONFIGURATION
SET BUFFER POOL EXTENSION OFF;

-- View buffer pool extension details again
SELECT * FROM sys.dm_os_buffer_pool_extension_configuration;


--if drive its running on runs out of space- it would automaticall turn itself off
-- very easy configuration and maintanance
-- ** the only pages that would be moved to the buffer pool extionsion is what we call clean pages so these are committed pages that havenet changed
  -- ..where as dirty pages is something that would in main RAM - not made itslef to Disk yet.. lose no transactions


