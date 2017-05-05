---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- Creates a database and defines the physical path of the database file;
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

sp_who2

/*
drop database edsact
drop database edsact001050
drop database edsglobal
*/

USE master
GO
CREATE DATABASE EDSACT
ON 
( NAME = EDSACT,
   FILENAME = 'C:\Program Files\Adpc\Activity Server\EDSACT_Data.mdf',
   SIZE = 10,
   FILEGROWTH = 5 )
LOG ON
( NAME = 'EDSACT_Log',
   FILENAME = 'C:\Program Files\Adpc\Activity Server\EDSACT_log.ldf',
   SIZE = 1MB,
   MAXSIZE = 10MB,
   FILEGROWTH = 1MB )
GO



---------------------------------------------------------------------------------
-- The statement below uses an alternative database name 
---------------------------------------------------------------------------------

USE master
GO
CREATE DATABASE EDSACT001050
ON 
( NAME = EDSACT001050,
   FILENAME = 'C:\Databases\Activity\EDSACT0010500_Data.mdf',
   SIZE = 10,

   FILEGROWTH = 5 )
LOG ON
( NAME = 'EDSACT001050_log',
   FILENAME = 'C:\Databases\Activity\EDSACT0010500_Log.ldf',
   SIZE = 1MB,
   MAXSIZE = 10MB,
   FILEGROWTH = 1MB )
GO

---------------------------------------------------------------------------------
-- The global database script;
---------------------------------------------------------------------------------

USE master
GO
CREATE DATABASE edsglobal
ON 
( NAME = edsglobal,
   FILENAME = 'C:\Program Files\Microsoft Sql Server\MSSQL\Data\edsglobal_data.mdf',
   SIZE = 5,
   FILEGROWTH = 1 )
LOG ON
( NAME = 'edsglobal_log',
   FILENAME = 'C:\Program Files\Microsoft Sql Server\MSSQL\Data\edsglobal_log.ldf',
   SIZE = 1MB,
   MAXSIZE = 1MB,
   FILEGROWTH = 1MB )
GO


 

