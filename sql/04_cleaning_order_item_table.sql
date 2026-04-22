-- Purpose: Clean order_item table by recalculating line_total, handling missing ORD_codes and creating a primary key.

-- Note: order_reference contained a mix of ORD_ codes and customer names. 
--       Customer name references were excluded as they cannot be reliably linked to a specific order. 
--       In a real scenario I would raise this issue with the person responsible of the data source system or data engineer.
--       In this case I created the primary key based on the ORD_codes and dropped the other rows.
--
-- Remaining Steps to be handled in later scripts:
--  - Foreign keys added after dimension tables are finalised.
--  - NULL unit_price filled from product_clean via foreign key join.
--  - Dropping redundant columns when foreign keys have been added.
-- Date: 22/04/2026
--
DROP TABLE IF EXISTS dbo.order_item_clean

SELECT
    ROW_NUMBER() OVER (ORDER BY order_reference) AS order_item_id,
    order_reference,
    product_name,
    quantity,
    unit_price,
    line_total
INTO dbo.order_item_clean
FROM dbo.order_item_raw
WHERE LEFT(order_reference, 3) = 'ORD';

-- Recalculating the line_total since incorrect values were discovered in the EDA.
UPDATE 
	dbo.order_item_clean
SET line_total = (quantity * unit_price)
WHERE (quantity * unit_price) != line_total AND quantity IS NOT NULL AND unit_price IS NOT NULL;

ALTER TABLE dbo.order_item_clean
ALTER COLUMN order_item_id INT NOT NULL;

ALTER TABLE dbo.order_item_clean
ADD CONSTRAINT PK_order_item_id PRIMARY KEY (order_item_id);

UPDATE
	dbo.order_item_clean
SET quantity = (line_total / unit_price)
WHERE quantity IS NULL AND unit_price IS NOT NULL and line_total IS NOT NULL;