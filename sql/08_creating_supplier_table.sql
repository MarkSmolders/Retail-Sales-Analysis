-- Purpose: Create a supplier table including the store names and the store_ids as primary key.
-- Date: 25/04/2026

DROP TABLE IF EXISTS dbo.supplier_clean;

CREATE TABLE dbo.supplier_clean (
	supplier_id INT IDENTITY(1,1),
	supplier    NVARCHAR(100)
);

INSERT INTO dbo.supplier_clean (supplier)
SELECT DISTINCT supplier
FROM dbo.product_clean;

ALTER TABLE dbo.supplier_clean
ADD CONSTRAINT PK_supplier_id PRIMARY KEY (supplier_id);