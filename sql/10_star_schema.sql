-- Purpose: Transform the relational database into a star schema ready for analysis.
--
-- Notes: dim_date is generated dynamically from the earliest and latest order date in order_clean.
--        fact_order_item is the single fact table linking to all dimensions via joins through order_clean.
--        customer_id, store_id, date_id and status are brought in from order_clean via order_id.
--        supplier_clean is dropped as it was not retained in any fact table.
--        The relational cleaned tables are retained and the star schema is built as a separate layer on top.
--        This was done to showcase and practice the knowledge of both concepts.
--
-- Date: 01/05/2026

-- Drop supplier_clean as it is not linked to any fact table
DROP TABLE IF EXISTS dbo.supplier_clean;

-- Table existence check
DROP TABLE IF EXISTS dbo.dim_date;

-- The declare statements need to be run with the CTE in one batch
DECLARE @start_date DATE = (SELECT MIN(order_date)
FROM dbo.order_clean);
DECLARE @end_date DATE = (SELECT MAX(order_date)
FROM dbo.order_clean);

-- dim_date table creation based on the earliest and latest date in the order_clean table
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

-- Creating fact_order_item as the single fact table joining order_clean for order level dimensions
SELECT
    OIC.order_item_id,
    OIC.order_id,
    OC.customer_id,
    OC.store_id,
    DD.date_id,
    OC.status,
    OC.total_amount,
    OIC.product_id,
    OIC.quantity,
    OIC.unit_price,
    OIC.line_total
INTO dbo.fact_order_item
FROM dbo.order_item_clean AS OIC
    JOIN dbo.order_clean AS OC ON OIC.order_id = OC.order_id
    JOIN dbo.dim_date AS DD ON OC.order_date = DD.date;

-- Creating dim_customer table
SELECT
    customer_id, first_name, last_name, email, phone, city, country, date_of_birth
INTO dbo.dim_customer
FROM dbo.customer_clean;

-- Creating dim_store table
SELECT
    store_id, store_name, city, address, postal_code, manager_name
INTO dbo.dim_store
FROM dbo.store_clean;

-- Creating dim_product table
SELECT
    product_id, product_name, category, price, stock_quantity
INTO dbo.dim_product
FROM dbo.product_clean;

-- Primary Keys
ALTER TABLE dbo.dim_date
ALTER COLUMN date_id INT NOT NULL;

ALTER TABLE dbo.dim_date
ADD CONSTRAINT PK_date_id PRIMARY KEY (date_id);

ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT PK_fact_order_item PRIMARY KEY (order_item_id);

ALTER TABLE dbo.dim_customer
ADD CONSTRAINT PK_dim_customer PRIMARY KEY (customer_id);

ALTER TABLE dbo.dim_product
ADD CONSTRAINT PK_dim_product PRIMARY KEY (product_id);

ALTER TABLE dbo.dim_store
ADD CONSTRAINT PK_dim_store PRIMARY KEY (store_id);


-- Changed date_id column in fact_order_item table to INT NOT NULL for foreign key constraint
ALTER TABLE dbo.fact_order_item
ALTER COLUMN date_id INT NOT NULL;

-- Foreign Keys
ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT FK_fact_order_item_customer FOREIGN KEY (customer_id) REFERENCES dbo.dim_customer (customer_id);

ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT FK_fact_order_item_store FOREIGN KEY (store_id) REFERENCES dbo.dim_store (store_id);

ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT FK_fact_order_item_date FOREIGN KEY (date_id) REFERENCES dbo.dim_date (date_id);

ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT FK_fact_order_item_product FOREIGN KEY (product_id) REFERENCES dbo.dim_product (product_id);

ALTER TABLE dbo.fact_order_item
ADD CONSTRAINT FK_fact_order_item_order FOREIGN KEY (order_id) REFERENCES dbo.order_clean (order_id);