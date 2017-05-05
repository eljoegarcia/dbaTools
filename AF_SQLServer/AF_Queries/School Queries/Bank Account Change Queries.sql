


select * from bank_info


alter table bank_info drop constraint PK_BANK_INFO_0001 
alter table acct_info drop constraint FK_BANK_ACCT_NUM_0001

select * from acct_info
select * from acct_sub

update acct_info set bank_acct_num = '7403608'

update acct_sub set bank_acct_num = '7403608'




--alter table receipt_detl drop constraint FK_RECEIPT_DETL_0001
--alter table receipt_detl add constraint FK_RECEIPT_DETL_0001 foreign key (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM) references RECEIPT_INFO (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM)update chks_reg set bank_acct_num = '7403608' -- where ckrg_fisyr = 2014



update receipt_info set bank_acct_num = '7403608'
update receipt_detl set bank_acct_num = '7403608'

select * from receipt_info
select * from receipt_detl
select * from chks_info
select * from chks_detl

update chks_info set bank_acct_num = '7403608' 
update chks_detl set bank_acct_num = '7403608' 
update deposit_info set bank_acct_num = '7403608' 
update transactions set bank_acct_num = '7403608'
update transfers set bank_acct_num = '7403608' 
update purc_info set bank_acct_num = '7403608' 
update purc_detl set bank_acct_num = '7403608'
update purc_history set bank_acct_num = '7403608' 
update invoices set bank_acct_num = '7403608' 
update outstandingchecks set bank_acct_num = '7403608' 
update outstandingreceipts set bank_acct_num = '7403608'
update voidcheck set bank_acct_num = '7403608' 
update voidreceipt set bank_acct_num = '7403608' 

------------------------------------------------------------------------------
  /*DO ALL YEAR OR WILL NOT BE TO PRINT SUMMARY FROM PRIOR YR */
select * from acct_history
select * from bank_history
select * from chks_reg
update acct_history set bank_acct_num = '7403608' where ahst_fisyr = 2015 
update bank_history set bank_acct_num = '7403608' where bhst_fisyr = 2015
update chks_reg set bank_acct_num = '7403608' where ckrg_fisyr = 2015
------------------------------------------------------------------------------

select * from bank_info
/*
update bank_info set bank_beg_balance = 68478.26, bank_next_check = '00001001', bank_next_receipt = '00000419' where bank_autoinc_key = 2
update bank_info set bank_beg_balance = 10773.81, bank_next_check = '00000101', bank_next_receipt = '00000073' where bank_autoinc_key = 2
update bank_info set bank_net_balance = -1820.93,bank_id = '001', site_num = '' where bank_autoinc_key = 2
update bank_info set bank_id = '001', site_num = '' where bank_autoinc_key = 2
update bank_info set bank_status = 'D', bank_beg_balance = 0.00 where bank_autoinc_key = 1
update bank_info set bank_net_balance = 0.0 where bank_autoinc_key = 1
*/



select * from chks_info where chks_recon_sw = 'N' and chks_status <> 'V'
select sum(chks_amount) from chks_info where chks_recon_sw = 'N' and chks_status <> 'V'

select * from receipt_info
select * from receipt_detl
select * from transactions 
/*
select * from current_values        ---   no bank information  ----
*/
select * from acct_history
select * from acct_info
select * from acct_sub
select * from chks_reg
select * from chks_audit   ---   BANK_AUTOINC_KEY   --- THERE FOR US
select * from deposit_info
select * from invoices
select * from outstandingchecks
select * from outstandingreceipts
select * from purc_info
select * from purc_detl
select * from purc_history
SELECT * FROM REQ_INFO
SELECT * FROM REQ_detl

sp_tables

select * from chks_info where chks_status = 'C'
select * from receipt_info where rcpt_status = 'C'