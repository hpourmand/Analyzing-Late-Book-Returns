CREATE TABLE cleaned_libraries AS
SELECT DISTINCT
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(name, 'MULTNOMAH', 'Multnomah'), 'OF', 'of'), 'COUNTY', 'County'), 'KENTON', 'Kenton')) AS name,
    TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(street_address, 'blvd', 'Blvd'), 'AVE', 'Ave'), 'BLVD', 'Blvd'), 'se', 'SE'), 'ne', 'NE')) AS street_address,
    TRIM(REPLACE(city, 'portland', 'Portland')) AS city,
    TRIM(REPLACE(region, 'or', 'OR')) AS region,
    COALESCE(postal_code, 'Unknown') AS postal_code
FROM libraries;

-- Updating rows to replace missing values in specific columns
WITH most_common_values AS (
    SELECT
        (SELECT MODE(city) FROM libraries WHERE city IS NOT NULL) AS most_common_city,
        (SELECT MODE(region) FROM libraries WHERE region IS NOT NULL) AS most_common_region
)
UPDATE cleaned_libraries
SET city = (SELECT most_common_city FROM most_common_values),
    region = (SELECT most_common_region FROM most_common_values);

-- Removing unwanted characters and whitespace
UPDATE cleaned_libraries
SET name = TRIM(REGEXP_REPLACE(name, '[^\w\s]', '')),
    street_address = TRIM(REGEXP_REPLACE(street_address, '[^\w\s]', '')),
    city = TRIM(REGEXP_REPLACE(city, '[^\w\s]', '')),
    region = TRIM(REGEXP_REPLACE(region, '[^\w\s]', '')),
    postal_code = TRIM(REGEXP_REPLACE(postal_code, '[^\w\s]', ''));
