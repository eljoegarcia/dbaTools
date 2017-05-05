
-- update the expenditure descriptions with the dim5 object description
UPDATE ocas_exp
SET ocex_descr = dimx5_descr
FROM dimx5, ocas_exp
WHERE dimx5_value = ocex_dim5
AND ocex_fisyr = 2004
AND dimx5_fisyr = 2004

-- update the revenue descriptions with the dim4 source description
UPDATE ocas_rev
SET ocrv_descr = dimr4_descr
FROM dimr4, ocas_rev
WHERE dimr4_value = ocrv_dim4
AND ocrv_fisyr = 2004
AND dimr4_fisyr = 2004
