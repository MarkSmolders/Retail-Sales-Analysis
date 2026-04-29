

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

-- Add store_id column to order_clean table
ALTER TABLE dbo.order_clean
ADD store_id INT;

-- Populate the store_id column by joining the order_clean table on the store_clean table with the store names
UPDATE OC
SET OC.store_id = SC.store_id
FROM dbo.order_clean AS OC
JOIN dbo.store_clean AS SC ON OC.store_name = SC.store_name;

-- Set store_id column in order_clean table to NOT NULL for the foreign key constraint
ALTER TABLE dbo.order_clean
ALTER COLUMN store_id INT NOT NULL;

-- Added foreign key constraint to store_id in order_clean table
ALTER TABLE dbo.order_clean
ADD CONSTRAINT FK_store_id FOREIGN KEY (store_id)
REFERENCES dbo.store_clean (store_id);