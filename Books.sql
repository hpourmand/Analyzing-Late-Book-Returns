CREATE TABLE cleaned_books AS
SELECT DISTINCT title, authors, publisher, categories, price, publishedDate, pages
FROM books;

-- Filling missing values in 'authors' and 'publisher' with 'Unknown'
UPDATE cleaned_books
SET authors = 'Unknown'
WHERE authors IS NULL;

UPDATE cleaned_books
SET publisher = 'Unknown'
WHERE publisher IS NULL;

-- The most common category
WITH most_common_category AS (
    SELECT categories
    FROM cleaned_books
    GROUP BY categories
    ORDER BY COUNT(*) DESC
    LIMIT 1
)

-- Filling missing 'categories' with the most common category
UPDATE cleaned_books
SET categories = (SELECT categories FROM most_common_category)
WHERE categories IS NULL;

-- Dropping rows with missing 'price' or 'publishedDate'
DELETE FROM cleaned_books
WHERE price IS NULL OR publishedDate IS NULL;

-- Cleaning up columns by stripping unwanted characters and whitespace using REGEXP_REPLACE for pattern-based cleaning
UPDATE cleaned_books
SET 
    title = TRIM(REGEXP_REPLACE(title, '[^\w\s]', '')),
    authors = TRIM(REGEXP_REPLACE(authors, '[^\w\s]', '')),
    publisher = TRIM(REGEXP_REPLACE(publisher, '[^\w\s]', '')),
    publishedDate = TRIM(REGEXP_REPLACE(publishedDate, '[^\w\s]', '')),
    categories = TRIM(REGEXP_REPLACE(categories, '[^\w\s]', '')),
    price = TRIM(REGEXP_REPLACE(price, '[^\w\s]', '')),
    pages = TRIM(REGEXP_REPLACE(pages, '[^\w\s]', ''));

-- Converting 'publishedDate' to the year and handle invalid dates with a check using TRY_CAST
UPDATE cleaned_books
SET publishedDate = CASE
    WHEN TRY_CAST(publishedDate AS DATE) IS NOT NULL
    THEN EXTRACT(YEAR FROM CAST(publishedDate AS DATE))
    ELSE 0
END;

-- Consolidating similar categories using a CASE statement to standardize categories
UPDATE cleaned_books
SET categories = CASE
    WHEN LOWER(categories) LIKE '%advertising%' THEN 'Advertising'
    WHEN LOWER(categories) LIKE '%mechanics%' THEN 'Mechanics'
    WHEN LOWER(categories) LIKE '%business & economics%' THEN 'Business & Economics'
    WHEN LOWER(categories) LIKE '%science%' THEN 'Science'
    WHEN LOWER(categories) LIKE '%technology%' THEN 'Technology & Engineering
