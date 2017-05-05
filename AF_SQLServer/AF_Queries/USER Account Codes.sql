
/*********************************************************************************************************************
   USER ACCOUNT CODES ~ 
   TABLES USED FOR THE USER ACCOUNT/PERMISSIONS SYSTEM THAT WILL RESTRICT A USER'S VIEW
   TO SELECTED ACCOUNT/SUBACCOUNTS WITHIN THE ACTIVITY FUND SYSTEM;  
*********************************************************************************************************************/

--drop table user_accounts
update user_info set user_account_sw = 1


create table USER_ACCOUNTS (
UACC_AUTOINC_KEY int identity (1, 1),
USER_AUTOINC_KEY int not null,				-- FK TO THE USER TABLE;
AS_AUTOINC_KEY	int not null,				-- FK TO THE SUBACCOUNT TABLE;
UACC_DATETIME datetime not null default getdate(),	-- DATESTAMP OF WHEN PERMISSION WAS CREATED;
constraint UNIQ_USER_ACCOUNT_0001 unique clustered (USER_AUTOINC_KEY, AS_AUTOINC_KEY))

-- make this switch default to all accounts for existing users, though new users added after will be set to -1;
alter table user_info add USER_ACCOUNT_SW smallint not null default -1 -- (-1) none; (0) user defined; (1) all accounts;

/*
insert into user_accounts (user_autoinc_key, as_autoinc_key, uacc_datetime) values (2, 2, getdate())
insert into user_accounts (user_autoinc_key, as_autoinc_key, uacc_datetime) values (2, 4, getdate())
insert into user_accounts (user_autoinc_key, as_autoinc_key, uacc_datetime) values (2, 52, getdate())
insert into user_accounts (user_autoinc_key, as_autoinc_key, uacc_datetime) values (2, 96, getdate())
*/


select * from user_accounts
select * from user_info WHERE user_status <> 'D' ORDER BY user_lastname, user_firstname, user_mi
select * from acct_sub order by af_acct_num, as_acct_num


-- list of subaccounts;
select h.af_autoinc_key, as_autoinc_key, as_status, h.af_acct_num, as_acct_num, af_acct_name, as_acct_name
from acct_info as h, acct_sub as d
where h.bank_acct_num = d.bank_acct_num
and h.af_acct_num = d.af_acct_num
and h.bank_acct_num = '814174723'
order by h.af_acct_num, as_acct_num

-- list of active users;
SELECT 0, user_autoinc_key, user_fullname, user_pid, user_password, user_lastname, user_firstname, user_mi, user_status 
FROM user_info WHERE user_status <> 'D' 
ORDER BY user_lastname, user_firstname, user_mi

