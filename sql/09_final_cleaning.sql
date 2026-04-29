--Purpose: Finalise cleaning by adding derived average price to the price in the order_item table and dropping redundant columns.
--
-- Notes: To keep the integrity of the data, missing prices are derived from the average unit price per product in order_item_clean
--        Line totals are recalculated after all prices are filled. 
--        product_name is kept until product_id is added as a foreign key in a later step.
--
-- Date: 29/04/2026


-- Calculated average price per item from the order_item table for the missing prices in the product_table
WITH avg_prices AS (
    SELECT product_name, AVG(unit_price) AS avg_price
    FROM dbo.order_item_clean
    WHERE unit_price IS NOT NULL
    GROUP BY product_name
)
UPDATE PC
SET PC.price = AP.avg_price
FROM dbo.product_clean AS PC
JOIN avg_prices AS AP ON PC.product_name = AP.product_name
WHERE PC.price IS NULL;

-- Updated order_item_clean table with the average prices added
UPDATE OIC
SET OIC.unit_price = PC.price
FROM dbo.order_item_clean as OIC
JOIN dbo.product_clean AS PC on OIC.product_name = PC.product_name
WHERE unit_price IS NULL;

-- Recalculates the line totals in the order_item_clean table with the average prices
UPDATE dbo.order_item_clean
SET line_total = quantity * unit_price
WHERE quantity IS NOT NULL AND unit_price IS NOT NULL;

-- Drops the order_reference column from the order_item_clean table since the primary key has been added already making this redundant
ALTER TABLE dbo.order_item_clean
DROP COLUMN order_reference;
