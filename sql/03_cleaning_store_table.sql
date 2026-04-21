-- Purpose: Create clean store table with consistent city casing
-- Date:    21/04/2026

SELECT
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