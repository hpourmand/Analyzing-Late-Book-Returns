---Display basic information
Describe libraries

---Identify duplicates
SELECT 
    id, name, street_address, city, region, postal_code COUNT(*) AS count_duplicates
FROM books
GROUP BY title, authors, publisher, categories
HAVING COUNT(*) > 1;

---Remove duplicates
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY name, street_address, city, region, postal_code ORDER BY name) AS row_num
    FROM libraries
)
DELETE FROM libraries
WHERE row_num > 1;



---Check for missing values 
SELECT 
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS missing_postal_code
FROM libraries;


---Filling missing values
--Fill city and region with the mode
WITH ModeCity AS (
    SELECT city
    FROM libraries
    WHERE city IS NOT NULL
    GROUP BY city
    ORDER BY COUNT(*) DESC
    LIMIT 1
),
ModeRegion AS (
    SELECT region
    FROM libraries
    WHERE region IS NOT NULL
    GROUP BY region
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UPDATE libraries
SET city = (SELECT city FROM ModeCity)
WHERE city IS NULL;

UPDATE libraries
SET region = (SELECT region FROM ModeRegion)
WHERE region IS NULL;


--Fill postal_code with "Unkown"
UPDATE libraries
SET postal_code = COALESCE(postal_code, 'Unknown');



---Standardize column values 
--Name
UPDATE libraries
SET name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(name), 'multnomah', 'Multnomah'), 'of', 'of'), 'county', 'County'), 'kenton', 'Kenton'), 'midland', 'Midland');

--Street_address
UPDATE libraries
SET street_address = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(street_address), 'blvd', 'Blvd'), 'ave', 'Ave'), 'blvd', 'Blvd'), 'se', 'SE'), 'ne', 'NE'), 'st', 'St');

--City
UPDATE libraries
SET city = REPLACE(REPLACE(LOWER(city), 'portland', 'Portland'), 'PORTLAND', 'Portland');

--Region
UPDATE libraries
SET region = REPLACE(LOWER(region), 'or', 'OR');

---Clean up columns
UPDATE libraries
SET name = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM name))),
    street_address = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM street_address))),
    city = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM city))),
    region = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM region))),
    postal_code = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM postal_code)));

							 
---Export Data
SELECT * 
INTO OUTFILE '/path/to/cleaned_libraries.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM libraries;

						
