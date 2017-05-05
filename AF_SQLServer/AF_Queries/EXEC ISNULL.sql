------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- aggregates can return a NULL value, the ISNULL will replace null with a value;
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- summarizing with ISNULL;
SELECT ISNULL(SUM(tran_amt), 0) FROM transactions WHERE bank_acct_num = 'BAD ACCOUNT'

-- summarizing without ISNULL;
SELECT SUM(tran_amt) FROM transactions WHERE bank_acct_num = 'BAD ACCOUNT'
