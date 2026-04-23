-- Purpose: Clean product table by changing category column and choosing consistent naming and removing trailing spaces.
--
-- Note: Price and stock_quantity have some null values. This will be handled in later scripts when initial cleaning has been done
--       on all tables. Some products have duplicate entries with different suppliers, this will also be handled in later scripts.
--
-- Remaining Steps to be handled in later scripts:
--  - Foreign keys added for the supplier_table which can then be dropped.
--  - Price and stock_quantity NULL values filled where possible from product_supplier join.
--  - product_id generated with ROW_NUMBER() after deduplication is finalised.
-- 
-- Date: 23/04/2026

DROP TABLE IF EXISTS dbo.product_clean

SELECT
    DISTINCT TRIM(product_name) AS product_name,
    CASE
	WHEN category = 'electronic' THEN 'Electronics'
	WHEN category = 'electronics' THEN 'Electronics'
	WHEN category = 'Elektronica' THEN 'Electronics'
	WHEN category = 'clothes' THEN 'Clothes'
	WHEN category = 'clothing' THEN 'Clothes'
	WHEN LOWER(category) = 'food' THEN 'Foods'
	WHEN category = 'Voedsel' THEN 'Foods'
	WHEN category = 'Schoonheid' THEN 'Personal Care'
	WHEN category = 'Sporting Goods' THEN 'Sports'		
	WHEN LOWER(category) = 'sport' THEN 'Sports'
	WHEN LOWER(category) = 'sports' THEN 'Sports'
	WHEN category = 'Home & Living' THEN 'Home'
	WHEN category = 'Wonen' THEN 'Home'
	WHEN category = 'home' THEN 'Home'
	WHEN category = 'Kleding' THEN 'Clothes'
	WHEN category = 'beauty' THEN 'Personal Care'
	ELSE category
		END AS category,
    price,
    supplier,
    stock_quantity
INTO dbo.product_clean
FROM dbo.product_raw;