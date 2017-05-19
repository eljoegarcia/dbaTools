-- Demonstration 17 - Locking and Deadlocks


---** TRANSACTions thisnk about ACID;
	--Atomic, Consistent Isolated and Durable
	-- Atomic - work all done then stored; explicitily create a transaction with beging transactionm committ plan in hand or or a rollbak
	-- With mupltiple users i want isolation levels to determine what i can read that may be in prcocess of being modified by a transaction,
	--question based on chhosing the appropriate isolation level depending on whcih type of anomalities your application can deal with.
	-- Fundamentally comes down to tracking tracking for the deadlock victim error are retrying or whatever ou need to do

-- MANAGING CONCURRENCY
	-- Concurrencey abalility for multiple processes to access the same data at the same time
		-- lots of users interacting with same data at same time
	--TWO Approaches to manage this effectively
		-- Pessimistic - assumes that different processes will try to read and write to the same data simmultaneously
			--Users lock to prevent conflicts
			-- Default/ traditional concurrency model for SQL Server to use  locking - remove access to avoid these kind of conflicts
		-- Optimistic - (since 2005) assumes that it is unlikely that readers and writers will be in conflict
			--Doesn't use locks - introduced the snapshot-based isolation levels..
				--us row verioning rather than locking to manage concurrency

	--Potential Concurrency issues
		-- Concurrency anomalies
			--with lost updates, 
			--dirty reads,
			--non-repeatable reads (shop - closing down, getting tills take in, but tills are still trading, ie, value changed
			--Phantom rows being inserted
		--Not always unwanted
			--we'd use isolation levels to control whether or not we want these non-repeatable reads and dirty reads..
				--to be introduced into the application
				--eg you can keep people out your data with no-repeatble reads	

		--ISOLATION LEVELS
			--Read UnCommitted ( No locks)
				-- Least Isolated and best performing - but,allows dirty reads, non-repeatable reads and phantoms
				-- Doesn't hold locks when reading data (benefit)
				--Downsirde you're getting this uncomitted data
				--...happy to read data while it has not been comitted (Dirty Data)
				-- People often use this because it doesnt take locks to read data
					--fits more performant, but cause lots of problems cause your not loacking data that youre reading

			--Read Committed ( drop our shared lock once we have read it)
				--** Default isolation level for SQL Server - ionly data that has  bbeen committed
				-- No Dirty reads nut non-repeatable reads and phantoms are still possible (pahntoms - data in process that has not been comitted yet
				-- To do That I will take a lock to prevent people updating it while I read
				-- Wait for someone to comit their data before I read it, so I could be blocked by someone writing data

			--Repeatable Read ((lock everyone out - till Im done what im doing)
				-- is essentailly under read Comitted if we are reading from a table, we will take a shared lock once we've read it
					-- allowing you to read the same data twice
					-- then drop our shared lock once we have read it - under Repeatable read we are saying we are going to read  the data, but when..
					-- I read it again it needs to not have changed,so Im going to put a lock on it, and hold that lock until Im finished 
					-- what Im doing
				-- Difference between read committed Holds Locks for the duration of the transaction to prevent 
					-- others transactions modifying the data
				-- benefit in terms of isolation but.. you sacrifice concurrency
				--Prevents dirty reads and non-repeatable data reads but still allows phantoms

			--Serializable  (lock everyone out)
				-- Serializes access to data and prevents all anomalities
				-- Holds Locks for transacion duration and key range locks for rows that don't even exits yet
				-- The most isolated level of transaction and damaging to concurrency
				--** tend not to use in day-to-day operations
				-- its place would be where there are not a high likelyhood of lots of different users (concurrency)

			--SnapShot Isolation (no lock)
				--The only Optimistic Isolation level 
				--(since 2005)
				--uses Row versions rather than Locks - when you write, prevous version gets stored in the version store which is TempDb and
					-- and if read will be returned from tempDb instead of being blocked i.e allow access to previously comitted value
				--Prevents all anomolies but update conflicts can occur which will cause a transaction rollback
				--Use to resolve the situation of readers and writers blocking each other because allows for much greater concurrency

			--** Lock are for the duration of the entire transaction till committed or rolled back
			-- our implict transactions individual statements will hold locks and realase them
			--** day-to-day operations we'd use read comitted or repeatable read (more loose in how we are flxible in managing concurrency)
			--When doing an explicit transactiona that does lots of things, might end up holding lots of locks until ready to committ

			--Understanding LOCKING ... the mechanism
				-- SQL Server uses Locks to deliver the level of isolation you specify (read COmmitted deafault)
				--Two Main Locking modes **;
					-- Shared   -  sh -- Required to read data (whenever you read data i need shared lock)
					-- Exclusive - ex- Required to write data - can't have multiple people writing same data at the same time
										--so only one person gets exclusive lock in order to update data
						 --sh and ex are not compatible
				--Other Locking Modes
					--Update - used to prevent deadlocks
						--Taken when a process needs to read data before updating it, its automatic so wont control this behaviour
							--if you wanted to do and update based on data you read you would do an update lock before doing an exclusive lock
					--Intent - Intent shared, Intent shared and Intent Exclusive, and Intent updatelock that.. is
								-- Used to indicate that locks are present at a lower level of granularity
							-- if I want to read a row, i would take a shared lock on the row,and i am going to take a shared lock on hte page, 
							--	and a intent shared lock on hte table, to prevent someone from caoming in and taking a higher lovel lock...
							--  if there is an intent lock shared lock at the table level that lock is incompatible for write
							-- A shared lock on a row will also create and intent shared loc on the page and table which it belongs to

			--Problems LOCKING PROBLEMs;
				--Blocking Locks
					--Processes are waiting for access to resources (combination of read write causes blocking locks -  really process waiintg for access to resources
						-- not wrong, its how the product works based on your business logic and application scenario
							-- (application can have timeout or retry mechanism eg 30 sec)
							-- ** troubleshoot mature appliations around these blocking locks
				--Deadlocks
					--Two processes each hold a lock that the other needs to continue (mebrace of I cant complete cause i need a lock on this resource and vise versa)
					--SQL server wil Automatically detect and resolve this situation
					--SQL Server would kill the Cheapest transaction to rollback is chosen as the victim
						-- the application needs to able to reiisue that  transaction and everything carries on
					--so not necesssarily a problem and lots of applications will infrequently see deadlock problems, as long as handled aproprately by application
						-- several dealocks in a day would be reason to investigate, one every 6 month not a problem)
					--**BEst Practise development update eg in usp to update tables in the same order eg cust table then address then prod table
				--Trace Flags 1204 and or/1222  can be used to diagnose deadlock information
					--** Trace flags are a way to enable what were undocumented pages in SQL server, but now we would use it to enable extra functionality in the product
					--**  Trace flags are frequently used to diagnose performance issues or to debug stored procedures or complex computer systems.
					-- so in this instance 1022 1222 will spit out lots of additional information when a deadlock was detected
					-- if getting these deadlock - enable these trace flags permanently so we could analyze the outputs and resolve these deadlocks
					-- switch on with DBCC TRACEON
				--DBCC TRACEON (1222,-1)
					--Enables the trace flag for all sessions
					--Spits out an XML output of blocking deatils and 1204 was an older version of that
					-- Enable both and should ** be aware that both deadlocks enable trace flags
					-- CAn alose configure they come on when I start SQL server service to it - in COnfiguration Manager ass a startup parameter minut=s T and ...
					--	then it will always be there


						Select @@version



USE [TSQL]
GO

-- Talk about read committed versus repeatable read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ --repeatable read -- allow to read the same data twice
												-- diffferent from default which is read comitted
GO
BEGIN TRANSACTION
SELECT * FROM HR.Employees
WHERE lastname = 'Buck'
	-- reason why on repatble read;
	-- .. if I was on read comitted I would take a shared lock on the row and as soon as I had read the data i would drop that shared lock
	-- in repeateable read I am holding that shared lock for the duration of the transaction

	-- ** check session locks
SELECT request_session_id AS Session,
resource_database_id AS DBID,
Resource_Type,
resource_description AS Resource,
request_type AS Type,
request_mode AS Mode,
request_status AS Status
FROM sys.dm_tran_locks
ORDER BY [session]

-- Shows session I am in, got a key lock --IS - Intent Shared Lock on page and object level, --S - Shared lock on database
--so have a share on on anyone with the value of Buck on last name but also any future rows with the value buck so this
--is a key lock rather thatn a row lock
-- so eg noone can delete these rows cause you cant get an exclusive lock when there is a IS lock
-- so update is stuck
--

-- talk about the locking modes and key lock

-- start a different window

UPDATE HR.Employees 
SET titleofcourtesy = 'Dr.'
WHERE lastname = 'Buck'

-- The new session has an update lock on the same page as the previous session. Update locks are compatible are used to read data before changing it. 
-- on this window run the locks - see new modes - from new session 
	-- IX intent exclusive, u- update lock - read before update  - X - Conversion into an exclusive lock, because we want to make a right so we're doing an update

-- Refreshing the tran_locks view doesn't change anything so look to see whats blocking


--** who is waiting for things - 
SELECT session_id,wait_duration_ms,wait_type,
blocking_session_id,resource_description
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
--troubleshootnig called dm_is_waiting tasks
-- wait_type: LCK_m_X; means Lock - on an exclusive lock, can also tell session lock id and which session it is blicked by

-- if we rollback update can complete
ROLLBACK TRANSACTION

-- Create a deadlock

DBCC TRACEON (1222,-1) -- -1 means enable this trace line for all sessions
GO

--Run Profiler and setup deadlock graph
	-- Profiler is a tool that can be used to lookat what sql server is doing when you are executing code and it's quite a heavyweight
	-- ... tool in itself and i really beyond the scope of this session
		-- set use templeate to blank  onevents selection tab - expand locks - check deadlock graph
		-- set up that trace to be running we'll capture some niforamtion on that

-- Session 1
BEGIN TRANSACTION
	UPDATE HR.Employees 
	SET titleofcourtesy = 'Dr.'
	WHERE lastname = 'Buck'

	-- run session2 (1) from new window
	-- ** check session locks
-- Session 1
	UPDATE HR.Employees  
	SET titleofcourtesy = 'Dr.'
	WHERE lastname = 'King'

-- Session 2(1)(on new window) both session2
BEGIN TRANSACTION
	UPDATE HR.Employees  
	SET titleofcourtesy = 'Dr.'
	WHERE lastname = 'King'

-- Session 2
	UPDATE HR.Employees  
	SET titleofcourtesy = 'Dr.'
	WHERE lastname = 'Buck'

	-- start a new window  and look at errorlog - beacasue of trace log
	-- also see information in profiler -intent is its much quicker also bear in mind, profiler is client-side tracing
	sp_readerrorlog
	2017-05-17 12:57:20.040	spid33s	deadlock-list
2017-05-17 12:57:20.040	spid33s	 deadlock victim=process46c71f088
2017-05-17 12:57:20.040	spid33s	  process-list
2017-05-17 12:57:20.040	spid33s	   process id=process46c71f088 taskpriority=0 logused=120 waitresource=KEY: 12:72057594039762944 (40fd182c0dd9) waittime=21786 ownerId=396684 transactionname=user_transaction lasttranstarted=2017-05-17T12:48:35.033 XDES=0x46c299000 lockMode=U schedulerid=6 kpid=9460 status=suspended spid=55 sbid=0 ecid=0 priority=0 trancount=3 lastbatchstarted=2017-05-17T12:56:58.260 lastbatchcompleted=2017-05-17T12:56:58.260 lastattention=1900-01-01T00:00:00.260 clientapp=Microsoft SQL Server Management Studio - Query hostname=DEVELOP-02 hostpid=2020 loginname=sa isolationlevel=repeatable read (3) xactid=396684 currentdb=12 lockTimeout=4294967295 clientoption1=671090784 clientoption2=390200
2017-05-17 12:57:20.040	spid33s	    executionStack
2017-05-17 12:57:20.040	spid33s	     frame procname=adhoc line=1 stmtstart=70 stmtend=210 sqlhandle=0x020000004304fe15e144b2a1aed7d118cf6e2841b24430420000000000000000000000000000000000000000
2017-05-17 12:57:20.040	spid33s	unknown     
2017-05-17 12:57:20.040	spid33s	     frame procname=adhoc line=1 stmtstart=2 stmtend=154 sqlhandle=0x02000000814856273de59ab278371ad9757b61f9b62929510000000000000000000000000000000000000000
2017-05-17 12:57:20.040	spid33s	unknown     
2017-05-17 12:57:20.040	spid33s	    inputbuf
2017-05-17 12:57:20.040	spid33s	 UPDATE HR.Employees  
2017-05-17 12:57:20.040	spid33s	 SET titleofcourtesy = 'Dr.'
2017-05-17 12:57:20.040	spid33s	 WHERE lastname = 'King'    
2017-05-17 12:57:20.040	spid33s	   process id=process46b959c28 taskpriority=0 logused=240 waitresource=KEY: 12:72057594039828480 (dff70333efcc) waittime=1913 ownerId=398910 transactionname=user_transaction lasttranstarted=2017-05-17T12:55:57.683 XDES=0x47832f000 lockMode=U schedulerid=5 kpid=18636 status=suspended spid=56 sbid=0 ecid=0 priority=0 trancount=2 lastbatchstarted=2017-05-17T12:57:18.133 lastbatchcompleted=2017-05-17T12:57:18.133 lastattention=1900-01-01T00:00:00.133 clientapp=Microsoft SQL Server Management Studio - Query hostname=DEVELOP-02 hostpid=2020 loginname=sa isolationlevel=read committed (2) xactid=398910 currentdb=12 lockTimeout=4294967295 clientoption1=671090784 clientoption2=390200
2017-05-17 12:57:20.040	spid33s	    executionStack
2017-05-17 12:57:20.040	spid33s	     frame procname=adhoc line=1 stmtstart=70 stmtend=210 sqlhandle=0x020000004304fe15e144b2a1aed7d118cf6e2841b24430420000000000000000000000000000000000000000
2017-05-17 12:57:20.040	spid33s	unknown     
2017-05-17 12:57:20.040	spid33s	     frame procname=adhoc line=1 stmtend=152 sqlhandle=0x02000000b4916737dcc1ba814fe6c16cee9b2a638b2a4f940000000000000000000000000000000000000000
2017-05-17 12:57:20.040	spid33s	unknown     
2017-05-17 12:57:20.040	spid33s	    inputbuf
2017-05-17 12:57:20.040	spid33s	UPDATE HR.Employees  
2017-05-17 12:57:20.040	spid33s	 SET titleofcourtesy = 'Dr.'
2017-05-17 12:57:20.040	spid33s	 WHERE lastname = 'Buck'
2017-05-17 12:57:20.040	spid33s	  resource-list
2017-05-17 12:57:20.040	spid33s	   keylock hobtid=72057594039762944 dbid=12 objectname=TSQL.HR.Employees indexname=PK_Employees id=lock4786b7d80 mode=X associatedObjectId=72057594039762944
2017-05-17 12:57:20.040	spid33s	    owner-list
2017-05-17 12:57:20.040	spid33s	     owner id=process46b959c28 mode=X
2017-05-17 12:57:20.040	spid33s	    waiter-list
2017-05-17 12:57:20.040	spid33s	     waiter id=process46c71f088 mode=U requestType=wait
2017-05-17 12:57:20.040	spid33s	   keylock hobtid=72057594039828480 dbid=12 objectname=TSQL.HR.Employees indexname=idx_nc_lastname id=lock4786bae00 mode=U associatedObjectId=72057594039828480
2017-05-17 12:57:20.040	spid33s	    owner-list
2017-05-17 12:57:20.040	spid33s	     owner id=process46c71f088 mode=U
2017-05-17 12:57:20.040	spid33s	    waiter-list
2017-05-17 12:57:20.040	spid33s	     waiter id=process46b959c28 mode=U requestType=wait
 
  
1. 	How does pessimistic concurrency prevent the same data from being updated simultaneously by two different processes?
--A.	While a record is accessed by one process, it is locked to prevent another process from accessing and updating it.

B.	While a record is accessed, it is versioned and a conflict resolution algorithm determines the outcome.

C.	The second transaction to complete is processed.

D.	The first transaction to complete is processed


 
2. 	True or false: Error checking can be used instead of explicit transactions to guarantee atomic processing.
A.	True

--B.	False

3. 	Which statement is used to make the results of an explicit transaction permanent?
--A.	commit

B.	save

C.	alter

D.	update



4. 	True or false: The default concurrency technique used by SQL Server is pessimistic concurrency.
--A.	True

B.	False

 
5. 	Which data is handled atomically as part of an implicit transaction?

--A.	all rows that are part of the same update statement

B.	all data that is updated by single stored procedure

C.	a single row in a table

D. all columns and rows that are part of the same update statement  --x Wrong


