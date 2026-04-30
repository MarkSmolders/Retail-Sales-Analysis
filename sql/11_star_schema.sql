
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