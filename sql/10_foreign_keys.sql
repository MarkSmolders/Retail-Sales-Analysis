-- Purpose: Finalise relational structure by adding foreign key constraints and populating
--          ID-based references to replace name-based columns.
--
-- Notes: An 'Unknown' store is inserted into store_clean to preserve transactional data
--        where store_name was missing in order_clean. store_name and product_name are 
--        dropped after their respective ID foreign keys are populated.
--        order_item_clean has no order_id link to order_clean due to a limitation in 
--        the source data — no order reference was present in the raw order item data.
--
-- Date: 29/04/2026

-- Insert value for unknown store name so no transactional data gets lost and foreign key can be populated
INSERT INTO dbo.store_clean (store_id, store_name, city, address, postal_code, manager_name)
VALUES ((SELECT MAX(store_id) + 1 FROM dbo.store_clean), 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown');

-- Add empty store_id column to order_clean
ALTER TABLE order_clean
ADD store_id INT NULL;

-- Populate store_id by matching store_name to store_clean
UPDATE OC 
SET OC.store_id = SC.store_id
FROM dbo.order_clean AS OC
JOIN dbo.store_clean AS  SC ON SC.store_name = OC.store_name;

-- Enforce NOT NULL now that all rows have a valid store_id
ALTER TABLE dbo.order_clean
ALTER COLUMN store_id INT NOT NULL;

-- Add foreign key constraint linking order_clean to store_clean
ALTER TABLE dbo.order_clean
ADD CONSTRAINT FK_store_id FOREIGN KEY (store_id)
REFERENCES dbo.store_clean (store_id);

-- Drop store_name as it is now replaced by store_id
ALTER TABLE dbo.order_clean
DROP COLUMN store_name;

-- Added Foreign key constraint to customer_id in order_clean table
ALTER TABLE dbo.order_clean
ADD CONSTRAINT FK_customer_id FOREIGN KEY (customer_id)
REFERENCES dbo.customer_clean (customer_id);

-- Added product_id column to order_item_clean table
ALTER TABLE dbo.order_item_clean
ADD product_id INT;

-- Populated product_id in order_item_clean table by joining the product_clean table on the product_name
UPDATE OIC
SET OIC.product_id = PC.product_id
FROM dbo.order_item_clean AS OIC
JOIN dbo.product_clean AS PC ON OIC.product_name = PC.product_name;

-- Drops product_name column from order_item_clean table as it is redundant after the product id foreign key addition
ALTER TABLE dbo.order_item_clean
DROP COLUMN product_name;

-- Alters the product_id column in order_item_clean table for the foreign key constraint
ALTER TABLE dbo.order_item_clean
ALTER COLUMN product_id INT NOT NULL;

-- Added foreign key constraint to product_id in the order_item_clean table
ALTER TABLE dbo.order_item_clean
ADD CONSTRAINT FK_product_id FOREIGN KEY (product_id)
REFERENCES dbo.product_clean (product_id);