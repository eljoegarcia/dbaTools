-- Demonstration 2 - Working with Schemas

--filegroups - f i want to savedb elsewhere (sd drive)
--under propeties of the new bd, under filegourps add- eg fast disk
--- then under files add fastdrive


	-- 1. Naming Boundary NAMING BOUNDARIES
	-- GROUP DATABASE OBJECTS
	--uSE SCHEMA NAME WHEN REFERENCEING DATATABASE OBJECT TO AID NAME RESOLUTION
		--[SERVER.][DATABASE.]Schema.object   <--- refernece a schema
	--Could in theory hava a sales schema that has a product in it and a production schema that has a product it
	
		-- **development and production schema code from - prove a naming boundary, group around business function for database or application
	--2. **Security boundary- 
		--simplify security configuration (new user /developer ) eg:
				--GRANT EXECUTE ON SCHEMA::Sales
				GRANT EXECUTE ON SCHEMA::Sales
		--database objects inherit permission set at the schema level
		-- ALSO eg on Stored Porcedures rather than granting each individual SP Access, use granting of schema

		---IF we don't specify a default schema
	--!! Default Schema and Name Resolution
		--- performance tuning tip is around this defaultschema and naming resolution
		-- TIP:BEST PRACTICE always use this two part naming convention of schema and object name is really scalability
		--
		--eg 
							--user 1				user 2				user3
		--default schema:	  sales			defaultschema:ops		no Default
		--								** select * from table	**
		-->					Sales.Product			OPS					dbo

		--- 1st SQL looks for obj at default schema 1st
		--- 2nd then if not exists looks at DBO schema
		--- then return object not found if not exist
			--user in sales can reference and object in dbo, will work very fast but if you scale it upto thousands of users
			--and thousands of transactions - this is it in the deault schame --no check dbo cause scalabilty issues
		-- there are default behaviours --best practice is to to BE EXPLICIT like no nulls (don't give SQL any extra work)



-- Step 1: Open a query window to the tempdb database

USE tempdb;
GO

-- Step 2: Create a schema (introduced sql2005)
	--user of database - the bd owner to own reporting
	-- there is a schema called DBO in every datatabase 
	-- there is a user called DBO inevery database (adminstrative user of the database)

CREATE SCHEMA Reporting AUTHORIZATION dbo;
GO

-- Step 3: Create a schema with an included object 
		-- executed as single statemetn so flights table should be within the operations schema

CREATE SCHEMA Operations AUTHORIZATION dbo
  CREATE TABLE Flights (FlightID int IDENTITY(1,1) PRIMARY KEY,
                        Origin nvarchar(3),
                        Destination nvarchar(3));							
GO

		-- now visible under tables
		-- under security - see Operations and Security Schema


-- Step 4: Use object explorer to work out which schema 
--         the table has been created in

-- Step 5: Drop the table

DROP TABLE Operations.Flights;
GO

-- Step 6: Drop the schema

DROP SCHEMA Operations;
GO

-- Step 7: Use the same syntax but execute each part of the 
--         statement separately

CREATE SCHEMA Operations AUTHORIZATION dbo
CREATE TABLE Flights (FlightID int IDENTITY(1,1) PRIMARY KEY,
                      Origin nvarchar(3),
                      Destination nvarchar(3));

-- Step 8: Again, use object explorer to work out which schema 
--         the table has been created in
	--now flights under dbo schema


-- Step 9: Create the same table in a different schema
CREATE TABLE Reporting.Flights (FlightID int IDENTITY(1,1) PRIMARY KEY,
                      Origin nvarchar(3),
                      Destination nvarchar(3));

					  --Careful whic you slect now eg dbo.flights or flights or reporting.flights
					  --need to be spicific to
