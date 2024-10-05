---Display basic information
Describe customers;



---Identify duplicates
SELECT 
    id, name, street_address, city, state, zipcode, birth_date, gender, education, occupation, COUNT(*) AS count_duplicates
FROM books
GROUP BY title, authors, publisher, categories
HAVING COUNT(*) > 1;


---Remove duplicates
WITH numbered_rows AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id 
								 ORDER BY id) AS row_num
    FROM customers
)
DELETE FROM numbered_rows
WHERE row_num > 1;


---Check for missing values
SELECT 
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS missing_state,
    SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) AS missing_education,
    SUM(CASE WHEN occupation IS NULL THEN 1 ELSE 0 END) AS missing_occupation,
    SUM(CASE WHEN birth_date IS NULL THEN 1 ELSE 0 END) AS missing_birth_date
FROM customers;



---Filling missing values
UPDATE customers
SET city = COALESCE(city, 'Unknown'),
    state = COALESCE(state, 'Unknown'),
    education = COALESCE(education, 'Others'),
    occupation = COALESCE(occupation, 'Not Provided');



---Fill birth_date with the mode:
WITH ModeCTE AS (
    SELECT birth_date, COUNT(*) AS count
    FROM customers
    WHERE birth_date IS NOT NULL
    GROUP BY birth_date
    ORDER BY count DESC
    LIMIT 1
)
UPDATE customers
SET birth_date = (SELECT birth_date FROM ModeCTE)
WHERE birth_date IS NULL;



---Filter rows based on date range
DELETE FROM customers
WHERE birth_date < '1900-01-01' OR birth_date > '2020-12-29';



--- Drop rows with other missing values
DELETE FROM customers
WHERE city IS NULL
   OR state IS NULL
   OR education IS NULL
   OR occupation IS NULL
   OR birth_date IS NULL;


---Standardize column values
--Gender
UPDATE customers
SET gender = REPLACE(LOWER(gender), 'female', 'FEMALE');
UPDATE customers
SET gender = REPLACE(LOWER(gender), 'male', 'MALE');

--City
UPDATE customers
SET city = REPLACE(LOWER(city), 'portland', 'Portland');

--State
UPDATE customers
SET state = CASE
               WHEN LOWER(state) = 'oregon' THEN 'Oregon'
               WHEN LOWER(state) = 'washington' THEN 'Washington'
               ELSE state
            END;


--Education
UPDATE customers
SET education = CASE
                   WHEN education LIKE '%COLLEGE%' THEN 'College'
                   WHEN education LIKE '%SCHOOL%' THEN 'School'
                   WHEN education LIKE '%HIGH%' THEN 'High'
                   WHEN education LIKE '%GRADUATE%' THEN 'Graduate'
                   WHEN education LIKE '%DEGREE%' THEN 'Degree'
                   ELSE 'Others'
               END;


--Occupation
UPDATE customers
SET occupation = CASE
                    WHEN LOWER(occupation) LIKE '%tech%' THEN 'Tech'
                    WHEN LOWER(occupation) LIKE '%sales%' THEN 'Sales'
                    ELSE 'Others'
                 END;


---Clean up columns
UPDATE customers
SET zipcode = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM zipcode))),
    name = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM name))),
    gender = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM gender))),
    city = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM city))),
    street_address = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM street_address))),
    state = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM state))),
    birth_date = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM birth_date))),
    education = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM education))),
    occupation = TRIM(BOTH '-' FROM TRIM(BOTH '#' FROM TRIM(BOTH '_' FROM occupation)));


---Convert 'zipcode' column to integer
UPDATE customers
SET zipcode = CAST(SUBSTRING_INDEX(zipcode, '.', 1) AS UNSIGNED);


---Import Data
SELECT *
INTO OUTFILE '/path/to/cleaned_customers.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM customers;







