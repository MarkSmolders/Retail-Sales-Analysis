-- Purpose: Create clean store table with consistent city casing and added primary key
-- Date:    01/05/2026

DROP TABLE IF EXISTS dbo.store_clean;

SELECT
	ROW_NUMBER() OVER (ORDER BY store_name) AS store_id,
	store_name,
	CASE
		WHEN LOWER(city) = 'den haag' THEN 'Den Haag'
		ELSE
		CONCAT(
			UPPER(SUBSTRING(city, 1, 1)),
			LOWER(SUBSTRING(city, 2, LEN(city)))
				) 
				END AS city	,
	address,
	postal_code,
	manager_name
INTO dbo.store_clean
FROM dbo.store_raw;

ALTER TABLE dbo.store_clean
ALTER COLUMN store_id INT NOT NULL;

ALTER TABLE dbo.store_clean
ADD CONSTRAINT PK_store PRIMARY KEY (store_id);


SELECT *
FROM dbo.store_clean;