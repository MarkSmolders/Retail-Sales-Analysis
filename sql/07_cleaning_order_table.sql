-- Purpose: Cleaning the order table by standardising the date values to 'YYYY-MM-DD' format 
--          and standardising the status column values.
--
-- Notes: order_raw was regenerated with proper customer_id references (1-600) matching
--        customer_clean, reflecting how real order systems reference customers by ID.
--        Store_name is standardised and set to 'Unknown' where missing.
--        Date formats found in source data: DD/MM/YYYY, written out (e.g. '21 January 2024'),
--        DD-MM-YYYY, and YYYY-DD-MM. All standardised to YYYY-MM-DD and converted to DATE type.
--
-- Remaining steps handled in later scripts:
--        - order_id generated as IDENTITY primary key after initial table creation
--        - customer_id foreign key constraint added referencing customer_clean
--        - store_id foreign key added by joining to store_clean on store_name
--        - store_name dropped after store_id is populated
--
-- Date: 01/05/2026

DROP TABLE IF EXISTS dbo.order_clean;


-- Create clean order table with standardised status values
SELECT
    order_reference,
    customer_id,
    order_date,
    store_name,
    CASE 
		WHEN LOWER(status) = 'completed' THEN 'Completed'
		WHEN LOWER(status) = 'shipped' THEN 'Shipped'
		WHEN LOWER(status) = 'pending' THEN 'Pending'
		WHEN LOWER(status) = 'cancelled' THEN 'Cancelled'
		ELSE status 
	END AS status,
    total_amount
INTO dbo.order_clean
FROM dbo.order_raw;

-- Add order_id row
ALTER TABLE dbo.order_clean
ADD order_id INT IDENTITY(1,1) NOT NULL;

-- Add primary key constraint to order_id
ALTER TABLE dbo.order_clean
ADD CONSTRAINT PK_order_id PRIMARY KEY (order_id);

-- Convert European format DD/MM/YYYY to ISO YYYY-MM-DD
UPDATE dbo.order_clean
SET order_date = CONVERT(NVARCHAR, CONVERT(DATE, order_date, 103), 120)
WHERE order_date LIKE '__/__/____';

-- Add helper columns to handle written out dates
ALTER TABLE dbo.order_clean
ADD Day_part NVARCHAR(10),
    Month_name NVARCHAR(20),
    Year_part NVARCHAR(10);

-- Extract day, month name and year from written out dates
UPDATE dbo.order_clean
SET Day_part = SUBSTRING(order_date, 0, CHARINDEX(' ', order_date)),
	Month_name = SUBSTRING(
		order_date, 
		CHARINDEX(' ', order_date) + 1,
		CHARINDEX(' ', order_date, CHARINDEX(' ', order_date) + 1) - CHARINDEX(' ', order_date) - 1),
	Year_part = SUBSTRING(
		order_date, 
		CHARINDEX(' ', order_date, CHARINDEX(' ', order_date) + 1) + 1,
		4)
WHERE CHARINDEX(' ', order_date) > 0;

-- Convert month names to two digit numbers
UPDATE dbo.order_clean
SET Month_name = 
    CASE 
        WHEN Month_name = 'January'   THEN '01'
        WHEN Month_name = 'February'  THEN '02'
        WHEN Month_name = 'March'     THEN '03'
        WHEN Month_name = 'April'     THEN '04'
        WHEN Month_name = 'May'       THEN '05'
        WHEN Month_name = 'June'      THEN '06'
        WHEN Month_name = 'July'      THEN '07'
        WHEN Month_name = 'August'    THEN '08'
        WHEN Month_name = 'September' THEN '09'
        WHEN Month_name = 'October'   THEN '10'
        WHEN Month_name = 'November'  THEN '11'
        WHEN Month_name = 'December'  THEN '12'
    END
WHERE Month_name IS NOT NULL;

-- Reassemble written out dates into YYYY-MM-DD format
UPDATE dbo.order_clean
SET order_date = Year_part + '-' + Month_name + '-' + Day_part
WHERE CHARINDEX(' ', order_date) > 0;

-- Drop helper columns after conversion is complete
ALTER TABLE dbo.order_clean
DROP COLUMN Day_part, Month_name, Year_part;

-- Convert hyphen separated DD-MM-YYYY format to ISO YYYY-MM-DD
UPDATE dbo.order_clean
SET order_date = SUBSTRING(order_date, 7, 4) + '-' + SUBSTRING(order_date, 4, 2) + '-' + SUBSTRING(order_date, 1, 2)
WHERE order_date LIKE '__-__-____';

-- Setting missing store_names to unknown
UPDATE dbo.order_clean
SET store_name = 'Unknown'
WHERE store_name IS NULL;

-- Updating YYYY-DD-MM format to YYYY-MM-DD format
UPDATE dbo.order_clean
SET order_date = SUBSTRING(order_date, 1, 5) + SUBSTRING(order_date, 9, 2) + '-' + SUBSTRING(order_date, 6, 2)
WHERE TRY_CONVERT(DATE, order_date) IS NULL;

-- Changing column datatype to DATE
ALTER TABLE dbo.order_clean
ALTER COLUMN order_date DATE;