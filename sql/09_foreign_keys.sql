-- Purpose: Finalise relational structure by adding foreign key constraints and populating
--          ID-based references to replace name-based columns.
--
-- Notes: An 'Unknown' store is inserted into store_clean to preserve transactional data
--        where store_name was missing in order_clean. store_name and product_name are 
--        dropped after their respective ID foreign keys are populated.
--        order_id is populated in order_item_clean by joining on order_reference,
--        which is then dropped after the foreign key is added.
--
-- Date: 01/05/2026

-- Insert value for unknown store name so no transactional data gets lost and foreign key can be populated
INSERT INTO dbo.store_clean
    (store_id, store_name, city, address, postal_code, manager_name)
VALUES
    ((SELECT MAX(store_id) + 1
        FROM dbo.store_clean), 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown');

-- Add empty store_id column to order_clean
ALTER TABLE dbo.order_clean
ADD store_id INT NULL;
GO

-- Populate store_id by matching store_name to store_clean
UPDATE OC 
SET OC.store_id = SC.store_id
FROM dbo.order_clean AS OC
    JOIN dbo.store_clean AS SC ON SC.store_name = OC.store_name;

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

-- Added foreign key constraint to customer_id in order_clean table
ALTER TABLE dbo.order_clean
ADD CONSTRAINT FK_customer_id FOREIGN KEY (customer_id)
REFERENCES dbo.customer_clean (customer_id);

-- Added product_id column to order_item_clean table
ALTER TABLE dbo.order_item_clean
ADD product_id INT;
GO

-- Populated product_id in order_item_clean table by joining the product_clean table on the product_name
UPDATE OIC
SET OIC.product_id = PC.product_id
FROM dbo.order_item_clean AS OIC
    JOIN dbo.product_clean AS PC ON OIC.product_name = PC.product_name;

-- Drops product_name column from order_item_clean table as it is redundant after the product_id foreign key addition
ALTER TABLE dbo.order_item_clean
DROP COLUMN product_name;

-- Alters the product_id column in order_item_clean table for the foreign key constraint
ALTER TABLE dbo.order_item_clean
ALTER COLUMN product_id INT NOT NULL;

-- Added foreign key constraint to product_id in the order_item_clean table
ALTER TABLE dbo.order_item_clean
ADD CONSTRAINT FK_product_id FOREIGN KEY (product_id)
REFERENCES dbo.product_clean (product_id);

-- Add order_id column to order_item_clean
ALTER TABLE dbo.order_item_clean
ADD order_id INT;
GO

-- Populate order_id by matching order_reference to order_clean
UPDATE OIC
SET OIC.order_id = OC.order_id
FROM dbo.order_item_clean AS OIC
    JOIN dbo.order_clean AS OC ON OIC.order_reference = OC.order_reference;

-- Drop order_reference as it is now replaced by order_id
ALTER TABLE dbo.order_item_clean
DROP COLUMN order_reference;

-- Alter order_id to NOT NULL for foreign key constraint
ALTER TABLE dbo.order_item_clean
ALTER COLUMN order_id INT NOT NULL;

-- Add foreign key constraint linking order_item_clean to order_clean
ALTER TABLE dbo.order_item_clean
ADD CONSTRAINT FK_order_id FOREIGN KEY (order_id)
REFERENCES dbo.order_clean (order_id);