-- Purpose: Clean the customer table by standardising country column, deduplicating and creating a customer_id primary key
-- Date: 01/05/2026

DROP TABLE IF EXISTS dbo.customer_clean;

WITH
    deduped
    AS
    (
        SELECT DISTINCT
            first_name,
            last_name,
            email,
            phone,
            city,
            CASE
            WHEN LOWER(country) = 'nl'              THEN 'Netherlands'
            WHEN LOWER(country) = 'nederland'        THEN 'Netherlands'
            WHEN LOWER(country) = 'nld'              THEN 'Netherlands'
            WHEN LOWER(country) = 'the netherlands'  THEN 'Netherlands'
            WHEN LOWER(country) = 'netherlands'      THEN 'Netherlands'
            ELSE country
        END AS country,
            date_of_birth
        FROM dbo.customer_raw
    )
SELECT
    ROW_NUMBER() OVER (ORDER BY first_name, last_name) AS customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    date_of_birth
INTO dbo.customer_clean
FROM deduped;

ALTER TABLE dbo.customer_clean
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE dbo.customer_clean
ADD CONSTRAINT PK_customer PRIMARY KEY (customer_id);