
/***********************************************************************************************************
-- THIS SCRIPT FILE CONTAINS ALL THE TABLES AND DEFINITIONS FOR THE ACTIVITY FUND DATABASE; 
-- LAST UPDATED 2016.06.15 BY FRED;
***********************************************************************************************************/

USE EDSACT001050
create table [dbo].BANK_INFO (
BANK_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) constraint PK_BANK_INFO_0001 primary key clustered,	
BANK_STATUS char(1) not null default 'O',
BANK_BEG_BALANCE decimal(13,2) not null default 0,				-- updated at eom	
BANK_NET_BALANCE decimal(13,2) not null default 0,				-- updated by receipts & checks
BANK_CUR_BALANCE as (BANK_BEG_BALANCE + BANK_NET_BALANCE),
BANK_FROZEN_ASSETS decimal(13,2) not null default 0,			-- used for investment/cd's
BANK_NEXT_CHECK char(8) not null,		
BANK_NEXT_RECEIPT char(8) not null,		
BANK_NAME varchar(50) not null default '',	
BANK_ADDR1 varchar(50) not null default '',		
BANK_ADDR2 varchar(25) not null default '',
BANK_ADDR3 varchar(25) not null default '',		
BANK_CITY varchar(25) not null default '',		
BANK_STATE varchar(2) not null default '',		
BANK_ZIP char(5) not null default '',		
BANK_ZIP_EXT char(4) not null default '',		
BANK_PHONE1 varchar(25) not null default '',		
BANK_PHONE1_EXT varchar(10) not null default '',		
BANK_PHONE2 varchar(25) not null default '',		
BANK_PHONE2_EXT varchar(10) not null default '',		
BANK_FAX varchar(25) not null default '',		
BANK_CONTACT1 varchar(50) not null default '',		
BANK_CONTACT2 varchar(50) not null default '',		
BANK_CUSTODIAN1 varchar(50) not null default '',						
BANK_CUSTODIAN2 varchar(50) not null default '',
BANK_ID char(3) not null default '000',
SITE_NUM varchar(5) not null default '',					-- typically the site number for that school; only used for display purposes... eg: 050
SITE_NAME varchar(50) not null default '',					-- info about the site (school location) for this bank account number 
SITE_ADDR1 varchar(50) not null default '',		
SITE_ADDR2 varchar(25) not null default '',
SITE_CITY varchar(25) not null default '',		
SITE_STATE varchar(2) not null default '',
SITE_ZIP char(5) not null default '',		
SITE_ZIP_EXT char(4) not null default '',
SITE_PHONE varchar(25) not null default '',		
SITE_PHONE_EXT varchar(10) not null default '',
SITE_FAX varchar(25) not null default '',
BANK_TRANSDATE datetime not null default getdate(),
BANK_DATETIME datetime not null default getdate(),
constraint CK_BANK_INFO_CHECK_0001 check (BANK_NEXT_CHECK LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
constraint CK_BANK_INFO_RECEIPT_0001 check (BANK_NEXT_RECEIPT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))


create table [dbo].BANK_HISTORY (
BHST_AUTOINC_KEY int identity (1,1),
BHST_FISYR int not null,							-- current fiscal year
BHST_CURRENT_MONTH int not null,						-- current fiscal month
BANK_ACCT_NUM varchar(30) not null,
BHST_BEG_BALANCE decimal(13,2) not null,					-- updated at eom	
BHST_NET_BALANCE decimal(13,2) not null,					-- updated by receipts & checks
BHST_CUR_BALANCE as (BHST_BEG_BALANCE + BHST_NET_BALANCE),
BHST_FROZEN_ASSETS decimal(13,2) not null,					-- used for investment/cd's
BHST_LAST_CHECK char(8) not null,						-- last check # for this month
BHST_LAST_RECEIPT char(8) not null,						-- last receipt # for this month
BHST_CLOSEOUTDATE datetime not null,						-- closeout date
USER_AUTOINC_KEY int not null, 							-- user key
BHST_TRANSDATE datetime not null default getdate(),
BHST_DATETIME datetime not null default getdate(),
constraint UNIQ_BANK_HISTORY_0001 unique clustered (BHST_FISYR, BHST_CURRENT_MONTH, BANK_ACCT_NUM))


create table [dbo].ACCT_INFO (
AF_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30),	
AF_ACCT_NUM varchar(8),	
AF_ACCT_NAME varchar(30) not null,
AF_STATUS char(1) not null default 'O',
AF_BEG_YEAR_BALANCE decimal (13,2) not null default 0,				--balance forward for beg of fisyr; doesn't chg until eoy
AF_BEG_MONTH_BALANCE decimal (13,2) not null default 0,				--beginning month balance (calced by rcpt + checks +- adj)
AF_MTD_RECEIPTS decimal (13,2) not null default 0,		
AF_MTD_ENCUMBERED decimal (13,2) not null default 0,
AF_MTD_EXPEND decimal (13,2) not null default 0,
AF_MTD_ADJUST decimal (13,2) not null default 0,		
AF_YTD_RECEIPTS decimal (13,2) not null default 0,		
AF_YTD_ENCUMBERED decimal (13,2) not null default 0,		
AF_YTD_EXPEND decimal (13,2) not null default 0,		
AF_YTD_ADJUST decimal (13,2) not null default 0,	
AF_TRANSDATE datetime not null default getdate(),		
AF_DATETIME datetime not null default getdate(),
AF_MTD_INVOICES decimal (13,2) not null default 0,	
AF_YTD_INVOICES decimal (13,2) not null default 0,	
AF_YTD_REQUISITION decimal (13,2) not null default 0,	
constraint CK_ACCT_INFO_0001 check (AF_ACCT_NUM LIKE '[0-9][0-9][0-9][0-9]'),
constraint PK_ACCT_INFO_0001 primary key clustered (BANK_ACCT_NUM, AF_ACCT_NUM),
constraint FK_BANK_ACCT_NUM_0001 foreign key (BANK_ACCT_NUM) references BANK_INFO (BANK_ACCT_NUM))


create table [dbo].ACCT_SUB (
AS_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30),
AF_ACCT_NUM varchar(8),
AS_ACCT_NUM varchar(4), 
AS_ACCT_NAME varchar(30) not null, 
AS_STATUS char(1) not null default 'O',
AS_BEG_YEAR_BALANCE decimal (13,2) not null default 0,				--balance forward for beg of fisyr; doesn't chg until eoy
AS_BEG_MONTH_BALANCE decimal (13,2) not null default 0,				--beginning month balance (calced by rcpt + checks +- adj)
AS_MTD_RECEIPTS decimal (13,2) not null default 0,				--stored by receipts during the month & zeroed at eom
AS_MTD_ENCUMBERED decimal (13,2) not null default 0,				--stored by po's during the month & zeroed at eom
AS_MTD_EXPEND decimal (13,2) not null default 0,				--stored by checks during the month & zeroed at eom
AS_MTD_ADJUST decimal (13,2) not null default 0,				--stored by adj during the month & zeroed at eom
AS_YTD_RECEIPTS decimal (13,2) not null default 0,				--added from mtd rcpts at eom		
AS_YTD_ENCUMBERED decimal (13,2) not null default 0,				--added from mtd po's at eom
AS_YTD_EXPEND decimal (13,2) not null default 0,				--added from mtd checks at eom
AS_YTD_ADJUST decimal (13,2) not null default 0,				--added from mtd adj at eom
AS_TRANSDATE datetime not null default getdate(),		
AS_DATETIME datetime not null default getdate(),
AS_MTD_INVOICES decimal (13,2) not null default 0,	
AS_YTD_INVOICES decimal (13,2) not null default 0,	
AS_YTD_REQUISITION decimal (13,2) not null default 0,
constraint PK_ACCT_SUB_0001 primary key clustered (BANK_ACCT_NUM, AF_ACCT_NUM, AS_ACCT_NUM),
constraint CK_ACCT_SUB_0001 check (AS_ACCT_NUM LIKE '[0-9][0-9][0-9]'))


create table [dbo].ACCT_HISTORY (
AHST_AUTOINC_KEY int identity (1, 1),
AHST_FISYR int not null,							-- current fiscal year
AHST_CURRENT_MONTH int not null,						-- current fiscal month
BANK_ACCT_NUM varchar(30) not null,
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
AHST_BEG_YEAR_BALANCE decimal (13,2) not null,					-- balance forward for beg of fisyr; doesn't chg until eoy
AHST_BEG_MONTH_BALANCE decimal (13,2) not null,					-- beginning month balance (calced by rcpt + checks +- adj)
AHST_MTD_RECEIPTS decimal (13,2) not null,					-- stored by receipts during the month & zeroed at eom
AHST_MTD_ENCUMBERED decimal (13,2) not null,					-- stored by po's during the month & zeroed at eom
AHST_MTD_EXPEND decimal (13,2) not null,					-- stored by checks during the month & zeroed at eom
AHST_MTD_ADJUST decimal (13,2) not null,					-- stored by adj during the month & zeroed at eom
AHST_YTD_RECEIPTS decimal (13,2) not null,					-- added from mtd rcpts at eom		
AHST_YTD_ENCUMBERED decimal (13,2) not null,					-- added from mtd po's at eom
AHST_YTD_EXPEND decimal (13,2) not null,					-- added from mtd checks at eom
AHST_YTD_ADJUST decimal (13,2) not null,					-- added from mtd adj at eom
AHST_CLOSEOUTDATE datetime not null,						-- closeout date for the month
AF_ACCT_NAME varchar(30) not null,
AS_ACCT_NAME varchar(30) not null, 
AHST_TRANSDATE datetime not null default getdate(),		
AHST_DATETIME datetime not null default getdate(),
AHST_MTD_INVOICES decimal (13,2) not null,					
AHST_YTD_INVOICES decimal (13,2) not null,				
AHST_YTD_REQUISITION decimal (13,2) not null,				
constraint UNIQ_ACCT_HISTORY_0001 unique clustered (AHST_FISYR, AHST_CURRENT_MONTH, BANK_ACCT_NUM, AF_ACCT_NUM, AS_ACCT_NUM))


