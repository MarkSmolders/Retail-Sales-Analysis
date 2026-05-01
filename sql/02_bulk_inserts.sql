-- Purpose: Load raw CSV data into staging tables
-- Note:    Local paths used because BULK INSERT requires direct filesystem access
-- Date:    01/05/2026

USE RetailSales;
GO

BULK INSERT store_raw
FROM 'C:\Portfolio\Retail-Sales-Analysis\data\raw\raw_stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT product_raw
FROM 'C:\Portfolio\Retail-Sales-Analysis\data\raw\raw_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT customer_raw
FROM 'C:\Portfolio\Retail-Sales-Analysis\data\raw\raw_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT order_raw
FROM 'C:\Portfolio\Retail-Sales-Analysis\data\raw\raw_orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

BULK INSERT order_item_raw
FROM 'C:\Portfolio\Retail-Sales-Analysis\data\raw\raw_order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);