
SELECT chks_fisyr, ocex_code, SUM(chks_amount) 
FROM chks_info AS ci, chks_detl AS cd 
WHERE ci.chks_autoinc_key = cd.chks_autoinc_key AND chks_fisyr = 2005
AND ci.chks_status = 'C' 
GROUP BY chks_fisyr, ocex_code 

UNION 

SELECT tran_fisyr, ocex_code, SUM(tran_amt) 
FROM transactions 
WHERE tran_fisyr = 2005 AND tran_type = 'E' 
GROUP BY tran_fisyr, ocex_code 
--ORDER BY tran_fisyr, ocex_code

UNION

SELECT tran_fisyr, ocex_code, SUM(tran_amt) 
FROM transactions 
WHERE tran_fisyr = 2005 AND tran_type = 'B' 
GROUP BY tran_fisyr, ocex_code 
ORDER BY ocex_code

