-- sum acct_info
Select sum(af_beg_month_balance) from acct_info---------------     --------->45405.06  ---. = bank beg bal
Where bank_acct_num = '0-036-436'

-- sum the receipts
Select sum(rd.rcdt_amount) 
from receipt_detl as rd, receipt_info as ri
where ri.rcpt_recon_sw = 'N'
and rd.bank_acct_num = ri.bank_acct_num
and rd.rcpt_fisyr = ri.rcpt_fisyr
and rd.rcpt_num = ri.rcpt_num
and ri.bank_acct_num = '0-036-436'
and ri.rcpt_fisyr = 2005
and ri.rcpt_applied_date between '2004-08-01' and '2004-08-31'

-- sum the checks
Select sum(chks_amount) from chks_info
where chks_recon_sw = 'N'
and bank_acct_num = '0-036-436'
and chks_fisyr = 2005

-- sum the transactions
Select sum(tran_amt) from transactions
where bank_acct_num = '0-036-436'
and tran_fisyr = 2005

select * from chks_Info
-- sum the checks
Select sum(chks_amount) from chks_info
where chks_recon_sw = 'N'
and bank_acct_num = '0-036-436'
and chks_fisyr = 2005



select * from voidcheck 
where voidchk_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'
select * from transactions 
where tran_type = 'E'
and tran_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


-- 55052.15		(Acct 5002 = 3517.37)
Select sum(rd.rcdt_amount) 
from receipt_detl as rd, receipt_info as ri
where rd.bank_acct_num = ri.bank_acct_num
and rd.rcpt_fisyr = ri.rcpt_fisyr
and rd.rcpt_num = ri.rcpt_num
and af_acct_num = '5002'
and ri.rcpt_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'



-------------------------------------------------------------------------------------------
-- checks
-------------------------------------------------------------------------------------------

select sum(ckdt_amount) from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key
and ci.bank_acct_num = '0466 426'
and af_acct_num = '0115'
and as_acct_num = '820'
and chks_applied_date between '2009-09-01 00:00:00.000' and '2009-10-01 00:00:00.000'

select * from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and ci.bank_acct_num = '0466 426'
and af_acct_num = '0115'
and as_acct_num = '820'
and chks_applied_date between '2009-09-01 00:00:00.000' and '2009-10-01 00:00:00.000'
 
select sum(ckdt_amount) from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key
and ci.bank_acct_num = '0466 426'
and af_acct_num = '0151'
and as_acct_num = '820'
and chks_applied_date between '2009-10-01 00:00:00.000' and '2009-11-01 00:00:00.000'

select * from chks_info as ci, chks_detl as cd
where ci.chks_autoinc_key = cd.chks_autoinc_key 
and ci.bank_acct_num = '0466 426'
and af_acct_num = '0051'
and as_acct_num = '816'
and chks_applied_date between '2009-10-01 00:00:00.000' and '2009-11-01 00:00:00.000'

select ahst_mtd_expend, * from acct_history where ahst_fisyr = 2010 and ahst_current_month = 9







select * from transfers where trx_fisyr = 2010
-- sum the transactions	
-- 				(B = 0.00), (E = 835.00), (I = 623.57), (N = 0.00), (R = -218.19)
-- acct 5002 = 		0.00 		600.00				 0.00 	 0.00			0.00
-- GRAND TOTAL = 1240.38
select sum(tran_amt) from transactions
where tran_type = 'R' 
and af_acct_num = '5002'
and tran_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


-- (mtdrcpt = 3517.37), (mtdexpend = 4182.71), (mtdadjust = 600.00)
select * from acct_Info where af_acct_num = '5002'	


select * from voidcheck 
where af_acct_num = '5002'
and voidchk_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'


select * from transactions
where tran_type = 'E' 
and af_acct_num = '5002'
and tran_applied_date between '2005-04-01 00:00:00.000' and '2005-05-01 00:00:00.000'