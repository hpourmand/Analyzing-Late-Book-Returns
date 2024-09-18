CREATE TABLE cleaned_checkouts AS
SELECT DISTINCT
    id,
    patron_id,
    library_id,
    date_checkout,
    date_returned
FROM checkouts;

-- Finding and removing duplicate rows across all columns
WITH cte AS (
    SELECT id, patron_id, library_id, date_checkout, date_returned,
           ROW_NUMBER() OVER (PARTITION BY id, patron_id, library_id, date_checkout, date_returned ORDER BY id) AS row_num
    FROM cleaned_checkouts
)
DELETE FROM cleaned_checkouts
WHERE id IN (
    SELECT id FROM cte WHERE row_num > 1
);

-- Checking missing values
SELECT 
    COUNT(*) AS total_rows,
    COUNT(date_checkout) AS valid_date_checkout,
    COUNT(date_returned) AS valid_date_returned,
    (COUNT(*) - COUNT(date_checkout)) AS missing_date_checkout,
    (COUNT(*) - COUNT(date_returned)) AS missing_date_returned
FROM cleaned_checkouts;

-- Removing rows with missing values
DELETE FROM cleaned_checkouts
WHERE date_checkout IS NULL OR date_returned IS NULL;

-- Filtering by date range
DELETE FROM cleaned_checkouts
WHERE date_checkout < '2017-01-01' 
OR date_checkout > '2020-12-24'
OR date_returned < '2017-01-01' 
OR date_returned > '2020-12-24';

-- Ensuring date_checkout is before date_returned
DELETE FROM cleaned_checkouts
WHERE date_checkout >= date_returned;

-- Cleaning up the columns
UPDATE cleaned_checkouts
SET 
    id = TRIM(REPLACE(id, '/', '-')),
    patron_id = TRIM(REPLACE(patron_id, '/', '-')),
    library_id = TRIM(REPLACE(library_id, '/', '-')),
    date_checkout = TRIM(REPLACE(date_checkout, '/', '-')),
    date_returned = TRIM(REPLACE(date_returned, '/', '-'));

-- Converting data formats
UPDATE cleaned_checkouts
SET date_checkout = TO_CHAR(TO_DATE(date_checkout, 'YYYY-MM-DD'), 'YYYY-MM-DD'),
    date_returned = TO_CHAR(TO_DATE(date_returned, 'YYYY-MM-DD'), 'YYYY-MM-DD');
