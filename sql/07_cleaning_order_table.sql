-- Purpose: Cleaning the order table by standardising the date values to 'YYYY-MM-DD' format and standardising the status column.
--
-- Note: order_raw originally referenced customers by name instead of customer_id.
--       Data was regenerated with proper customer_id foreign key references (1-600)
--       matching the cleaned customer_clean table. This reflects how real order systems
--       reference customers — by ID generated at registration, not by name.
--
-- Remaining steps to be handled in later scripts
--	- Order_ID generated after all cleaning is handled
--	- Customer_id foreign key added by joining to customer_clean on customer_name
--	- Store_id foreign key added by joining to store_clean on store_name
--	- Customer_name and store_name dropped after foreign keys are populated
-- Date: 25/04/2026
DROP TABLE IF EXISTS dbo.order_clean


-- Create clean order table with standardised status values
SELECT
    customer_id,
    order_date,
    store_name,
    CASE 
		WHEN LOWER(status) = 'completed' THEN 'Completed'
		WHEN LOWER(status) = 'shipped' THEN 'Shipped'
		WHEN LOWER(status) = 'pending' THEN 'Pending'
		WHEN LOWER(status) = 'cancelled' THEN 'Cancelled'
		ELSE status 
	END AS status 
		total_amount
INTO dbo.order_clean
FROM dbo.order_raw;

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