-- contains a record for each account changed to another account (added 2015.04.10);
CREATE TABLE [dbo].ACCT_AUDIT (
ACCT_AUTOINC_KEY int identity (1,1) primary key,
BANK_ACCT_NUM varchar(30) not null,
ACCT_FISYR int not null,
ACCT_PRIORACCT varchar(8) not null,
ACCT_PRIORSUBACCT varchar(4) not null,
ACCT_NEWACCT varchar(8) not null,
ACCT_NEWSUBACCT varchar(4) not null,
REQS_COUNT int not null,
PURC_COUNT int not null,
INVC_COUNT int not null,
CHKS_COUNT int not null,
TRXFR_COUNT int not null,
TRXTO_COUNT int not null,
TRANS_COUNT int not null,
RCPT_COUNT int not null,
ACCTHIST_COUNT int not null,
VOIDCHKS_COUNT int not null,
VOIDRCPT_COUNT int not null,
USER_AUTOINC_KEY int not null,
ACCT_DATETIME datetime not null default getdate())


-- this table holds the current fiscal year, ponumber, & deposit number
create table [dbo].CURRENT_VALUES (
CVAL_AUTOINC_KEY int identity (1, 1),
CVAL_FISYR int not null ,
CVAL_PO_NUM char(8) not null,
CVAL_DEPOSIT_NUM char(5) not null, 
CVAL_CURDATE datetime not null,							
CVAL_TRANSDATE datetime not null default getdate(),
CVAL_DATETIME datetime not null default getdate(),
constraint UNIQ_CURRENT_VALUES_0001 unique (CVAL_FISYR),
constraint CK_CURRENT_VALUES_FISYR_0001 check (CVAL_FISYR LIKE '[1-2][0-9][0-9][0-9]'),
constraint CK_CURRENT_VALUES_0001 check (CVAL_PO_NUM LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
constraint CK_CURRENT_VALUES_0002 check (CVAL_DEPOSIT_NUM LIKE '[0-9][0-9][0-9][0-9][0-9]'))



/***************************************************************************/
/************************ OCAS REVENUE DIMENSIONS **************************/
/***************************************************************************/
create table [dbo].DIMR1 (
DIMR1_AUTOINC_KEY int identity (1, 1),
DIMR1_FISYR integer not null,	
DIMR1_VALUE char(1) constraint UNIQ_DIMR1_0001 unique clustered (DIMR1_FISYR, DIMR1_VALUE),		
DIMR1_TYPE char(1) not null,
DIMR1_VALID char(1) not null default 'Y',
DIMR1_ROLLVALUE char(1) default '',		
DIMR1_DESCR varchar(50) not null default '',		
DIMR1_TRANSDATE datetime not null default getdate(),	
DIMR1_DATETIME datetime not null default getdate(),
constraint CK_DIMR1_VALUE_0001 check (DIMR1_VALUE LIKE '[0-9]'),
constraint CK_DIMR1_TYPE_0001 check (DIMR1_TYPE LIKE '[A-Z]'),
constraint CK_DIMR1_FISYR_0001 check (DIMR1_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMR2 (
DIMR2_AUTOINC_KEY int identity (1, 1),
DIMR2_FISYR integer not null,	
DIMR2_VALUE char(2) constraint UNIQ_DIMR2_0001 unique clustered (DIMR2_FISYR, DIMR2_VALUE),		
DIMR2_TYPE char(1) not null,
DIMR2_VALID char(1) not null default 'Y',
DIMR2_ROLLVALUE char(2) default '',		
DIMR2_DESCR varchar (50) not null default '',		
DIMR2_TRANSDATE datetime not null default getdate(),	
DIMR2_DATETIME datetime not null default getdate(),
constraint CK_DIMR2_VALUE_0001 check (DIMR2_VALUE LIKE '[0-9][0-9]'),
constraint CK_DIMR2_TYPE_0001 check (DIMR2_TYPE LIKE '[A-Z]'),
constraint CK_DIMR2_FISYR_0001 check (DIMR2_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMR3 (
DIMR3_AUTOINC_KEY int identity (1, 1),
DIMR3_FISYR integer not null,	
DIMR3_VALUE char(3) constraint UNIQ_DIMR3_0001 unique clustered (DIMR3_FISYR, DIMR3_VALUE),		
DIMR3_TYPE char(1) not null,
DIMR3_VALID char(1) not null default 'Y',
DIMR3_ROLLVALUE char(3) default '',		
DIMR3_DESCR varchar (50) not null default '',		
DIMR3_TRANSDATE datetime not null default getdate(),	
DIMR3_DATETIME datetime not null default getdate(),	
constraint CK_DIMR3_VALUE_0001 check (DIMR3_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMR3_TYPE_0001 check (DIMR3_TYPE LIKE '[A-Z]'),
constraint CK_DIMR3_FISYR_0001 check (DIMR3_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMR4 (
DIMR4_AUTOINC_KEY int identity (1, 1),
DIMR4_FISYR integer not null,	
DIMR4_VALUE char(4) constraint UNIQ_DIMR4_0001 unique clustered (DIMR4_FISYR, DIMR4_VALUE),		
DIMR4_TYPE char(1) not null,
DIMR4_VALID char(1) not null default 'Y',
DIMR4_ROLLVALUE char(4) default '',		
DIMR4_DESCR varchar (50) not null default '',		
DIMR4_TRANSDATE datetime not null default getdate(),	
DIMR4_DATETIME datetime not null default getdate(),	
constraint CK_DIMR4_VALUE_0001 check (DIMR4_VALUE LIKE '[0-9][0-9][0-9][0-9]'),
constraint CK_DIMR4_TYPE_0001 check (DIMR4_TYPE LIKE '[A-Z]'),
constraint CK_DIMR4_FISYR_0001 check (DIMR4_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMR5 (
DIMR5_AUTOINC_KEY int identity (1, 1),
DIMR5_FISYR integer not null,	
DIMR5_VALUE char(3) constraint UNIQ_DIMR5_0001 unique clustered (DIMR5_FISYR, DIMR5_VALUE),		
DIMR5_TYPE char(1) not null,
DIMR5_VALID char(1) not null default 'Y',
DIMR5_ROLLVALUE char(3) default '',		
DIMR5_DESCR varchar (50) not null default '',		
DIMR5_TRANSDATE datetime not null default getdate(),	
DIMR5_DATETIME datetime not null default getdate(),
constraint CK_DIMR5_VALUE_0001 check (DIMR5_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMR5_TYPE_0001 check (DIMR5_TYPE LIKE '[A-Z]'),
constraint CK_DIMR5_FISYR_0001 check (DIMR5_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].DIMR6 (
DIMR6_AUTOINC_KEY int identity (1, 1),
DIMR6_FISYR integer not null,	
DIMR6_VALUE char(3) constraint UNIQ_DIMR6_0001 unique clustered (DIMR6_FISYR, DIMR6_VALUE),		
DIMR6_TYPE char(1) not null,
DIMR6_VALID char(1) not null default 'Y',
DIMR6_ROLLVALUE char(3) default '',		
DIMR6_DESCR varchar (50) not null default '',		
DIMR6_TRANSDATE datetime not null default getdate(),	
DIMR6_DATETIME datetime not null default getdate(),
constraint CK_DIMR6_VALUE_0001 check (DIMR6_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMR6_TYPE_0001 check (DIMR6_TYPE LIKE '[A-Z]'),
constraint CK_DIMR6_FISYR_0001 check (DIMR6_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


/***************************************************************************/
/********************** OCAS EXPENDITURE DIMENSIONS ************************/
/***************************************************************************/
create table [dbo].DIMX1 (
DIMX1_AUTOINC_KEY int identity (1, 1),
DIMX1_FISYR integer not null,	
DIMX1_VALUE char (1) constraint UNIQ_DIMX1_0001 unique clustered (DIMX1_FISYR, DIMX1_VALUE),		
DIMX1_TYPE char (1) not null,
DIMX1_VALID char (1) not null default 'Y',
DIMX1_ROLLVALUE char(1) default '',		
DIMX1_DESCR varchar (50) not null default '',		
DIMX1_TRANSDATE datetime not null default getdate(),	
DIMX1_DATETIME datetime not null default getdate(),
constraint CK_DIMX1_VALUE_0001 check (DIMX1_VALUE LIKE '[0-9]'),
constraint CK_DIMX1_TYPE_0001 check (DIMX1_TYPE LIKE '[A-Z]'),
constraint CK_DIMX1_FISYR_0001 check (DIMX1_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMX2 (
DIMX2_AUTOINC_KEY int identity (1, 1),
DIMX2_FISYR integer not null,	
DIMX2_VALUE char(2) constraint UNIQ_DIMX2_0001 unique clustered (DIMX2_FISYR, DIMX2_VALUE),		
DIMX2_TYPE char(1) not null,
DIMX2_VALID char(1) not null default 'Y',
DIMX2_ROLLVALUE char(2) default '',		
DIMX2_DESCR varchar (50) not null default '',		
DIMX2_TRANSDATE datetime not null default getdate(),	
DIMX2_DATETIME datetime not null default getdate(),
constraint CK_DIMX2_VALUE_0001 check (DIMX2_VALUE LIKE '[0-9][0-9]'),
constraint CK_DIMX2_TYPE_0001 check (DIMX2_TYPE LIKE '[A-Z]'),
constraint CK_DIMX2_FISYR_0001 check (DIMX2_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMX3 (
DIMX3_AUTOINC_KEY int identity (1, 1),
DIMX3_FISYR integer not null,	
DIMX3_VALUE char(3) constraint UNIQ_DIMX3_0001 unique clustered (DIMX3_FISYR, DIMX3_VALUE),		
DIMX3_TYPE char(1) not null,
DIMX3_VALID char(1) not null default 'Y',
DIMX3_ROLLVALUE char(3) default '',		
DIMX3_DESCR varchar (50) not null default '',		
DIMX3_TRANSDATE datetime not null default getdate(),	
DIMX3_DATETIME datetime not null default getdate(),	
constraint CK_DIMX3_VALUE_0001 check (DIMX3_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMX3_TYPE_0001 check (DIMX3_TYPE LIKE '[A-Z]'),
constraint CK_DIMX3_FISYR_0001 check (DIMX3_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMX4 (
DIMX4_AUTOINC_KEY int identity (1, 1),
DIMX4_FISYR integer not null,	
DIMX4_VALUE char(4) constraint UNIQ_DIMX4_0001 unique clustered (DIMX4_FISYR, DIMX4_VALUE),		
DIMX4_TYPE char(1) not null,
DIMX4_VALID char(1) not null default 'Y',
DIMX4_ROLLVALUE char(4) default '',		
DIMX4_DESCR varchar (50) not null default '',		
DIMX4_TRANSDATE datetime not null default getdate(),	
DIMX4_DATETIME datetime not null default getdate(),	
constraint CK_DIMX4_VALUE_0001 check (DIMX4_VALUE LIKE '[0-9][0-9][0-9][0-9]'),
constraint CK_DIMX4_TYPE_0001 check (DIMX4_TYPE LIKE '[A-Z]'),
constraint CK_DIMX4_FISYR_0001 check (DIMX4_FISYR LIKE '[1-2][0-9][0-9][0-9]'))


create table [dbo].DIMX5 (
DIMX5_AUTOINC_KEY int identity (1, 1),
DIMX5_FISYR integer not null,	
DIMX5_VALUE char(3) constraint UNIQ_DIMX5_0001 unique clustered (DIMX5_FISYR, DIMX5_VALUE),		
DIMX5_TYPE char(1) not null,
DIMX5_VALID char(1) not null default 'Y',
DIMX5_ROLLVALUE char(3) default '',		
DIMX5_DESCR varchar (50) not null default '',		
DIMX5_TRANSDATE datetime not null default getdate(),	
DIMX5_DATETIME datetime not null default getdate(),
constraint CK_DIMX5_VALUE_0001 check (DIMX5_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMX5_TYPE_0001 check (DIMX5_TYPE LIKE '[A-Z]'),
constraint CK_DIMX5_FISYR_0001 check (DIMX5_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].DIMX6 (
DIMX6_AUTOINC_KEY int identity (1, 1),
DIMX6_FISYR integer not null,	
DIMX6_VALUE char(3) constraint UNIQ_DIMX6_0001 unique clustered (DIMX6_FISYR, DIMX6_VALUE),		
DIMX6_TYPE char(1) not null,
DIMX6_VALID char(1) not null default 'Y',
DIMX6_ROLLVALUE char(3) default '',		
DIMX6_DESCR varchar (50) not null default '',		
DIMX6_TRANSDATE datetime not null default getdate(),	
DIMX6_DATETIME datetime not null default getdate(),
constraint CK_DIMX6_VALUE_0001 check (DIMX6_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMX6_TYPE_0001 check (DIMX6_TYPE LIKE '[A-Z]'),
constraint CK_DIMX6_FISYR_0001 check (DIMX6_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].DIMX7 (
DIMX7_AUTOINC_KEY int identity (1, 1),
DIMX7_FISYR integer not null,	
DIMX7_VALUE char(4) constraint UNIQ_DIMX7_0001 unique clustered (DIMX7_FISYR, DIMX7_VALUE),		
DIMX7_TYPE char(1) not null,
DIMX7_VALID char(1) not null default 'Y',
DIMX7_ROLLVALUE char(4) default '',		
DIMX7_DESCR varchar (50) not null default '',		
DIMX7_TRANSDATE datetime not null default getdate(),	
DIMX7_DATETIME datetime not null default getdate(),
constraint CK_DIMX7_VALUE_0001 check (DIMX7_VALUE LIKE '[0-9][0-9][0-9][0-9]'),
constraint CK_DIMX7_TYPE_0001 check (DIMX7_TYPE LIKE '[A-Z]'),
constraint CK_DIMX7_FISYR_0001 check (DIMX7_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].DIMX8 (
DIMX8_AUTOINC_KEY int identity (1, 1),
DIMX8_FISYR integer not null,	
DIMX8_VALUE char(3) constraint UNIQ_DIM8_0001 unique clustered (DIMX8_FISYR, DIMX8_VALUE),		
DIMX8_TYPE char(1) not null,
DIMX8_VALID char(1) not null default 'Y',
DIMX8_ROLLVALUE char(3) default '',		
DIMX8_DESCR varchar (50) not null default '',		
DIMX8_TRANSDATE datetime not null default getdate(),	
DIMX8_DATETIME datetime not null default getdate(),
constraint CK_DIMX8_VALUE_0001 check (DIMX8_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMX8_TYPE_0001 check (DIMX8_TYPE LIKE '[A-Z]'),
constraint CK_DIMX8_FISYR_0001 check (DIMX8_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].DIMX9 (
DIMX9_AUTOINC_KEY int identity (1, 1),
DIMX9_FISYR integer not null,	
DIMX9_VALUE char(3) constraint UNIQ_DIMX9_0001 unique clustered (DIMX9_FISYR, DIMX9_VALUE),		
DIMX9_TYPE char(1) not null,
DIMX9_VALID char(1) not null default 'Y',
DIMX9_ROLLVALUE char(3) default '',		
DIMX9_DESCR varchar (50) not null default '',		
DIMX9_TRANSDATE datetime not null default getdate(),	
DIMX9_DATETIME datetime not null default getdate(),
constraint CK_DIMX9_VALUE_0001 check (DIMX9_VALUE LIKE '[0-9][0-9][0-9]'),
constraint CK_DIMX9_TYPE_0001 check (DIMX9_TYPE LIKE '[A-Z]'),
constraint CK_DIMX9_FISYR_0001 check (DIMX9_FISYR LIKE '[1-2][0-9][0-9][0-9]'))	


create table [dbo].OCAS_EXP (
OCEX_AUTOINC_KEY int identity (1, 1),
OCEX_CODE char(26)  constraint PK_OCAS_EXP_0001 primary key clustered,
OCEX_STATUS char (1) not null default 'O',					-- (O)-open; (D)-deleted; (I)-invalid;
OCEX_FISYR integer not null,		
OCEX_DIM1 char (1) not null,		
OCEX_DIM2 char (2) not null,		
OCEX_DIM3 char (3) not null,		
OCEX_DIM4 char (4) not null,		
OCEX_DIM5 char (3) not null,		
OCEX_DIM6 char (3) not null,		
OCEX_DIM7 char (4) not null,		
OCEX_DIM8 char (3) not null,		
OCEX_DIM9 char (3) not null,		
OCEX_DESCR varchar (50) not null default '',		
OCEX_CODE_FORMAT as OCEX_DIM1 + '-' + OCEX_DIM2 + '-' + OCEX_DIM3 + '-' + OCEX_DIM4 + '-' + OCEX_DIM5 + '-' + OCEX_DIM6 + '-' + OCEX_DIM7 + '-' + OCEX_DIM8 + '-' + OCEX_DIM9,
OCEX_TRANSDATE datetime not null default getdate(),
OCEX_DATETIME datetime not null default getdate(),
constraint UNIQ_OCAS_EXP_CODE_0002 unique (OCEX_DIM1, OCEX_DIM2, OCEX_DIM3, OCEX_DIM4, OCEX_DIM5, OCEX_DIM6, OCEX_DIM7, OCEX_DIM8, OCEX_DIM9),
constraint CK_OCAS_EXP_FISYR_0001 check (OCEX_FISYR between 1900 and 2099),
constraint CK_OCAS_EXP_DIM2_0001 check (len(OCEX_DIM2) = 2),
constraint CK_OCAS_EXP_DIM3_0001 check (len(OCEX_DIM3) = 3),
constraint CK_OCAS_EXP_DIM4_0001 check (len(OCEX_DIM4) = 4),
constraint CK_OCAS_EXP_DIM5_0001 check (len(OCEX_DIM5) = 3),
constraint CK_OCAS_EXP_DIM6_0001 check (len(OCEX_DIM6) = 3),
constraint CK_OCAS_EXP_DIM7_0001 check (len(OCEX_DIM7) = 4),
constraint CK_OCAS_EXP_DIM8_0001 check (len(OCEX_DIM8) = 3),
constraint CK_OCAS_EXP_DIM9_0001 check (len(OCEX_DIM9) = 3))


create table [dbo].OCAS_REV (
OCRV_AUTOINC_KEY int identity (1, 1),
OCRV_CODE char(16)  constraint PK_OCAS_REV_0001 primary key clustered,
OCRV_STATUS char (1) not null default 'O',					-- (O)-open; (D)-deleted; (I)-invalid;
OCRV_FISYR integer not null,		
OCRV_DIM1 char (1) not null,		
OCRV_DIM2 char (2) not null,		
OCRV_DIM3 char (3) not null,		
OCRV_DIM4 char (4) not null,		
OCRV_DIM5 char (3) not null,		
OCRV_DIM6 char (3) not null,		
OCRV_DESCR varchar (50) not null default '',		
OCRV_CODE_FORMAT as OCRV_DIM1 + '-' + OCRV_DIM2 + '-' + OCRV_DIM3 + '-' + OCRV_DIM4 + '-' + OCRV_DIM5 + '-' + OCRV_DIM6,
OCRV_TRANSDATE datetime not null default getdate(),
OCRV_DATETIME datetime not null default getdate(),
constraint UNIQ_OCAS_REV_CODE_0002 unique (OCRV_DIM1, OCRV_DIM2, OCRV_DIM3, OCRV_DIM4, OCRV_DIM5, OCRV_DIM6),
constraint CK_OCAS_REV_FISYR_0001 check (OCRV_FISYR between 1900 and 2099),
constraint CK_OCAS_REV_DIM2_0001 check (len(OCRV_DIM2) = 2),
constraint CK_OCAS_REV_DIM3_0001 check (len(OCRV_DIM3) = 3),
constraint CK_OCAS_REV_DIM4_0001 check (len(OCRV_DIM4) = 4),
constraint CK_OCAS_REV_DIM5_0001 check (len(OCRV_DIM5) = 3),
constraint CK_OCAS_REV_DIM6_0001 check (len(OCRV_DIM6) = 3))



create table [dbo].OUTSTANDINGCHECKS (
OUTC_AUTOINC_KEY int identity (1, 1) primary key,
BANK_ACCT_NUM varchar(30) not null,	
OUTC_CHK_FISYR int not null,	
AF_ACCT_NUM varchar(8) not null default '',
AS_ACCT_NUM varchar(4) not null default '',	
OUTC_CHK_NUM varchar(10) not null,	
OUTC_CHK_AMOUNT decimal (13,2) not null,	
OUTC_CHK_LINE_AMOUNT decimal (13,2) not null default '0',	
OUTC_RECON_SW char (1) not null default 'N',					-- (N)-not reconciled; (Y)-reconciled before closeout; (F)-reconciled (finalized) after closeout
OUTC_STALE_SW char (1) not null default 'N',
OUTC_CHK_PAYEE_NAME varchar (50) not null default '',		
OUTC_CHK_DESCR varchar(125) not null default '',	 
OUTC_CHK_VEND_NUMBER char(5) not null default '00000', 		
OUTC_OCEX_CODE char (34) not null default '',	
OUTC_CHK_ISSUE_DATE datetime not null default getdate(),
OUTC_TRANSDATE datetime not null default getdate(),
OUTC_DATETIME datetime not null default getdate())


create table [dbo].OUTSTANDINGRECEIPTS (
OUTR_AUTOINC_KEY int identity (1, 1) primary key,
BANK_ACCT_NUM varchar(30) not null,	
OUTR_RCPT_FISYR int not null,	
AF_ACCT_NUM varchar(8) not null default '',
AS_ACCT_NUM varchar(4) not null default '',	
OUTR_RCPT_NUM varchar(8) not null,	
OUTR_RCPT_AMOUNT decimal (13,2) not null,	
OUTR_RCPT_LINE_AMOUNT decimal (13,2) not null default '0',	
OUTR_RECON_SW char (1) not null default 'N',					-- (N)-not reconciled; (Y)-reconciled before closeout; (F)-reconciled (finalized) after closeout
OUTR_STALE_SW char (1) not null default 'N',			
OUTR_RCPT_RCVD_FROM varchar (50) not null default '',		
OUTR_RCPT_DESCR varchar(125) not null default '',
OUTR_RCPT_VEND_NUMBER char(5) not null default '00000', 
OUTR_OCRV_CODE char (21) not null default '',	
OUTR_RCPT_ISSUE_DATE datetime not null default getdate(),
OUTR_TRANSDATE datetime not null default getdate(),
OUTR_DATETIME datetime not null default getdate())



create table [dbo].VEND_INFO (
VEND_AUTOINC_KEY int identity (1, 1),
VEND_NUMBER char(5) constraint PK_VEND_INFO_0001 primary key clustered,	 
VEND_NAME varchar (50) not null,	
VEND_1099_SW char (1) not null default 'N',	
VEND_STATUS char (1) not null default 'O',					-- O - open; I - inactive; D - deleted;	
VEND_ADDR1 varchar (40) not null default '',		
VEND_ADDR2 varchar (40) not null default '',
VEND_ADDR3 varchar (40) not null default '',		
VEND_CITY varchar (25) not null default '',		
VEND_STATE char (2) not null default '',		
VEND_ZIP char (5) not null default '',		
VEND_ZIP_EXT char (4) not null default '',		
VEND_PHONE1 varchar (25) not null default '',		
VEND_PHONE1_EXT varchar (10) not null default '',		
VEND_PHONE2 varchar (25) not null default '',		
VEND_PHONE2_EXT varchar (10) not null default '',		
VEND_FAX varchar (25) not null default '',		
VEND_EMAIL_ADDR varchar (50) not null default '',		
VEND_SSN char (9) not null default '',	
VEND_SSN_FORMAT as substring(vend_ssn, 1, 3) + '-' + substring(vend_ssn, 4, 2) + '-' + substring(vend_ssn, 6, 4),
VEND_REMIT_NAME varchar (50) not null default '',		
VEND_REMIT_ADDR1 varchar (40) not null default '',		
VEND_REMIT_ADDR2 varchar (40) not null default '',		
VEND_REMIT_ADDR3 varchar (40) not null default '',		
VEND_REMIT_CITY varchar (25) not null default '',		
VEND_REMIT_STATE char (2) not null default '',		
VEND_REMIT_ZIP char (5) not null default '',		
VEND_REMIT_ZIP_EXT char (4) not null default '',		
VEND_REMIT_PHONE1 varchar (25) not null default '',		
VEND_REMIT_PHONE1_EXT varchar (10) not null default '',		
VEND_REMIT_PHONE2 varchar (25) not null default '',		
VEND_REMIT_PHONE2_EXT varchar (10) not null default '',		
VEND_REMIT_FAX varchar (25) not null default '',		
VEND_REMIT_EMAIL_ADDR varchar (50) not null default '',		
VEND_TRANSDATE datetime not null default getdate(),
VEND_DATETIME datetime not null default getdate(),
VEND_1098T_SW char (1) not null default 'N',
VEND_W9_SW smallint not null default 0,
constraint CK_VEND_INFO_VEND_NUMBER_0001 check (VEND_NUMBER LIKE '[0-9][0-9][0-9][0-9][0-9]'),
constraint CK_VEND_INFO_STATE_0002 check (VEND_STATE LIKE '[A-Z][A-Z]' or VEND_REMIT_STATE = ''),
constraint CK_VEND_INFO_STATE_0003 check (VEND_REMIT_STATE LIKE '[A-Z][A-Z]' or VEND_REMIT_STATE = ''),
constraint CK_VEND_INFO_ZIP_0004 check (VEND_ZIP LIKE '[0-9][0-9][0-9][0-9][0-9]' or vend_zip = ''),
constraint CK_VEND_INFO_ZIP_0005 check (VEND_REMIT_ZIP LIKE '[0-9][0-9][0-9][0-9][0-9]' or vend_remit_zip = ''),
constraint CK_VEND_INFO_STATUS_0006 check (VEND_STATUS LIKE '[A-Z]'))


create table [dbo].VEND_AUDIT (
VAUD_AUTOINC_KEY int identity (1, 1),
VEND_NUMBER char(5) not null,	 
VEND_NAME varchar (50) not null,	
USER_AUTOINC_KEY int not null default 0,					-- user key;
VAUD_TRANSDATE datetime not null default getdate(),
VAUD_DATETIME datetime not null default getdate(),
VEND_AUTOINC_KEY int not null default 0)


create table [dbo].PURC_INFO (
PO_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,
PO_FISYR integer not null,	
PO_NUM char (8) not null,						 
PO_STATUS char (1) not null default 'O',					-- (O)-open; (C)-closed [existing check]; (D)-deleted; (X)-closed due to yearend closeout;
PO_DESCR varchar(125) not null default '',		
VEND_NUMBER char(5) not null,		
PO_POSTED_SW char (1) not null default 'Y',					-- for future use... posted switch (indicates whether amt has been added to mtd encumbrances...)
PO_APPLIED_DATE datetime not null default getdate(),
RQST_AUTOINC_KEY int not null default 0,					-- fk to the requisition table (no constraint);
SIGN_AUTOINC_KEY int not null default 0,					-- fk to the signature table (no constraint);
PO_TRANSDATE datetime not null default getdate(),		
PO_DATETIME datetime not null default getdate(),
PO_TYPE char(1) not null default 'R',						-- (R)-regular; (B)-blanket;
SHIP_AUTOINC_KEY int not null default 0,					-- fk to the shipping table (no constraint);
SHIP_ATTN varchar(50) not null default '',					-- ATTN TO: for the shipping record;
SHIP_VENDOR_ATTN varchar(50) not null default '',				-- ATTN TO: for the vendor;
constraint PK_PURC_INFO_0001 primary key clustered (PO_FISYR, PO_NUM),
constraint CK_PURC_INFO_0001 check (PO_FISYR between 1900 and 2099),
constraint CK_PURC_INFO_0002 check (PO_NUM LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
constraint CK_PURC_INFO_0003 check (PO_STATUS LIKE '[A-Z]'))

create table [dbo].PURC_DETL (
PODT_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,
PO_FISYR integer not null,	
PO_NUM char (8) not null,	
PODT_STATUS char (1) not null default 'O',		
PODT_QTY integer not null default 1,		
PODT_UNITP decimal (13,2) not null default 0,		
PODT_AMOUNT as (PODT_QTY * PODT_UNITP),	
OCEX_CODE char (26) not null,		
AF_ACCT_NUM varchar(8) not null,
AF_ACCT_NAME varchar(30) not null,
AS_ACCT_NUM varchar(4) not null,
AS_ACCT_NAME varchar(30) not null, 
PODT_TRANSDATE datetime not null default getdate(),
PODT_DATETIME datetime not null default getdate(),
PODT_DESCR varchar(255) not null default '',
INVC_AUTOINC_KEY int not null default 0,					-- FK to the invoice table (no constraint);
INVOICE_TOTAL decimal(13,2) not null default 0,
EXPENSE_TOTAL decimal(13,2) not null default 0,
constraint FK_PURC_DETL_0003 foreign key (OCEX_CODE) references OCAS_EXP (OCEX_CODE),
constraint FK_PURC_DETL_0001 foreign key (PO_FISYR, PO_NUM) references PURC_INFO (PO_FISYR, PO_NUM))

create clustered index IX_PURC_DETL on purc_detl (PO_FISYR, PO_NUM)


-- this table holds a history of purchase orders (with line information) for any open purchase orders deleted by a user;
create table [dbo].PURC_HISTORY (
PH_AUTOINC_KEY integer identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,			
PO_FISYR integer not null,					
PO_NUM char (8) not null,	
PO_APPLIED_DATE datetime not null,						-- orig. applied date of po;
VEND_NUMBER char(5) not null,
PODT_QTY integer not null,		
PODT_UNITP decimal (13,2) not null,		
PODT_AMOUNT as (PODT_QTY * PODT_UNITP),	
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
OCEX_CODE char (26) not null,						
PO_CREATEDDATE datetime not null,						-- the created date of the po;
PO_DESCR varchar(125) not null,
PODT_DESCR varchar(255) not null,
PO_AUTOINC_KEY integer not null,
PODT_AUTOINC_KEY integer not null,
USER_AUTOINC_KEY integer not null,						-- the user who deleted the po;
PH_DATETIME datetime not null default getdate())				-- the deleted date (when this rec was deleted);


create table [dbo].INVOICES (
INVC_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,
INVC_FISYR integer not null,	
INVC_NUM varchar(100) not null default '',
INVC_STATUS char(1) not null default 'O',
INVC_TYPE char (1) not null default 'R',
INVC_AMOUNT decimal (13,2) not null default 0,
PO_NUM char(8) not null,	
CHKS_NUM char(8) not null default '',	
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
INVC_DATEDUE datetime not null default '',		
INVC_DATEPAID datetime not null default '',
PO_AUTOINC_KEY int not null,
PODT_AUTOINC_KEY int not null,
CKDT_AUTOINC_KEY int not null default 0,
OCEX_CODE char (26) not null,	
VEND_NUMBER char(5) not null, 		
INVC_APPLIED_DATE datetime not null,	
INVC_ISSUED_DATE  datetime not null default getdate(),	
INVC_DATETIME datetime not null default getdate())

create clustered index IX_INVOICES_001 on INVOICES (BANK_ACCT_NUM, INVC_FISYR)


create table [dbo].RECEIPT_INFO (
RCPT_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,
RCPT_FISYR int not null,
RCPT_NUM char(8) not null,	
RCPT_STATUS char(1) not null default 'O',	
RCPT_RCVD_FROM varchar(50) not null default '',					-- receipt received by		
RCPT_RECON_SW char (1) not null default 'N',					-- reconciliation switch
DPST_AUTOINC_KEY int not null default 0,		
VEND_NUMBER char(5) not null default '00000',	
RCPT_POSTED_SW char (1) not null default 'Y',					-- posted switch (this flag indicates if the receipt has been added to mtd receipts acct/sub balances)
SIGN_AUTOINC_KEY int not null default 0,					-- fk (no constraint) to the signature table
RCPT_APPLIED_DATE datetime not null default getdate(),
RCPT_TRANSDATE datetime not null default getdate(),
RCPT_DATETIME datetime not null default getdate(),
constraint PK_RECEIPT_INFO_0001 primary key clustered (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM),
constraint CK_RECEIPT_INFO_0001 check (RCPT_FISYR between 1900 and 2099),
constraint CK_RECEIPT_INFO_0002 check (RCPT_NUM LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
constraint CK_RECEIPT_INFO_0003 check (RCPT_STATUS LIKE '[A-Z]'))


create table [dbo].RECEIPT_DETL (
RCDT_AUTOINC_KEY int identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,
RCPT_FISYR int not null,
RCPT_NUM char(8) not null,		
RCDT_QTY integer not null,		
RCDT_UNITP decimal (13,2) not null,		
RCDT_AMOUNT as (RCDT_QTY * RCDT_UNITP),	
RCDT_STATUS char(1) not null default 'O',
RCDT_REMARKS varchar(125) not null default '',		
RCDT_PYMT_TYPE char(1) not null,						--(1)-cash,(2)-check,(3)-coin,(4)-credit
RCDT_PYMT_CHKNUM varchar(20) not null default '',				--holds the check number used for payment
OCRV_CODE char(16) not null,	
AF_ACCT_NUM varchar(8) not null,
AF_ACCT_NAME varchar(30) not null,
AS_ACCT_NUM varchar(4) not null,
AS_ACCT_NAME varchar(30) not null,	
RCDT_TRANSDATE datetime not null default getdate(),
RCDT_DATETIME datetime not null default getdate(),
constraint FK_RECEIPT_DETL_0001 foreign key (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM) references RECEIPT_INFO (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM),
constraint FK_RECEIPT_DETL_0003 foreign key (OCRV_CODE) references OCAS_REV (OCRV_CODE))

create clustered index IX_RECEIPT_DETL on receipt_detl (BANK_ACCT_NUM, RCPT_FISYR, RCPT_NUM)

-- this table holds a history of receipts (with line information) for any open receipts deleted by a user;
create table [dbo].RECEIPT_HISTORY (
RH_AUTOINC_KEY integer identity (1, 1),
BANK_ACCT_NUM varchar(30) not null,			
RCPT_FISYR integer not null,					
RCPT_NUM char(8) not null,	
RCDT_AMOUNT decimal (13,2) not null,		
VEND_NUMBER char(5) not null,
RCPT_RCVD_FROM varchar(50) not null default '',					--receipt received by;	
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
OCRV_CODE char(16) not null,						
RCPT_APPLIED_DATE datetime not null,						-- orig. applied date of receipt;
RCPT_CREATEDDATE datetime not null,						-- the created date of the receipt;
RCDT_REMARKS varchar(125) not null,
RCDT_PYMT_TYPE char(1) not null,						--(1)-cash,(2)-check,(3)-coin,(4)-credit;
RCDT_PYMT_CHKNUM varchar(20) not null default '',				--holds the check number used for payment;
RCPT_AUTOINC_KEY integer not null,
RCDT_AUTOINC_KEY integer not null,
USER_AUTOINC_KEY integer not null,						-- the user who deleted the receipt;
RH_DATETIME datetime not null default getdate())				-- the deleted date (when this rec was deleted)



/***********************************************************************************************************
	This table stores information for batch uploading of receipts from an external file;
	Currently, Meridian Technology asked for this table, though it's not currently in use;
***********************************************************************************************************/
create table [dbo].RECEIPT_BATCH (
RBAT_AUTOINC_KEY integer identity (1, 1) primary key clustered,
BANK_ACCT_NUM varchar(30) not null,			
RBAT_FISYR integer not null,
RBAT_CONTROL varchar(10) not null,						-- batch control number defined by external app.;
RBAT_ITEMS integer not null,							-- # of receipts in the batch;
RBAT_AMOUNT decimal (13,2) not null,						-- sum of receipts in the batch;
RBAT_CUR_BANK_BALANCE decimal (13,2) not null,					-- beginning balance of the bank before the batch;
RBAT_BEG_RCPT_NUM varchar(8) not null,						-- beginning receipt number of the batch;
RBAT_END_RCPT_NUM varchar(8) not null,						-- beginning receipt number of the batch;
RBAT_BATCH_DATE datetime not null default getdate(),				-- issued date defined by external app.;
RBAT_APPLIED_DATE datetime not null,						-- applied date when batch was created;
RBAT_DATETIME datetime not null default getdate())				-- issued date of the batch;



create table [dbo].SCHOOL_INFO (
SCHI_AUTOINC_KEY int identity (1, 1),
SCHI_ID_NUM char(3) not null primary key,					-- adpc id number; 
SCHI_SITE_ID char(3) not null,							-- default site number, usually 050;
SCHI_NAME varchar(50) not null,
SCHI_ADDR1 varchar(25) not null default '',
SCHI_ADDR2 varchar(25) not null default '',
SCHI_ADDR3 varchar(25) not null default '',		
SCHI_CITY varchar(25) not null default '',		
SCHI_STATE char(2) not null default '',		
SCHI_ZIP char(5) not null default '',		
SCHI_ZIP_EXT char(4) not null default '',	
SCHI_PHONE1 varchar(25) not null default '',		
SCHI_PHONE1_EXT varchar(10) not null default '',		
SCHI_PHONE2 varchar(25) not null default '',		
SCHI_PHONE2_EXT varchar(10) not null default '',		
SCHI_FAX varchar(25) not null default '',	
SCHI_CONTACT varchar(50) not null default '',		
SCHI_DISTRICT_ID char(4) not null default '',		
SCHI_COUNTY_ID char(2) not null default '',		
SCHI_USE_OCAS char(1) not null default 'Y',					-- (Y)- true, (N)- false;
SCHI_TRANSDATE datetime not null default getdate(),	
SCHI_DATETIME datetime not null default getdate(),
constraint CK_SCHOOL_INFO_0001 check (SCHI_ID_NUM LIKE '[0-9][0-9][0-9]'),
constraint CK_SCHOOL_INFO_0002 check (SCHI_SITE_ID LIKE '[0-9][0-9][0-9]'))


create table [dbo].SHIPPING (
SHIP_AUTOINC_KEY int identity (1, 1),
SHIP_NAME varchar(50) not null default '',	
SHIP_DEFAULT smallint not null default 0,
SHIP_ADDR1 varchar(25) not null default '',		
SHIP_ADDR2 varchar(25) not null default '',
SHIP_ADDR3 varchar(25) not null default '',		
SHIP_CITY varchar(25) not null default '',		
SHIP_STATE char(2) not null default '',		
SHIP_ZIP char(5) not null default '',		
SHIP_ZIP_EXT char(4) not null default '',	
SHIP_TRANSDATE datetime not null default getdate(),	
SHIP_DATETIME datetime not null default getdate())


create table [dbo].SIGNATURES (
SIGN_AUTOINC_KEY int identity (1, 1) primary key clustered,
SIGN_FNAME varchar(25) not null default '',	
SIGN_LNAME varchar(25) not null default '',
SIGN_MI varchar(1) not null default '',
SIGN_TITLE varchar(25) not null default '',		
SIGN_LEVEL char(1) not null default '1',					-- (1)-primary; (2)-secondary;
SIGN_CHECK_SW char(1) not null default 'N',					-- indicates use signature on checks;
SIGN_PO_SW char(1) not null default 'N',					-- indicates use signature on po's;
SIGN_RCPT_SW char(1) not null default 'N',					-- indicates use signature on receipts;
SIGN_SIGNATURE image,		
SIGN_TRANSDATE datetime not null default getdate(),	
SIGN_DATETIME datetime not null default getdate())


create table [dbo].SYSTEM_BACKUPS (
SYBK_AUTOINC_KEY int identity (1, 1),
SYBK_DB_DAILYPATH varchar(100) not null default '',				-- daily backuppath;
SYBK_DB_MONTHLYPATH varchar(100) not null default '',				-- monthly backuppath;
SYBK_DB_NIGHTLYPATH varchar(100) not null default '',				-- nightly backuppath;
SYBK_DB_YEARLYPATH varchar(100) not null default '',				-- yearly backuppath;
SYBK_EXECUTE_DAILY char(1) not null default 'N',				-- (0)-default; (1)-requested; (2-8)-in process; (9)-complete;
SYBK_EXECUTE_MONTHLY char(1) not null default 'N',
SYBK_EXECUTE_NIGHTLY char(1) not null default 'N',
SYBK_EXECUTE_YEARLY char(1) not null default 'N',
SYBK_EXECUTE_FTP char(1) not null default 'N',
SYBK_EXECUTE_TEMP char(1) not null default 'N',
SYBK_LAST_DAILY_BACKUP datetime not null default getdate(),		
SYBK_OFFSITE_LICENSE char(1) not null default 'N',
SYBK_TRANSDATE datetime not null default getdate(),		
SYBK_DATETIME datetime not null default getdate())


-- NOTE: this table is not currently in use;
create table [dbo].SYSTEM_FTP (
SFTP_AUTOINC_KEY int identity (1, 1),
SFTP_STATUS smallint not null default 0,					-- (0-ready, 1-backup, 2-compress, 9-finished)
SFTP_FILEPATH varchar(150) not null default '',					-- the physical path to the backup for ftp
SFTP_FILENAME varchar(50) not null default '',					-- the filename of the backup for ftp
SFTP_TRANSDATE datetime not null default getdate(),		
SFTP_DATETIME datetime not null default getdate())


create table [dbo].SYSTEM_INFO (
SYSI_AUTOINC_KEY int identity (1, 1),
SYSI_APPLICATION_DIR varchar(100) not null default '',				-- the path to the application exe
SYSI_COMPONENT_DIR varchar(100) not null default '',				-- the path to the components
SYSI_FTP_GET_DATE smalldatetime not null default 0,				-- last uploaded date
SYSI_FTP_SET_DATE smalldatetime not null default 0,				-- last downloaded date
SYSI_PRIMARY_FTP_DOMAIN varchar(50) not null default '',		
SYSI_PRIMARY_FTP_IP varchar(16) not null default '',		
SYSI_PRIMARY_FTP_LOGIN varchar(20) not null default '',		
SYSI_PRIMARY_FTP_PASSWORD varchar(20) not null default '',			-- this column not used...
SYSI_SECONDARY_FTP_DOMAIN varchar(50) not null default '',		
SYSI_SECONDARY_FTP_IP varchar(16) not null default '',		
SYSI_SECONDARY_FTP_LOGIN varchar(20) not null default '',		
SYSI_SECONDARY_FTP_PASSWORD varchar(20) not null default '',			-- this column not used...		
SYSI_FTP_PORT varchar(5) not null default '',		
SYSI_SERVER_NAME varchar(75) not null default '',				-- name of the server where the database resides
SYSI_UNC_PATH varchar(150) not null default '',					-- path to the shared folder
SYSI_DB_PATH varchar(100) not null default '',					-- database path
SYSI_SQLSERVER_VERSION varchar(50) not null default '',
SYSI_TRANSDATE datetime not null default getdate(),		
SYSI_DATETIME datetime not null default getdate(),
SYSI_INVOICE_SW smallint not null default 2)					-- default to 2 since invoices are required;


-- used by the activity client (AF_MAIN) to process updates sent thru the application;
create table [dbo].SYSTEM_UPDATES (
SYSU_AUTOINC_KEY int identity (1, 1),
SYSU_VERSION varchar(25) not null,			
SYSU_COMPLETED smallint not null default 0,			
SYSU_BEGIN_DATE smalldatetime not null default '',
SYSU_END_DATE smalldatetime not null default '',
SYSU_PROCESS_NAME varchar(50) not null default '',
constraint UNIQ_SYSTEM_UPDATES_0001 unique clustered (SYSU_VERSION))



/*
***************  types of adjustments:  *****************************
*   (B)-bank charge; (I)-interest; (N)-NSF  			    *
*   (E)-general expenditure adj; (R)-general revenue adj            *
*********************************************************************
*/


create table [dbo].TRANSACTIONS (
TRAN_AUTOINC_KEY int identity (1, 1) primary key clustered,
TRAN_TYPE char(1) not null,							-- E-exp; R-rev; I-interest; B-bank N-NSF;
TRAN_AMT decimal (13,2) not null default 0,
OCEX_CODE char (26) not null default '',
OCRV_CODE char (16) not null default '',					
OCEX_CODE_HIST char (26) not null default '',
OCRV_CODE_HIST char (16) not null default '',
TRAN_FISYR int not null,	
BANK_ACCT_NUM varchar(30) not null default '0',
AF_ACCT_NUM varchar(8) not null default '0' ,		
AS_ACCT_NUM varchar(4) not null default '0',
USER_AUTOINC_KEY int not null default '0', 
TRAN_APPLIED_DATE datetime not null default getdate(),
TRAN_TRANSDATE datetime not null default getdate(),
TRAN_DATETIME datetime not null default getdate(),
TRAN_DESCR varchar(255) not null default '',					-- appended or changed description
TRAN_REMARKS varchar(150) not null default '',		
TRAN_DESCR_HIST varchar(255) not null default '',				-- original description during creation
TRAN_REMARKS_HIST varchar(150) not null default '',
constraint CK_TRANS_0001 check (TRAN_TYPE LIKE '[A-Z]'))


create table [dbo].TRANSFERS (
TRX_AUTOINC_KEY int identity (1, 1) primary key clustered,
TRX_FISYR int not null,	
BANK_ACCT_NUM varchar(30) not null,
AF_ACCT_NUM_FROM varchar(8) not null,		
AS_ACCT_NUM_FROM varchar(4) not null,
AF_ACCT_NUM_TO varchar(8) not null,		
AS_ACCT_NUM_TO varchar(4) not null,
TRX_AMT decimal (13,2) not null default 0,
USER_AUTOINC_KEY int not null, 
TRX_APPLIEDDATE datetime not null default getdate(),				-- date of board approval (user-defined)
TRX_TRANSDATE datetime not null default getdate(),
TRX_DATETIME datetime not null default getdate(),
TRX_DESCR varchar(50) not null default '',
TRX_REMARKS varchar(255) not null default '', 
TRX_DESCR_HIST varchar(50) not null,						-- original descr
TRX_REMARKS_HIST varchar(255) not null default '') 				-- original remarks


create table [dbo].CHKS_REG (
CKRG_AUTOINC_KEY int identity (1, 1) primary key,				-- acts as the register number
BANK_ACCT_NUM varchar(30) not null,		
CKRG_FISYR int not null,								
BANK_CUR_BALANCE decimal (13,2) not null,					-- curbalance before checks
CKRG_TRANSDATE datetime not null default getdate(),
CKRG_DATETIME datetime not null default getdate())


create table [dbo].CHKS_INFO (
CHKS_AUTOINC_KEY int identity (1, 1) primary key,
CKRG_AUTOINC_KEY int not null,
BANK_ACCT_NUM varchar(30) not null,		
CHKS_FISYR int not null,	
CHKS_NUM char(8) not null,	
CHKS_STATUS char (1) not null default 'O',					-- (O)-open; (C)-closed; (X)-stale; (V)-void;
CHKS_AMOUNT decimal (13,2) not null,	
CHKS_PRINTED_SW char (1) not null default 'N',
CHKS_RECON_SW char (1) not null default 'N',					-- reconciliation switch
CHKS_POSTED_SW char (1) not null default 'Y',					-- posted switch (flag indicates this item has been added to mtd expenditures?)
CHKS_PAYEE_NAME varchar (50) not null default '',		
CHKS_DESCR varchar(125) not null default '',	 
PO_FISYR integer not null,	
PO_NUM char (8) not null,
VEND_NUMBER char(5) not null, 		
SIGN_AUTOINC_KEY int not null default 0,					-- fk (no constraint) to the signature table
CHKS_APPLIED_DATE datetime not null default getdate(),
CHKS_TRANSDATE datetime not null default getdate(),
CHKS_DATETIME datetime not null default getdate(),
VEND_AUTOINC_KEY int not null default 0,
CHKS_MULTI_PO smallint not null default 0,
constraint UNIQ_CHKS_INFO_0001 unique clustered (BANK_ACCT_NUM, CHKS_FISYR, CHKS_NUM),
constraint FK_CHKS_INFO_0001 foreign key (PO_FISYR, PO_NUM) references PURC_INFO (PO_FISYR, PO_NUM),
constraint FK_CHKS_INFO_0002 foreign key (CKRG_AUTOINC_KEY) references CHKS_REG (CKRG_AUTOINC_KEY))


create table [dbo].CHKS_DETL (
CKDT_AUTOINC_KEY int identity (1, 1),
CHKS_AUTOINC_KEY int not null,	
CKDT_AMOUNT decimal (13,2) not null,	
BANK_ACCT_NUM varchar(30) not null,
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
CKDT_DESCR varchar (255) not null default '',		
PODT_AUTOINC_KEY int not null,
OCEX_CODE char (26) not null,			
CKDT_TRANSDATE datetime not null default getdate(),		
CKDT_DATETIME datetime not null default getdate(),
INVC_AUTOINC_KEY int not null default 0,
INVC_NUM varchar(100) not null default '',
PO_AUTOINC_KEY int not null default 0,
constraint FK_CHKS_DETL_0001 foreign key (CHKS_AUTOINC_KEY) references CHKS_INFO (CHKS_AUTOINC_KEY))

create clustered index IX_CHKS_DETL on chks_detl (BANK_ACCT_NUM, AF_ACCT_NUM, AS_ACCT_NUM)


create table [dbo].CHKS_AUDIT (
CHKA_AUTOINC_KEY int identity (1,1),
CHKS_AUTOINC_KEY int not null,
BANK_AUTOINC_KEY int not null,
CHKS_FISYR int not null,
CHKS_NUM char(8) not null,
CHKS_AMOUNT decimal (13,2) not null,
CHKS_PAYEE_NAME varchar (50) not null default '',
VEND_NUMBER char(5) not null,
PODT_AUTOINC_KEY int not null,
CKDT_AMOUNT decimal (13,2) not null,
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
OCEX_CODE char (26) not null,	
USER_AUTOINC_KEY int not null default 0,
CHKA_DATETIME datetime not null default getdate())


create table [dbo].VOIDCHECK (
VOIDCHK_AUTOINC_KEY int identity (1, 1) primary key,
VOIDCHK_NUM char(8) not null,
VOIDCHK_AMT decimal (13,2) not null,
VOIDCHK_FISYR int not null,	
VOIDCHK_APPLIED_DATE datetime not null,
VOIDCHK_TRANSDATE datetime not null default getdate(),
VOIDCHK_DATETIME datetime not null default getdate(),
VOIDCHK_REMARKS varchar(150) not null default '',		
USER_FULLNAME varchar(50) not null, 
BANK_ACCT_NUM varchar(30) not null,
OCEX_CODE char (26) not null ,
AF_ACCT_NUM varchar(8) not null,		
AS_ACCT_NUM varchar(4) not null,
CHKS_AUTOINC_KEY int not null default 0,
CKDT_AUTOINC_KEY int not null default 0,
CKDT_AMOUNT decimal (13,2) not null default 0""



create table [dbo].VOIDRECEIPT (
VOIDRCPT_AUTOINC_KEY int identity (1, 1) primary key,
VOIDRCPT_NUM char(8) not null,
VOIDRCPT_AMT decimal (13,2) not null,
VOIDRCPT_FISYR int not null,	
VOIDRCPT_APPLIED_DATE datetime not null,
VOIDRCPT_TRANSDATE datetime not null default getdate(),
VOIDRCPT_DATETIME datetime not null default getdate(),
VOIDRCPT_REMARKS varchar(150) not null default '',		
USER_FULLNAME varchar(50) not null, 
BANK_ACCT_NUM varchar(30) not null,
OCRV_CODE char (16) not null ,
AF_ACCT_NUM varchar(8) not null,		
AS_ACCT_NUM varchar(4) not null""



create table [dbo].DEPOSIT_INFO (
DPST_AUTOINC_KEY int identity (1, 1) primary key clustered,
BANK_ACCT_NUM varchar(30) not null,
DPST_FISYR int not null,	
DPST_NUM char(5) not null,
DPST_AMOUNT decimal(13,2) not null,	
DPST_STATUS char(1) not null default 'O',		
DPST_REMARKS varchar (125) not null default '',	
DPST_TRANSDATE datetime not null default getdate(),	
DPST_DATETIME datetime not null default getdate(),
constraint UNIQ_DEPOSIT_INFO_0001 unique (DPST_FISYR, DPST_NUM),
constraint CK_DEPOSIT_INFO_0001 check (DPST_NUM LIKE '[0-9][0-9][0-9][0-9][0-9]'))	


-- this table is not currently being used;
create table [dbo].LOGOS (
LOGO_AUTOINC_KEY int identity (1, 1),
LOGO_SCHI_ID_NUM varchar (5) not null,	
LOGO_VALUE image not null default '',		
LOGO_TRANSDATE datetime not null default getdate(),			
LOGO_DATETIME datetime not null default getdate())





/***********************************************************************************************************
    USER TABLES;
***********************************************************************************************************/

-- holds a single user record with name, userid, password;
create table [dbo].USER_INFO (
USER_AUTOINC_KEY int identity (1, 1) primary key clustered,
USER_PID varchar(25) not null,
USER_PASSWORD varchar(25) not null,	
USER_STATUS char(1) not null default 'O',	
USER_LASTNAME varchar(25) not null,		
USER_FIRSTNAME varchar(25) not null,
USER_MI char(1) not null default '',	
USER_FULLNAME as rtrim(USER_LASTNAME) + ', ' + rtrim(USER_FIRSTNAME) + ' ' + (USER_MI),
USER_TRANSDATE datetime not null default getdate(),		
USER_DATETIME datetime not null default getdate(),
USER_ACCOUNT_SW smallint not null default -1,		-- Switch that determines if User Account table is used for access;
constraint CK_USER_INFO_PASSWORD_0001 check (len(USER_PASSWORD) > 5))


--USER ACCOUNT CODES; This table is used to determine the accounts available to the logged in user; 
--Similar to Trends, this table will hold an entry for each user key + account key that the user is
--allowed to access;
create table [dbo].USER_ACCOUNTS (
UACC_AUTOINC_KEY int identity (1, 1),
USER_AUTOINC_KEY int not null,						-- FK TO THE USER TABLE;
AS_AUTOINC_KEY	int not null,						-- FK TO THE SUBACCOUNT TABLE;
UACC_DATETIME datetime not null default getdate(),	-- DATESTAMP OF WHEN PERMISSION WAS CREATED;
constraint UNIQ_USER_ACCOUNT_0001 unique clustered (USER_AUTOINC_KEY, AS_AUTOINC_KEY))


-- holds a unique id number and name for each assembly that requires permission;
create table [dbo].UASSEMBLIES (
ASSM_AUTOINC_KEY int identity (1,1),
ASSM_ID int not null,  
ASSM_DESCR varchar(50) not null default '',
ASSM_DATETIME datetime not null default getdate(),
constraint UQ_UASSEMBLIES_0001 unique clustered (ASSM_ID))

-- holds additional id number and name entries for an assembly; esp. for requisition reviewer, approver, etc; 
create table [dbo].UASSEMBLIES_AUXILIARY (
AAUX_AUTOINC_KEY int identity (1,1),
AAUX_ID int not null,  
AAUX_DESCR varchar(50) not null default '',
AAUX_DATETIME datetime not null default getdate(),
constraint UQ_UASSEMBLIESAUX_0001 unique clustered (AAUX_ID))

-- contains a record for each unique user and assembly combination;  each user must have a permission 
-- for each assembly within the application;
create table [dbo].UPERMISSIONS (
PERM_AUTOINC_KEY int identity (1,1),
USER_AUTOINC_KEY int not null,							-- FK to the user_info table;
ASSM_ID int not null,  								-- FK to the uassemblies table;
PERM_RW int not null default 0, 						-- (0)none; (1)read; (2)full;
PERM_DATETIME datetime not null default getdate(),
constraint FK_UPERMISSIONS_0001 foreign key (USER_AUTOINC_KEY) references USER_INFO (USER_AUTOINC_KEY),
constraint FK_UPERMISSIONS_0002 foreign key (ASSM_ID) references UASSEMBLIES (ASSM_ID),
constraint UQ_UPERMISSIONS_0001 unique clustered (USER_AUTOINC_KEY, ASSM_ID))

-- contains the permissions for each user and auxiliary assembly; esp. requisition reviewer, approver;
create table [dbo].UPERMISSIONS_AUXILIARY (
PAUX_AUTOINC_KEY int identity (1,1),
USER_AUTOINC_KEY int not null,							-- FK to the user_info table;
AAUX_ID int not null,  								-- FK to the uassemblies_auxiliary table;
PAUX_RW int not null default 0, 						-- (0)none; (1)read; (2)full;
PAUX_DATETIME datetime not null default getdate(),
constraint FK_UPERMISSIONSAUX_0001 foreign key (USER_AUTOINC_KEY) references USER_INFO (USER_AUTOINC_KEY),
constraint FK_UPERMISSIONSAUX_0002 foreign key (AAUX_ID) references UASSEMBLIES_AUXILIARY (AAUX_ID),
constraint UQ_UPERMISSIONSAUX_0001 unique clustered (USER_AUTOINC_KEY, AAUX_ID))


/***********************************************************************************************************
    USER TABLE INSERTS;
	NOTE: The following scripts are used as lookup entries for the permission system in Activity Fund; 
		  these entries must be present in each database created;
***********************************************************************************************************/

-- default entries for the UASSEMBLIES table;
insert into uassemblies (assm_id, assm_descr) values (110, 'Account information')
insert into uassemblies (assm_id, assm_descr) values (120, 'Adjustments')
insert into uassemblies (assm_id, assm_descr) values (130, 'Transfers')
insert into uassemblies (assm_id, assm_descr) values (210, 'Bank information')
insert into uassemblies (assm_id, assm_descr) values (310, 'Checks')
insert into uassemblies (assm_id, assm_descr) values (320, 'Clear checks')
insert into uassemblies (assm_id, assm_descr) values (330, 'Void checks')
insert into uassemblies (assm_id, assm_descr) values (410, 'OCAS Expenditures')
insert into uassemblies (assm_id, assm_descr) values (420, 'OCAS Revenue')
insert into uassemblies (assm_id, assm_descr) values (510, 'Purchase orders')
insert into uassemblies (assm_id, assm_descr) values (520, 'Invoices')
insert into uassemblies (assm_id, assm_descr) values (610, 'Receipts')
insert into uassemblies (assm_id, assm_descr) values (620, 'Clear receipts')
insert into uassemblies (assm_id, assm_descr) values (630, 'Void receipts')
insert into uassemblies (assm_id, assm_descr) values (640, 'Issue deposits')
insert into uassemblies (assm_id, assm_descr) values (710, 'Requisitions')
insert into uassemblies (assm_id, assm_descr) values (810, 'Reconciliation/Closeout')
insert into uassemblies (assm_id, assm_descr) values (820, 'Reporting')
insert into uassemblies (assm_id, assm_descr) values (910, 'System information')
insert into uassemblies (assm_id, assm_descr) values (920, 'School information')
insert into uassemblies (assm_id, assm_descr) values (930, 'User information')
insert into uassemblies (assm_id, assm_descr) values (940, 'Vendor information')

--default entries for the UASSEMBLIES_AUXILIARY table;
insert into uassemblies_auxiliary (aaux_id, aaux_descr) values (751, 'Review requisitions')
insert into uassemblies_auxiliary (aaux_id, aaux_descr) values (752, 'Mandatory reviewer')
insert into uassemblies_auxiliary (aaux_id, aaux_descr) values (753, 'Reviewer edit')
insert into uassemblies_auxiliary (aaux_id, aaux_descr) values (761, 'Convert requisitions')






/***********************************************************************************************************
    REQUISITION TABLES;
***********************************************************************************************************/

create table [dbo].REQ_INFO (
REQ_AUTOINC_KEY int identity (1, 1) primary key,
BANK_ACCT_NUM varchar(30) not null,
REQ_FISYR int not null,	
REQ_NUM char (8) not null,
REQ_PRIORITY smallint not null default 1,					-- (-1)-hold; (1)-normal; (2)-high;
REQ_TYPE char(1) not null default 'R',						-- (R)egular; (B)lanket; 
REQ_STATUS char (1) not null default 'O',					-- (O)-open; (C)-closed [existing purchase order]; (D)-deleted; (X)-closed due to yearend closeout;
VEND_NUMBER char(5) not null,		
REQ_MACHINE_ID varchar(50) not null default 'SYSTEM',
PO_AUTOINC_KEY int not null default 0,
REQ_DESCR varchar(125) not null default '',		
USER_AUTOINC_KEY int not null,
REQ_APPLIED_DATE datetime not null,
REQ_TRANSDATE datetime not null default getdate(),		
REQ_DATETIME datetime not null default getdate(),
constraint PK_REQ_INFO_0001 unique clustered (REQ_FISYR, REQ_NUM))


create table [dbo].REQ_DETL (
RQDT_AUTOINC_KEY int identity (1, 1) primary key,
REQ_AUTOINC_KEY int not null,
RQDT_STATUS char (1) not null default 'O',		
RQDT_QTY int not null default 1,		
RQDT_UNITP decimal (13,2) not null default 0,		
RQDT_AMOUNT as (RQDT_QTY * RQDT_UNITP),	
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
OCEX_CODE char (26) not null,		
RQDT_TRANSDATE datetime not null default getdate(),
RQDT_DATETIME datetime not null default getdate(),
RQDT_DESCR varchar(255) not null default '',		
constraint FK_RQDT_DETL_0001 foreign key (REQ_AUTOINC_KEY) references REQ_INFO (REQ_AUTOINC_KEY))


-- lists the approvers & reviewers, and their heirarchy;
create table [dbo].REQ_APPROVER (
RAPV_AUTOINC_KEY int identity (1, 1) primary key,
USER_AUTOINC_KEY int not null,
RAPV_TYPE char(1) not null,							-- (R)-reviewer; (A)-approver;
RAPV_LEVEL smallint not null default 0,						-- priority level (0-99); [0] lowest to [99] highest;
RAPV_MANDATORY char(1) not null default 'N',
RAPV_EDIT_YN char(1) not null default 'N',
RAPV_STATUS char(1) not null,							-- (A)-active; (D)-deleted/inactive;
constraint FK_REQ_APPROVER_0001 foreign key (USER_AUTOINC_KEY) references USER_INFO (USER_AUTOINC_KEY),
constraint UQ_REQ_APPROVER_0001 unique (USER_AUTOINC_KEY))


-- This table will hold deleted requisitions only; Note: contains the header & detail in the same record;
create table [dbo].REQ_AUDIT (
RAUD_AUTOINC_KEY int identity (1, 1) primary key,
BANK_ACCT_NUM varchar(30) not null,
REQ_FISYR int not null,	
REQ_NUM char (8) not null,
VEND_NUMBER char(5) not null,		
USER_AUTOINC_KEY int not null,
REQ_MACHINE_ID varchar(50) not null,
REQ_DESCR varchar(125) not null,		
REQ_APPLIED_DATE datetime not null,
REQ_DATETIME datetime not null,
RQDT_QTY int not null,		
RQDT_UNITP decimal (13,2) not null,		
RQDT_AMOUNT as (RQDT_QTY * RQDT_UNITP),	
RQDT_STATUS char (1) not null,	
AF_ACCT_NUM varchar(8) not null,
AS_ACCT_NUM varchar(4) not null,
OCEX_CODE char (26) not null,		
RQDT_DESCR varchar(255) not null,		
RQDT_DATETIME datetime not null,
RAUD_DATETIME datetime not null default getdate())


-- holds the workflow of requisitions available in the system;
create table [dbo].REQ_QUEUE (
RQUE_AUTOINC_KEY int identity (1, 1),
REQ_AUTOINC_KEY int not null,
RAPV_AUTOINC_KEY int not null,
RQUE_TYPE char(1) not null,									-- (A)pprover; (R)eviewer;
RQUE_LEVEL smallint not null default 0,						-- (-1)rejection; (0)null; (1)approval;
RQUE_APPROVED smallint not null default 0,					-- (0)in queue; (1)approved;
RQUE_DATETIME datetime not null default getdate())

-- index on the req_queue table;
create clustered index IX_REQ_QUEUE on req_queue (REQ_AUTOINC_KEY, RAPV_AUTOINC_KEY)


-- holds the comments for the requisition workflow (Note: this is a detail record tied to the queue); 
create table [dbo].REQ_COMMENTS (
RCOM_AUTOINC_KEY int identity (1, 1),
REQ_AUTOINC_KEY int not null,							-- FK to the requisition header;
RAPV_AUTOINC_KEY int not null,							-- FK to the approver table;
RCOM_APPROVED int not null,							-- (1)-approved; (-1)-rejected;
RCOM_NAME varchar(50) not null,
RCOM_COMMENTS varchar(255) not null default '',
RCOM_DATETIME datetime not null default getdate())



