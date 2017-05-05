sp_tables

select * from [EAST\dedwards].uassemblies
select * from [EAST\dedwards].upermissions
select * from [EAST\mdenny].SYSTEM_UPDATES
select * from system_updates
select * from user_info


drop table [dbo].system_updates
drop table [EAST\dedwards].upermissions_auxiliary
drop table [EAST\dedwards].upermissions
drop table [EAST\dedwards].uassemblies_auxiliary
drop table [EAST\dedwards].uassemblies
drop table [EAST\mdenny].receipt_batch

sp_changeobjectowner '[EAST\mdenny].INVOICES', 'dbo'
sp_changeobjectowner '[EAST\mdenny].SYSTEM_UPDATES', 'dbo'
sp_changeobjectowner '[EAST\mdenny].UASSEMBLIES', 'dbo'
sp_changeobjectowner '[EAST\mdenny].UASSEMBLIES_AUXILIARY', 'dbo'
sp_changeobjectowner '[EAST\mdenny].UPERMISSIONS', 'dbo'
sp_changeobjectowner '[EAST\mdenny].UPERMISSIONS_AUXILIARY', 'dbo'



