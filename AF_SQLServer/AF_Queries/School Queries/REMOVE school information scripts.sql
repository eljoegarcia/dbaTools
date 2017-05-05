

update bank_info SET bank_name = 'ADPC DEMO BANK', bank_next_check = '00000001', bank_next_receipt = '00000001', bank_custodian1 = 'ADPC USER1', bank_custodian2 = 'ADPC USER2'

update acct_info set af_acct_name = replace(af_acct_name, 'CLINTON','ADPC') 
update acct_sub set as_acct_name = replace(as_acct_name, 'CLINTON','ADPC')
update vend_info set vend_name = replace(vend_name, 'CLINTON','ADPC') 
update vend_info set vend_city = 'PONCA CITY', vend_state = 'OK', vend_zip = '74601',
	vend_phone1 = '1(800)747-2372', vend_phone2 = '1(800)747-2372'
update school_info set schi_id_num = '999', schi_site_id = '050', 
	schi_name = 'ADPC DEMO INSTITUTIONAL', schi_addr1 = 'P.O. Box 591',
	schi_city = 'PONCA CITY', schi_zip = '74601', schi_phone1 = '1(800)747-2372',
	schi_district_id = 'I000', schi_county_id = '00' 
update transactions set tran_descr = replace(tran_descr, 'CLINTON','ADPC'), 
	tran_remarks = replace(tran_remarks, 'CLINTON','ADPC'), 
	tran_descr_hist = replace(tran_descr_hist, 'CLINTON','ADPC'),
	tran_remarks_hist = replace(tran_remarks_hist, 'CLINTON','ADPC')

update ocas_exp set ocex_descr = 'EXPENDITURE DESCRIPTION MISSING' WHERE ocex_descr = ''
update ocas_rev set ocrv_descr = 'REVENUE DESCRIPTION MISSING' WHERE ocrv_descr = ''

update school_info set schi_shipname = 'ADPC PUBLIC SCHOOLS', schi_shipaddr1 = '', 
	schi_shipaddr2 = '', schi_shipaddr3 = '', schi_shipcity = '', schi_shipstate = '', 
	schi_shipzip = '', schi_shipzip_ext = ''


select * from bank_info
select * from acct_info
select * from acct_sub
select * from school_info
select * from system_backups
select * from transactions
select * from transfers
select * from user_info
select * from vend_info
select * from current_values


update vend_info set vend_addr1 = '2201 N ASH', vend_addr2 = 'PO BOX 591', vend_city = 'PONCA CITY', vend_state = 'OK', vend_zip = '74601',
	vend_phone1 = '1(800)747-2372', vend_phone2 = '1(800)747-2372'

update school_info set schi_name = 'ADPC ACTIVITY FUND', schi_addr1 = '2201 N ASH', schi_city = 'PONCA CITY', schi_state = 'OK', schi_zip = '74601'
update school_info set schi_shipname = 'ADPC ACTIVITY FUND', schi_shipaddr1 = '2201 N ASH', schi_shipcity = 'PONCA CITY', schi_shipstate = 'OK', schi_shipzip = '74601'
update school_info set schi_district_id = 'I099', schi_county_id = '99'
