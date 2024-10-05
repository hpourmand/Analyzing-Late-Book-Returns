---Display basic information
Describe checkouts;

---Identify duplicates
SELECT id, patron_id, library_id, date_checkout, date_returned, COUNT(*) AS duplicate_count
FROM checkouts
GROUP BY id, patron_id, library_id, date_checkout, date_returned
HAVING COUNT(*) > 1;


---Remove duplicates
WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY id, patron_id, library_id, date_checkout, date_returned 
                              ORDER BY (SELECT NULL)) AS row_num
    FROM checkouts
)
DELETE FROM checkouts
WHERE id IN (SELECT id FROM CTE WHERE row_num > 1);


---Check for missing values
SELECT 
    SUM(CASE WHEN date_checkout IS NULL THEN 1 ELSE 0 END) AS missing_date_checkout,
    SUM(CASE WHEN date_returned IS NULL THEN 1 ELSE 0 END) AS missing_date_returned
FROM checkouts;


---Remove rows where date_checkout or date_returned is NULL
DELETE FROM checkouts
WHERE date_checkout IS NULL OR date_returned IS NULL;


---Filter rows based on a date range
DELETE FROM checkouts
WHERE date_checkout < '2017-01-01' 
   OR date_checkout > '2020-12-24'
   OR date_returned < '2017-01-01'
   OR date_returned > '2020-12-24';


---Ensure 'date_checkout' is before 'date_returned'
DELETE FROM checkouts
WHERE date_checkout >= date_returned;



---Clean up columns
UPDATE checkouts
SET id = TRIM(BOTH '-' FROM REPLACE(REPLACE(REPLACE(id, '|', '-'), '/', '-'), ' ', '-')),
    patron_id = TRIM(BOTH '-' FROM REPLACE(REPLACE(REPLACE(patron_id, '|', '-'), '/', '-'), ' ', '-')),
    library_id = TRIM(BOTH '-' FROM REPLACE(REPLACE(REPLACE(library_id, '|', '-'), '/', '-'), ' ', '-')),
    date_checkout = TRIM(BOTH '-' FROM REPLACE(REPLACE(REPLACE(date_checkout, '|', '-'), '/', '-'), ' ', '-')),
    date_returned = TRIM(BOTH '-' FROM REPLACE(REPLACE(REPLACE(date_returned, '|', '-'), '/', '-'), ' ', '-'));



---Convert 'date_checkout' and 'date_returned' to datetime format
UPDATE checkouts
SET date_checkout = COALESCE(DATE_FORMAT(STR_TO_DATE(date_checkout, '%Y-%m-%d'), '%Y-%m-%d'), ''),
    date_returned = COALESCE(DATE_FORMAT(STR_TO_DATE(date_returned, '%Y-%m-%d'), '%Y-%m-%d'), '');



---Export data
SELECT *
INTO OUTFILE '/path/to/cleaned_checkouts.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM checkouts;
