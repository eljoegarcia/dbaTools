GO
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.ytd_tchks'),NULL,NULL,'DETAILED');
GO
USE [ADPCt004]
GO
ALTER INDEX [ClusteredIndex-20170508] ON [dbo].[ytd_tchk] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

 ALTER INDEX ALL ON [dbo].[ytd_tchk]  REORGANIZE

ALTER INDEX ALL ON [dbo].[ytd_tchk] REBUILD;
GO
-- Step 4: Insert some data into the table
select * from ytd_tchk

SET NOCOUNT ON;

DECLARE @Counter int = 0;

WHILE @Counter < 10000 BEGIN
  INSERT dbo.[ytd_tchk] (tr_date, tr_num, tr_descrip)
    VALUES(SYSDATETIME(),'9999999',CAST(RAND() * 1000 AS int));
  SET @Counter += 1;
END;
GO
--test on stats
SET NOCOUNT ON;

DECLARE @Counter int = 0;

WHILE @Counter < 10000 BEGIN
  UPDATE dbo.[ytd_tchk] SET tr_descrip = Replicate('9',CAST(RAND() * 10 AS int))
    WHERE id = @Counter % 10000;
  IF @Counter % 100 = 0 PRINT @Counter;
  SET @Counter += 1;
END;
GO

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(),OBJECT_ID('dbo.ytd_tchks'),NULL,NULL,'DETAILED');
GO
USE [ADPCt004]
GO
ALTER INDEX [ClusteredIndex-20170508] ON [dbo].[ytd_tchk] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO