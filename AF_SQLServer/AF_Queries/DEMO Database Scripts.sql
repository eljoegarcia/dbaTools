

/********************************************************************************************************
	
THE FOLLOWING SCRIPTS ARE USED TO STRIP AN EXISTING PRODUCTION DATABASE FOR USE AS A 
	
DEMO DATABASE FOR ANY SCHOOL TO USE. ANY PRODUCTION INFORMATION WITHIN THIS DATABASE
	
MUST BE REPLACED WITH GENERIC SUBSTITUTES.

********************************************************************************************************/



-- CHANGE BANK INFORMATION;
update bank_info SET bank_name = '$BANK NAME', bank_addr1 = '2201 N ASH', bank_addr2 = '', bank_city = 'PONCA CITY', bank_zip = '76501',
  bank_phone1 = '800 747-2372', bank_phone2 = '580 762-6376', bank_fax = '', bank_contact1 = '', 
  bank_contact2 = '', bank_custodian1 = 'JOAN WELBORN', bank_custodian2 = ''




-- CHANGE ACCOUNT INFORMATION IF NEEDED (replace original string with new string);
update acct_info set af_acct_name = replace(af_acct_name, 'HENNESSEY', 'OKLAHOMA')
update acct_sub set as_acct_name = replace(as_acct_name, 'HENNESSEY', 'OKLAHOMA')
update acct_history set af_acct_name = replace(af_acct_name, 'HENNESSEY', 'OKLAHOMA')
update acct_history set as_acct_name = replace(as_acct_name, 'HENNESSEY', 'OKLAHOMA')
update purc_detl set af_acct_name = replace(af_acct_name, 'HENNESSEY', 'OKLAHOMA')
update purc_detl set as_acct_name = replace(as_acct_name, 'HENNESSEY', 'OKLAHOMA')
update receipt_detl set af_acct_name = replace(af_acct_name, 'HENNESSEY', 'OKLAHOMA')
update receipt_detl set as_acct_name = replace(as_acct_name, 'HENNESSEY', 'OKLAHOMA')


-- CHANGE CHECK PAYEE INFORMATION IF NEEDED (replace original string with new string);
update chks_info set chks_payee_name = replace(chks_payee_name, 'HENNESSEY', 'OKLAHOMA')



-- RECEIPT INFORMATION;
update receipt_info set rcpt_rcvd_from = replace(rcpt_rcvd_from, 'MR CONWAY', 'MRS WELBORN')
update receipt_history set rcpt_rcvd_from = replace(rcpt_rcvd_from, 'MR CONWAY', 'MRS WELBORN')


-- CHANGE REQUISITION INFORMATION;
update req_comments set rcom_name = '$ADMIN$', rcom_comments = '$COMMENTS'


-- CHANGE SCHOOL, SHIPPING, AND SIGNATURE INFORMATION;
update school_info set schi_id_num = '999', schi_site_id = '050', schi_name = 'PUBLIC SCHOOLS ACTIVITY FUND', 
	schi_addr1 = '2201 N ASH', schi_addr2 = '', schi_addr3 = '', schi_city = 'PONCA CITY', schi_zip = '76501',
	schi_phone1 = '800 747-2372', schi_phone1_ext = '',schi_phone2 = '580 762-6376', schi_phone2_ext = '', schi_fax = '',
	schi_contact = 'ANGIE FRENCH', schi_district_id = 'I000', schi_county_id = '00'

update shipping set ship_name = 'PUBLIC SCHOOLS ACTIVITY FUND', ship_addr1 = '2201 N ASH', ship_addr2 = '', ship_addr3 = '', 
	ship_city = 'PONCA CITY', ship_zip = '76501'
update signatures set sign_fname = '$FIRSTNAME', sign_lname = '$LASTNAME', sign_signature = null



-- NOTE: IT MAY BE EASIER TO USE THE CLIENT TO REMOVE OLD USERS AND RENAME CURRENT USERS;
-- CHANGE USER INFORMATION;
delete user_permissions where user_autoinc_key in (select user_autoinc_key from user_info where user_status = 'D')
delete upermissions where user_autoinc_key in (select user_autoinc_key from user_info where user_status = 'D')
delete upermissions_auxiliary where user_autoinc_key in (select user_autoinc_key from user_info where user_status = 'D')
delete req_approver where user_autoinc_key in (select user_autoinc_key from user_info where user_status = 'D')
delete user_info where user_status = 'D'
-- ASSIGN ONE USER AS REQ CONVERTER;
update user_info set user_pid = 'activity', user_password = 'french', user_firstname = 'ANGIE', user_lastname = 'FRENCH', user_account_sw = 1 
	where user_autoinc_key = 5
update user_info set user_pid = 'activity', user_password = 'activity', user_firstname = 'JOAN', user_lastname = 'WELBORN', user_account_sw = 1 
	where user_autoinc_key = 6



-- CHANGE VENDOR INFORMATION;
update vend_info set vend_addr1 = replace(vend_addr1, '5', '12')	--find & replace adpc vendor name;
update vend_info set vend_addr1 = replace(vend_addr1, '8', '5')	--find & replace adpc vendor name;
update vend_info set vend_addr1 = replace(vend_addr1, '7', '11')	--find & replace adpc vendor name;
update vend_info set vend_city = replace(vend_city, 'HENNESSEY', 'OKLAHOMA CITY')
update vend_info set vend_city = 'OKLAHOMA CITY' where vend_city = ''
update vend_info set vend_state = 'OK' where vend_city = 'OKLAHOMA CITY'
update vend_info set vend_zip = replace(vend_zip, '73742', '73194 ')
update vend_info set vend_ssn = '730000000' where len(vend_ssn) > 0
update vend_info set vend_phone1 = '800 747-2372' where len(vend_phone1) > 0


-- CHANGE VOIDCHECKS & VOIDRECEIPTS;
update voidcheck set user_fullname = '$USERNAME'
update voidreceipt set user_fullname = '$USERNAME'

