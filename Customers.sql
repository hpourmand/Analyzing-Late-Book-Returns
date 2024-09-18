CREATE TEMPORARY TABLE temp_customers AS
SELECT *
FROM customers;

-- Dropping duplicates
DELETE FROM temp_customers
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM temp_customers
    GROUP BY -- List all columns that you consider as duplicates
    city, state, education, occupation, birth_date
);

-- Filling missing values
UPDATE temp_customers
SET city = COALESCE(city, 'Unknown'),
    state = COALESCE(state, 'Unknown'),
    education = COALESCE(education, 'Others'),
    occupation = COALESCE(occupation, 'Not Provided'),
    birth_date = COALESCE(birth_date, (SELECT MAX(birth_date) FROM temp_customers)); -- Use MAX or another suitable method

-- Filtering dates
DELETE FROM temp_customers
WHERE birth_date < '1900-01-01' OR birth_date > '2020-12-29';

-- Dropping rows with other missing values
DELETE FROM temp_customers
WHERE city IS NULL
   OR state IS NULL
   OR education IS NULL
   OR occupation IS NULL
   OR birth_date IS NULL;

-- Standardizing values in columns
UPDATE temp_customers
SET gender = CASE
                 WHEN LOWER(gender) = 'female' THEN 'FEMALE'
                 WHEN LOWER(gender) = 'male' THEN 'MALE'
                 ELSE gender
             END,
    city = CASE
               WHEN UPPER(city) = 'PORTLAND' THEN 'Portland'
               ELSE city
           END,
    state = CASE
                WHEN UPPER(state) = 'OREGON' THEN 'Oregon'
                WHEN LOWER(state) = 'washington' THEN 'Washington'
                ELSE state
            END,
    education = CASE
                    WHEN UPPER(education) IN ('COLLEGE', 'SCHOOL', 'HIGH', 'GRADUATE', 'DEGREE') THEN 'Graduate'
                    ELSE education
                END,
    occupation = CASE
                    WHEN UPPER(occupation) IN ('TECH', 'COLLAR', 'SUPPORT', 'ADMIN', 'BLUE', 'FINANCE', 'EDUCATION', 'SALES') THEN 'Sales'
                    ELSE occupation
                 END;

-- Cleaning up columns by stripping unwanted characters and whitespace
UPDATE temp_customers
SET zipcode = TRIM(REPLACE(zipcode, '.', '')),
    name = TRIM(REPLACE(name, '_#-', '')),
    gender = TRIM(REPLACE(gender, '_#-', '')),
    city = TRIM(REPLACE(city, '_#-', '')),
    street_address = TRIM(REPLACE(street_address, '_#-', '')),
    state = TRIM(REPLACE(state, '_#-', '')),
    birth_date = TRIM(REPLACE(birth_date, '_#-', '')),
    education = TRIM(REPLACE(education, '_#-', '')),
    occupation = TRIM(REPLACE(occupation, '_#-', ''));

-- Saving cleaned data back to a table
CREATE TABLE cleaned_customers AS
SELECT *
FROM temp_customers;
