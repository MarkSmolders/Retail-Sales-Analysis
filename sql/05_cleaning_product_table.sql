-- Purpose: Clean product table by changing category column and choosing consistent naming and removing trailing spaces.
--
-- Note: Price and stock_quantity have some null values. This will be handled in later scripts when initial cleaning has been done
--       on all tables.
--
-- Remaining Steps to be handled in later scripts:
--  - Price and stock_quantity NULL values filled where possible from product_supplier join.
-- 
-- Date: 29/04/2026

DROP TABLE IF EXISTS dbo.product_clean

WITH table_creation AS(
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
		stock_quantity
	FROM dbo.product_raw
)
SELECT ROW_NUMBER() OVER (ORDER BY product_name) AS product_id,
	product_name,
	category,
	price,
	stock_quantity
INTO dbo.product_clean
FROM table_creation;