


ALTER TABLE CHKS_INFO ADD CHKS_MULTI_PO smallint not null default 0

ALTER TABLE CHKS_DETL ADD PO_AUTOINC_KEY int not null default 0

ALTER TABLE VOIDCHECK ADD CHKS_AUTOINC_KEY int not null default 0

/*
select * from system_updates
select * from chks_info
select * from chks_detl
select * from voidcheck
*/



select * from system_updates
select * from system_info
select * from current_values

