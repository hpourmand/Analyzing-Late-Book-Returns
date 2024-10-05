---Display basic information
DESCRIBE books;


---Identify Duplicates
SELECT 
    title, authors, publisher, categories, COUNT(*) AS count_duplicates
FROM books
GROUP BY title, authors, publisher, categories
HAVING COUNT(*) > 1;


---Remove Duplicates
WITH numbered_rows AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY title, authors, publisher, categories 
               ORDER BY book_id 
           ) AS row_num
    FROM books
)
DELETE FROM numbered_rows
 WHERE row_num > 1;

---Check for missing values
SELECT 
    SUM(CASE WHEN authors IS NULL THEN 1 ELSE 0 END) AS missing_authors,
    SUM(CASE WHEN publisher IS NULL THEN 1 ELSE 0 END) AS missing_publisher,
    SUM(CASE WHEN categories IS NULL THEN 1 ELSE 0 END) AS missing_categories,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN publishedDate IS NULL THEN 1 ELSE 0 END) AS missing_publishedDate
FROM books;


---Fill missing values
UPDATE books
SET authors = COALESCE(authors, 'Unknown'),
    publisher = COALESCE(publisher, 'Unknown');

---Fill missing categories with the most common category
WITH most_common AS (
    SELECT categories
    FROM books
    WHERE categories IS NOT NULL
    GROUP BY categories
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UPDATE books
SET categories = (SELECT categories FROM most_common)
WHERE categories IS NULL;

--Drop rows where price or publishedDate is NULL
DELETE FROM books
WHERE price IS NULL OR publishedDate IS NULL;


---Clean up columns
UPDATE books
SET title = TRIM(BOTH ' USD*$^#|' FROM title),
    authors = TRIM(BOTH ' USD*$^#|' FROM authors),
    publisher = TRIM(BOTH ' USD*$^#|' FROM publisher),
    publishedDate = TRIM(BOTH ' USD*$^#|' FROM publishedDate),
    categories = TRIM(BOTH ' USD*$^#|' FROM categories),
    price = TRIM(BOTH ' USD*$^#|' FROM price),
    pages = TRIM(BOTH ' USD*$^#|' FROM pages);


---Convert 'publishedDate' to year and remove rows with 0 year
UPDATE books
SET publishedDate = YEAR(STR_TO_DATE(publishedDate, '%Y-%m-%d'))
WHERE publishedDate IS NOT NULL;

DELETE FROM books
WHERE publishedDate = 0;


---Consolidate categories
UPDATE books
SET categories = CASE
    WHEN LOWER(categories) LIKE '%advertising%' THEN 'Advertising'
    WHEN LOWER(categories) LIKE '%mechanics%' THEN 'Mechanics'
    WHEN LOWER(categories) LIKE '%business & economics%' THEN 'Business & Economics'
    WHEN LOWER(categories) LIKE '%science%' THEN 'Science'
    WHEN LOWER(categories) LIKE '%technology%' THEN 'Technology & Engineering'
    WHEN LOWER(categories) LIKE '%engineering%' THEN 'Technology & Engineering'
    WHEN LOWER(categories) LIKE '%mathematics%' THEN 'Mathematics'
    WHEN LOWER(categories) LIKE '%social science%' THEN 'Social Science'
    WHEN LOWER(categories) LIKE '%psychology%' THEN 'Psychology'
    WHEN LOWER(categories) LIKE '%political science%' THEN 'Political Science'
    WHEN LOWER(categories) LIKE '%art%' THEN 'Art'
    WHEN LOWER(categories) LIKE '%language arts%' THEN 'Language Arts & Disciplines'
    WHEN LOWER(categories) LIKE '%government publications%' THEN 'Government Publications'
    WHEN LOWER(categories) LIKE '%fiction%' THEN 'Fiction'
    ELSE 'Uncategorized'
END;



---Export data
SELECT *
INTO OUTFILE '/path/to/cleaned_books.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM books;

