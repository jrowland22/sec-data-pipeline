use logs;

-- 10 most requested form
SELECT form, COUNT(form) form_count 
FROM forms 
GROUP BY form, access_date 
ORDER BY form_count DESC 
LIMIT 10; 

-- 10 most requested companies
SELECT name, COUNT(*) comp_count 
FROM companies 
GROUP BY cik, access_date
ORDER BY comp_count DESC 
LIMIT 10;

-- 10 most requested filing
SELECT name,accession,form,COUNT(*) as v 
FROM companies
GROUP BY accession,access_date
ORDER BY v DESC 
LIMIT 10;