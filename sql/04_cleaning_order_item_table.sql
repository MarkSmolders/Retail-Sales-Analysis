-- Purpose: Clean order_item table by standardising and recalculating line_total, 
--          handling missing values and creating a primary key.
--
-- Notes: order_raw was regenerated to include a valid order_reference column (ORD_0001-ORD_1200)
--        linking each order item to its parent order. Previously, order_reference contained a mix 
--        of ORD_ codes and customer names — this has been fixed in the source data.
--        line_total is recalculated from quantity and unit_price to correct inconsistencies 
--        found during EDA. Missing quantity values are derived where possible from line_total 
--        and unit_price.
--
-- Remaining steps handled in later scripts:
--        - NULL unit_price filled from product_clean via average price calculation
--        - product_id foreign key added by joining to product_clean on product_name
--        - order_id foreign key added by joining to order_clean on order_reference
--        - product_name and order_reference dropped after foreign keys are populated
--
-- Date: 22/04/2026

DROP TABLE IF EXISTS dbo.order_item_clean;

-- Create clean order_item table
SELECT
    ROW_NUMBER() OVER (ORDER BY order_reference) AS order_item_id,
    order_reference,
    product_name,
    quantity,
    unit_price,
    line_total
INTO dbo.order_item_clean
FROM dbo.order_item_raw;

-- Set order_item_id to NOT NULL for primary key constraint
ALTER TABLE dbo.order_item_clean
ALTER COLUMN order_item_id INT NOT NULL;

-- Add primary key constraint
ALTER TABLE dbo.order_item_clean
ADD CONSTRAINT PK_order_item_id PRIMARY KEY (order_item_id);

-- Recalculate line_total where values were incorrect
UPDATE dbo.order_item_clean
SET line_total = (quantity * unit_price)
WHERE (quantity * unit_price) != line_total
    AND quantity IS NOT NULL
    AND unit_price IS NOT NULL;

-- Derive missing quantity values from line_total and unit_price where possible
UPDATE dbo.order_item_clean
SET quantity = (line_total / unit_price)
WHERE quantity IS NULL
    AND unit_price IS NOT NULL
    AND line_total IS NOT NULL;