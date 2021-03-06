

alter table acct_info add AF_CURRENT_BALANCE AS ((AF_BEG_MONTH_BALANCE + AF_MTD_RECEIPTS + AF_MTD_ADJUST) - AF_MTD_EXPEND)

alter table acct_sub add AS_CURRENT_BALANCE AS ((AS_BEG_MONTH_BALANCE + AS_MTD_RECEIPTS + AS_MTD_ADJUST) - AS_MTD_EXPEND)

alter table system_backups add SYBK_OFFSITE_LICENSE char(1) not null default 'N'

-- sample column width change
alter table system_info alter column SYSI_PRIMARY_FTP_DOMAIN varchar (1000)



ALTER TABLE PURC_DETL ADD INVOICE_TOTAL decimal(13,2) not null default 0
ALTER TABLE PURC_DETL ADD EXPENSE_TOTAL decimal(13,2) not null default 0

SELECT * FROM PURC_DETL ORDER BY PODT_AUTOINC_KEY DESC

UPDATE PURC_DETL SET INVOICE_TOTAL = 500.00, EXPENSE_TOTAL = 500.00 WHERE PODT_AUTOINC_KEY = 3891
UPDATE PURC_DETL SET INVOICE_TOTAL = 925.00, EXPENSE_TOTAL = 225.00 WHERE PODT_AUTOINC_KEY = 3892
UPDATE PURC_DETL SET INVOICE_TOTAL =  65.00, EXPENSE_TOTAL =   0.00 WHERE PODT_AUTOINC_KEY = 3893


select * from chks_detl
