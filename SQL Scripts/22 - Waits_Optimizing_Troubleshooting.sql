-- Demonstration 22 - Waits

--Optimizing and Troubleshooting

	-- SQL Server Waits
	--Joining too many tables
	-- Other performance tips



-- SQL Server Waits
	-- SQL server Waits Architecture
													-- SQL Server has a co-operative scheduler
													-- Windows has a pre-emptive scheduler 
																--(windows is a generel purpose OS from my desktop to a powerful server) for multiple 
																-- applciations, langauges uses & nothing to optimize windows on my laptop
																--You get a time slice in order to do your execution														
		--Session -->

		--Task-->			  []  []  []

		-- Worker Thread (Running) -->

		--Scheduler-->       ()  ()  ()  ()
													--<<--Co-Operative Scheduling
		--Logical CPU-->     []  []  []  []				( (may have hyper threading, may have virtual CPUs'))
													-- When SQL Starts it will look at the number of CPUs it sees when it starts
														-- and generate one scheduler per CPU -- called; --Co-Operative Scheduling Model (schduling threads on CPUs)
				--** Fundementally a CPU can only ever do one thing at one time - gives illusion of multitasking
					--because its switching between these treads very very fast (** swithing context switches) large number of workloads trying to compete
					--SQl cooperates with other threads to provide more effecient execution model

	-- When you connect to SQL Server you connect in the context of a session
		--Tracked by a Session ID (SPID)
	--When execute piece of code SQL Server generates (internal structure) for execution youre trying to use -->  a task concept
	-- When we're talking about things running we're refering to a worker thread
		-- Task then assigned a worker Thread
		--** Session
			-->Task
				-->Worker Thread assigned to execute the task
					 --> assigned to a Scheduler
						 --> Shcedulers job to schedule time for workers to execute on a processor (Logical CPU)

	--SQL Server WAITS Architecture;
		--threads can be in one of 3 states;
			--1. Running State eg :  Running Scheduler 1 55 Runnning   [Thread running under context of Session ID 55 on Scheduler 1] (ie thread running on processer)
			--2. Suspended State eg: Suspended Scheduler 1	(if not running...suspended, store what im waiting for) 
							-- 52 PAGEIOLATCH_SH		|
							-- 54 CXPACKET				|
							-- 60 LCK_M_S				|--> SQL Server Wait
							-- 61 LCK_M_S				|
					--So anything in this suspended state is what we call a SQL Server WAIT
			--3. Runnable State eg - volunary yield while i wait for something - run ..then get back to queue back to runnable state
							-- 53 Runnable				|
							-- 56 Runnable				|
							-- 59 Runnable				|--> Signal Wait (way to track CPU Pressure)
							-- 52 Runnable				|
		-- Useful Wait types; 
			-- PAGEIOLATCH		>-- Pure Wait - a latch on a page in memory (read data from a table eg select * - got to memory before sent back) 
									-- so im going to use this in a minute, so no-one use it while go get data to put into it
			-- CXPACKET			>--Synchronization packet, indicates we have parrallism running on systemm sync between parralel threads	
									-- meaning multiple processors -- also meaning we have expensive queries (usine moer thatn one processors
									-- and if expensive determine because they have not been written properly or they need to be expensive to achive business logic

			-- WRITELOG			>-- Writelog -is a wait to write to the transaction log, high level indicator of transaction log write performance
			-- LCK_M_*			>-- Locking - not just resource utilization and resource waits also involves locking eg blocked by shared
			-- PREEMPTIVE_*		>-- Premptive wait types - >2008 windows preemptive, sql is waiting for windows to return something
								-- eg customer could log in with sql server counts but not with domain accounts - everyone was waiting for..
									-- preemptive authentication OPs wait types (meaning sql was waiting to enumerate Windows groups from a domain controller..
									-- found domain controller was broken
								-- Another eg it will also look at filesystem - it will have a premptive wait type, so SQL has to do an autogrow 
								--** therefore wait types is an excellent troubleshooting tool, as everyting from a slow file system to broken domain controller, to
									-- locking problems yu can see from this single view -- very powerful
				
				-- If we can track what threads are waiting for and aggregate those we can essentially have a look at the bottlenecks in the system

--DMVs to View Wait Information;
-- ** ** **
sp_who --> new replacement;


select * from sys.dm_exec_requests
Where session_id >50 --user generated sessions
			--user session always be > 50
			--system generated systems can spil over
	--Session Level ONly -  so wont see the wait types for anymore than 1 task sitting at that level

	
select * from sys.dm_os_waiting_tasks
Where session_id >50 --user generated sessions
--REally interested in working at this task level; -- find out whos currently waiting for something
		--Very Accurate (because its a live view on who is waiting for what at time when you select)
			-- Very useful for a live problem
		--Transient data
		-- system threads sleep, pole ,wakeup we tend to ignore

	
select * from sys.dm_os_wait_stats 
Order by wait_time_ms desc
 -- probably first thing to look at if performace issues (re: history - since last restart) -- good startying point
	-- if you have lots f users waiting for a very short time period not really noticblem over time an accumulative effect on overall performance;
	--Cummulative waits by wait type ( a row for every possible wait type) aggregated statistics (historical data)
	--persistent data
	--Then trim out wait time that are benign basically - sleep task
	-- then checks eg Lck_M_X awaiting for exclusive lock especially if single user



	
--SLOW Query 
Select p.*
from production.product p 
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..
join Production.Product...........  = p.Porduct..

--Kind of real scenario -- number of joins, not consitent in the way it runs
--becasue of amount of joins and way optimizer works
-- Optimizer ...check properties ...Reason for early termination  Time Out .. optimizer will work out a good way of executing that time
	-- Does not look for best way to execute..it looks for a good way in a reasonable amount of time
	-- IN this query with so many joins we've hit this threshold of  areasonable time plan , 
	--So optimizer has dom=ne as much as it could find a resonable plan and its jsut going to take the best one for that time period

--Join Order; in the eg we are doing a join between two tables(Customer & Order)
	--Possible permutations;
	--Customer_id--------------->Order_id
				  -------------->Customer_id (FK)
	--Customer_name				Order_date
	--...    					...
	
	-- how many ways can the optimizer can join these two tables;
		-- Customer -> Order
		-- Order	-> Customer
	--The number of Choices increases exponentially with more joins
	--The order in which joins happen is important (to optimizer) in terms of the way you write your code
		-- incidently unles you start using hints in your code. So there ** is a little tip there - if you start using query hints the optimizer ..
		-- will assume that you know what you're doing and it will enforce the join order in the order that you've written it

--Join Order; in the eg we are doing a join between Three tables(Customer & Order & Product)
		
	--Customer_id--------------->Order_id        <---------------Product_id
				  -------------->Customer_id (FK)				 product_name				  	
	--Customer_name				Order_date
	--...    					...
	--Possible permutations;
		-- (Customer -> Order) -> Product
		-- (Order -> Customer) -> Product
		-- Product ->(Customer -> Order) 
		-- Product ->(Order -> Customer)
		-- Customer ->(Order -> Product)
		-- Customer ->(Product -> Order)

--Join Order
	-- There are n! (N factorial) possible permutations (them more tables you join, more possible permutations 
		--Where n is the number based on number of tables in the statement
		--With 6 joins you have 700 possible permutations (quite reasonable)
		--With 7 joins you have 5,000 possible permutations (reasonable)
		--With 10 tables there are 3,628,800 permutations
		--With 14 tables there are over 86 BILLION permutations
	-- This is even before the optimizer has had the chance to evaluate data access methods, join algorithms etc.
		-- What happens effectively the optimier hsa to evaluate plans in a reasonable amount of time.. timing out
		--The optimizer has to evaluate plans in a reasonable amount of time and will time out keeping the best plan it had found up to then
		-- Better off having a bad plan that finishes in 10 minutes,than taking the tim to find the best one
		-- Thus the same plan wont be guaranteed (uses best one found in that time period)

--Help the optimizer
	-- We get inconsistent performance becuase the optimizer is scurrying about trying to find the best plan, and runs out of time trying to find one
	-- Key is, when you find these tables and you have 14 joins, really
			--1. simplify the query first and foremost
		-- think about it with 6 joins you have 700 possible permutations, 7 joins has around 5,000
			--2. so keep table joins around 6 or 7 joins
			--3. Also consider database design
Select p.*
into #temp1
from production.product p 
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..

Select pm.*
into #temp2
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..

Select #pdoc.*
into #temp3
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..
join Production.Product...........  = p.Product..

Select p*
from #temp1 p 
join #temp2. pm on p.Poduct.= p.Porduct.
join #temp3 pdoc on pdocon pdoc.prod= p.Porduct.


	-- Simplify -- take long query and break it down into multiple sections eg break into 3 select statements
		-- load them into temporary tables
		-- then finally join three tables together
			-- although same query, more effictive to split join 3, load in temptable then join 3 finals

-- Other PErformance Tips
	-- Make sure your variables and column names have identical data types`
		--eg store procedure with a parameter of age, so you amde parameter tiny int data type
			-- So you wrote that data into a table but the age type was int
					-- Now there is an implicit conversionfrom tiny int to int - a tiny tiny CPU cycle change that you don't notice
					-- but if you scale that out, agin talking massive concurrence, masive scale, you'll find you have a creeping
					-- CPU utilization problem, becaus eyou have a 1000 or 10k millions of implicit conversions between data types- causes compound problem
	-- Avoid the use of Scalar UDFs in the WHERE clause
		--Optimizer has no idea of the data that's going to return to that function, when it creates the plan
		-- thus does not know how to optimize the plan when using Scalar UDF
			-- as it doesnt know what the values are, until it runs the function
				--... eg Show me this data, WHERE Ill tell you what I'm going to filter later - how do you optimize that?
				--Recommend run that Scalar UDF and pass that valuethough as a parameter that the optimizer then has visibility of.
	--MAssive decision trees in stored procedure
		--If this do this - have problems with dynamic SQL that's created in masive SP if this, add this appends this and appends this and does this
			-- end up with scenario of parameter sniffing used to generate the code you just created won't make for a reuseable plan
			-- dont do too much within a single piece of code ( break in smaller units, for optimizer to crete smaller plans for those code units

















	--DEMO

USE people
GO

EXEC usp_looppeopleinsert 10000
GO

SELECT * FROM sys.dm_exec_requests
GO

SELECT * from sys.dm_os_waiting_tasks
GO

SELECT * from sys.dm_os_wait_stats
GO
VIEW SERVER STATE
	
SELECT * FROM sys.dm_os_wait_stats





https://www.mssqltips.com/sqlservertip/1949/sql-server-sysdmoswaitstats-dmv-queries/

WITH Waits AS 
 ( 
 SELECT  
   wait_type,  
   wait_time_ms / 1000. AS wait_time_s, 
   100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct, 
   ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn 
 FROM sys.dm_os_wait_stats 
 WHERE wait_type  
   NOT IN 
     ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 
   'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 
   'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT') 
   ) -- filter out additional irrelevant waits 
    
SELECT W1.wait_type, 
 CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s, 
 CAST(W1.pct AS DECIMAL(12, 2)) AS pct, 
 CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct 
FROM Waits AS W1 
 INNER JOIN Waits AS W2 ON W2.rn <= W1.rn 
GROUP BY W1.rn,  
 W1.wait_type,  
 W1.wait_time_s,  
 W1.pct 
HAVING SUM(W2.pct) - W1.pct < 95; -- percentage threshold;


 
1. 	
True or false: The SQL Server scheduler allows each thread to have only a single running process.

--A.	True

B.	False

 
2. 	
How does the Windows preemptive scheduler assign time to multiple processes?

A.	Each process is assigned a dedicated CPU core.

-- B.	Each process gets a fixed slice of time.

C.	Each process runs from start until completion without being interrupted.

D.	Each process uses the CPU until that process must fetch data.


Which three resources does SQL Server assign to each running process during a session?

--A.	a dedicated scheduler
--
--B.	a dedicated task

C.	a dedicated cache

--D.	a dedicated logical CPU

 
4. 	
Which two actions improve the performance of a query?

A.	using scalar functions in the where clause

--B.	reducing the number of if statements in stored procedures

--C.	ensuring that variables and column names have the same data type

D.	using joins rather than multiple select statements



5. 	
True or false: The number of choices for the optimizer increases exponentially as the number of joins in a query increases.

A.	False

-- B.	True







