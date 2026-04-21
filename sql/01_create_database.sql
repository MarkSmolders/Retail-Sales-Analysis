CREATE DATABASE RetailSales;
GO

USE RetailSales;
GO 

DROP TABLE IF EXISTS store_raw;
DROP TABLE IF EXISTS product_raw;
DROP TABLE IF EXISTS customer_raw;
DROP TABLE IF EXISTS order_raw;
DROP TABLE IF EXISTS order_item_raw;
GO

CREATE TABLE store_raw (
    store_name   NVARCHAR(100),
    city         NVARCHAR(100),
    address      NVARCHAR(200),
    postal_code  NVARCHAR(20),
    manager_name NVARCHAR(100)
);

CREATE TABLE product_raw (
    product_name   NVARCHAR(100),
    category       NVARCHAR(100),
    price          DECIMAL(10,2),
    supplier       NVARCHAR(100),
    stock_quantity INT
);

CREATE TABLE customer_raw (
    first_name    NVARCHAR(100),
    last_name     NVARCHAR(100),
    email         NVARCHAR(255),
    phone         NVARCHAR(20),
    city          NVARCHAR(100),
    country       NVARCHAR(100),
    date_of_birth DATE
);

CREATE TABLE order_raw(
    customer_name NVARCHAR(100),
    order_date    NVARCHAR(50), -- Changed to NVARCHAR because of inconsistent date formats
    store_name    NVARCHAR(100),
    status        NVARCHAR(100),
    total_amount  DECIMAL(10,2)
);

CREATE TABLE order_item_raw(
    order_reference NVARCHAR(100),
    product_name    NVARCHAR(100),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    line_total      DECIMAL(10,2)
);