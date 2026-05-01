
--None of the fact tables include the supplier id making this redundant for the star schema
DROP TABLE dbo.supplier_clean;

-- Table existence check
DROP TABLE IF EXISTS dbo.dim_date

-- The declare statements need to be run with the CTE in one batch
DECLARE @start_date DATE = (SELECT MIN(order_date)
FROM dbo.order_clean);
DECLARE @end_date DATE = (SELECT MAX(order_date)
FROM dbo.order_clean);

-- dim_date table creation based on the earliest and latest date in the order_clean table. Also added date_id
WITH
    date_series
    AS
    (
                    SELECT @start_date AS date
        UNION ALL

            SELECT DATEADD(day, 1, date)
            FROM date_series
            WHERE date < @end_date
    )
SELECT
    ROW_NUMBER() OVER (ORDER BY date) AS date_id,
    date
INTO dbo.dim_date
FROM date_series
OPTION
(MAXRECURSION
0);

-- Added columns and fitting datatypes in the dim_date table 
ALTER TABLE dbo.dim_date
ADD day INT,
	month_number INT,
	month_name NVARCHAR(50),
	quarter INT,
	year INT,
	weekday_name NVARCHAR(25);

-- Populated all the columns in the dim_date table
UPDATE dbo.dim_date
SET day = DATEPART(day, date),
	month_number = DATEPART(month, date),
	month_name = DATENAME(month, date),
	[quarter] = DATEPART(quarter, date),
	[year] = DATEPART(year, date),
	weekday_name = DATENAME(weekday, date);

-- Changed date_id column to INT NOT NULL datatype for primary key constraint
ALTER TABLE dbo.dim_date
ALTER COLUMN date_id INT NOT NULL;

-- Added primary key constraint
ALTER TABLE dbo.dim_date
ADD CONSTRAINT PK_date_id PRIMARY KEY (date_id);

-- Creating the order_fact table with an empty column date_id 
SELECT
    customer_id,
    NULL AS date_id,
    order_date,
    status,
    total_amount,
    order_id,
    store_id
INTO dbo.fact_order
FROM dbo.order_clean;

-- Populating the date_id column in the fact_order table with matching dates from the dim_date table
UPDATE FO
SET FO.date_id = DD.date_id
FROM dbo.fact_order AS FO
    JOIN dbo.dim_date AS DD ON FO.order_date = DD.date;

-- Drops order_date column from fact_order table
ALTER TABLE dbo.fact_order
DROP COLUMN order_date;

-- Changes the date_id column in the fact_order table to INT NOT NULL for foreign key constraint
ALTER TABLE dbo.fact_order
ALTER COLUMN date_id INT NOT NULL;

-- Adds foreign key constraint to the date_id column in the fact_order table
ALTER TABLE dbo.fact_order
ADD CONSTRAINT FK_date_id FOREIGN KEY (date_id)
REFERENCES dbo.dim_date (date_id);

-- Creating fact_order_item table
SELECT
    order_item_id,
    quantity,
    unit_price,
    line_total,
    product_id
INTO dbo.fact_order_item
FROM dbo.order_item_clean;

-- Creating dim_customer table
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    date_of_birth
INTO dbo.dim_customer
FROM dbo.customer_clean;

-- Creating dim_customer table
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    date_of_birth
INTO dbo.dim_customer
FROM dbo.customer_clean;