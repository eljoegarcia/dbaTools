select * from bank_info
select * from acct_info

-- sum acct_info
---------------------------------------------------------------
select sum(af_beg_month_balance) from acct_info where bank_acct_num = '0605492'
select sum(af_mtd_expend) from acct_info where bank_acct_num = '0605492'
select sum(as_mtd_expend) from acct_sub where bank_acct_num = '0605492'


-- sum the receipts
---------------------------------------------------------------
Select sum(rd.rcdt_amount) 
from receipt_detl as rd, receipt_info as ri
where rd.bank_acct_num = ri.bank_acct_num
and rd.rcpt_fisyr = ri.rcpt_fisyr
and rd.rcpt_num = ri.rcpt_num
and ri.rcpt_fisyr = 2006
and ri.bank_acct_num = '0605492'

and ri.rcpt_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'

-- sum the check header amounts
---------------------------------------------------------------
Select sum(chks_amount) from chks_info
where chks_recon_sw = 'N'
and chks_fisyr = 2005

-- sum the check detail amounts
---------------------------------------------------------------
Select sum(ckdt_amount) from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and ci.bank_acct_num = '0605492' 
and ci.chks_fisyr = 2006
and ci.chks_applied_date between '2005-10-01 00:00:00.000' and '2005-11-01 00:00:00.000'

Select * from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and ci.bank_acct_num = '0605492' 
and ci.chks_fisyr = 2006
and ci.chks_applied_date between '2005-10-01 00:00:00.000' and '2005-11-01 00:00:00.000'
order by chks_num

select sum(ahst_mtd_expend) from acct_history
where bank_acct_num = '0605492'
and ahst_current_month = 9
and ahst_fisyr = 2006

-- sum checks for all accounts by bank
---------------------------------------------------------------
Select af_acct_num, as_acct_num, sum(ckdt_amount) 
from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and ci.bank_acct_num = '0605492'
group by af_acct_num, as_acct_num
order by af_acct_num, as_acct_num



and ci.chks_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'

-- detail void checks
---------------------------------------------------------------
select * from voidcheck 
where voidchk_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


-- detail adjustments
---------------------------------------------------------------
select * from transactions 
where tran_type = 'E'
and tran_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


-- sum receipts for an account
---------------------------------------------------------------
Select sum(rd.rcdt_amount) 
from receipt_detl as rd, receipt_info as ri
where rd.bank_acct_num = ri.bank_acct_num
and rd.rcpt_fisyr = ri.rcpt_fisyr
and rd.rcpt_num = ri.rcpt_num
and af_acct_num = '0136'
and as_acct_num = '003'
and ri.rcpt_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'

-- sum receipts for all accounts by bank
---------------------------------------------------------------
Select af_acct_num, as_acct_num, sum(rd.rcdt_amount) 
from receipt_detl as rd, receipt_info as ri
where rd.bank_acct_num = ri.bank_acct_num
and rd.rcpt_fisyr = ri.rcpt_fisyr
and rd.rcpt_num = ri.rcpt_num
and ri.bank_acct_num = '0605492'
group by af_acct_num, as_acct_num
order by af_acct_num, as_acct_num


-- sum all the adjustments by a single bank
---------------------------------------------------------------
select distinct
	(select sum(tran_amt) from transactions where tran_type = 'B' and bank_acct_num = '0605492') as Bankcharges,
	(select sum(tran_amt) from transactions where tran_type = 'E' and bank_acct_num = '0605492') as Expenditures,
	(select sum(tran_amt) from transactions where tran_type = 'I' and bank_acct_num = '0605492') as Interest,
	(select sum(tran_amt) from transactions where tran_type = 'N' and bank_acct_num = '0605492') as Nsfcharges,
	(select sum(tran_amt) from transactions where tran_type = 'R' and bank_acct_num = '0605492') as Revenues
from transactions


-- sum all adjustments by date for a single bank
select distinct
	(select sum(tran_amt) from transactions where tran_type = 'B' and bank_acct_num = '0605492' and tran_applied_date between '2004-07-01 00:00:00.000' and '2005-07-01 00:00:00.000') as Bankcharges,
	(select sum(tran_amt) from transactions where tran_type = 'E' and bank_acct_num = '0605492' and tran_applied_date between '2004-07-01 00:00:00.000' and '2005-07-01 00:00:00.000') as Expenditures,
	(select sum(tran_amt) from transactions where tran_type = 'I' and bank_acct_num = '0605492' and tran_applied_date between '2004-07-01 00:00:00.000' and '2005-07-01 00:00:00.000') as Interest,
	(select sum(tran_amt) from transactions where tran_type = 'N' and bank_acct_num = '0605492' and tran_applied_date between '2004-07-01 00:00:00.000' and '2005-07-01 00:00:00.000') as Nsfcharges,
	(select sum(tran_amt) from transactions where tran_type = 'R' and bank_acct_num = '0605492' and tran_applied_date between '2004-07-01 00:00:00.000' and '2005-07-01 00:00:00.000') as Revenues
from transactions

select distinct
	(select sum(tran_amt) from transactions where tran_type = 'B') as Bankcharges,	
	(select sum(tran_amt) from transactions where tran_type = 'E') as Expenditures,	
	(select sum(tran_amt) from transactions where tran_type = 'I') as Interest,		
	(select sum(tran_amt) from transactions where tran_type = 'N') as Nsfcharges,	
	(select sum(tran_amt) from transactions where tran_type = 'R') as Revenues		
from transactions


-- sum all adjustments by all accounts by bank
---------------------------------------------------------------
select af_acct_num, as_acct_num, sum(tran_amt) from transactions 
where tran_type = 'R' and bank_acct_num = '0605492'
group by af_acct_num, as_acct_num
order by af_acct_num, as_acct_num


	(select sum(tran_amt) from transactions where tran_type = 'E' and bank_acct_num = '0605492') as Expenditures,
	(select sum(tran_amt) from transactions where tran_type = 'I' and bank_acct_num = '0605492') as Interest,
	(select sum(tran_amt) from transactions where tran_type = 'N' and bank_acct_num = '0605492') as Nsfcharges,
	(select sum(tran_amt) from transactions where tran_type = 'R' and bank_acct_num = '0605492') as Revenues
from transactions


-- bank balance from account history = bank_beg_balance
select sum(ahst_beg_month_balance + ahst_mtd_receipts - ahst_mtd_expend + ahst_mtd_adjust) 
from acct_history where ahst_current_month = 3

-- net balance from account history = bank_net_balance
select sum(ahst_mtd_receipts - ahst_mtd_expend + ahst_mtd_adjust) 
from acct_history where ahst_current_month = 3


Select sum(ckdt_amount) from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and af_acct_Num = '5002'
and ci.chks_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'

select * from transactions 
where af_acct_num = '5002'
and tran_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


select * from transactions