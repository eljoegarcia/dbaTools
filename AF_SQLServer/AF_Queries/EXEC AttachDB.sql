----------------------------------------------------------------------------------------
sp_attach_db @dbname = 'edsact', 
   @filename1 = 'C:\Program Files\Adpc\Activity Server\edsact_data.mdf', 
   @filename2 = 'C:\Program Files\Adpc\Activity Server\edsact_log.ldf'

sp_detach_db 'edsact'
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
sp_attach_db @dbname = 'edsact', 
   @filename1 = 'C:\Program Files\Microsoft SQL Server\MSSQL\Data\edsact_data.mdf', 
   @filename2 = 'C:\Program Files\Microsoft SQL Server\MSSQL\Data\edsact_log.ldf'

sp_detach_db 'edsact'
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
sp_attach_db @dbname = 'edsact790050', 
   @filename1 = 'C:\Program Files\Adpc\Activity Server\edsact790050_data.mdf', 
   @filename2 = 'C:\Program Files\Adpc\Activity Server\edsact790050_log.ldf'

sp_detach_db 'edsact790050'
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
sp_attach_db @dbname = 'edsglobal', 
   @filename1 = 'C:\Program Files\ADPC\Activity Server\edsglobal_data.mdf', 
   @filename2 = 'C:\Program Files\ADPC\Activity Server\edsglobal_log.ldf'

sp_detach_db 'edsglobal'
----------------------------------------------------------------------------------------
sp_attach_db @dbname = 'ADPCt134', 
   @filename1 = 'C:\eds\treasury\Data\ADPCt134.mdf', 
   @filename2 = 'C:\eds\treasury\Data\ADPCt134.ldf'

sp_detach_db 'ADPCt134'
