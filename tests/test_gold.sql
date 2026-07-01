/*============================================================
  Purpose:
  Validate data quality in Gold layer.

  Views Tested:
  - gold.dim_customers
  - gold.dim_products
  - gold.fact_sales
============================================================*/


use DataWarehouse;
GO

-- Check for duplicate customer keys in gold.dim_customers
SELECT 
	customer_key,
	COUNT(*) AS count_keys
FROM gold.dim_customers
GROUP BY
	customer_key
HAVING 
	COUNT(*) > 1;

-- Check for NULL customer keys
SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- Check for duplicate product keys in gold.dim_products
SELECT 
	product_key,
	COUNT(*) AS count_keys
FROM gold.dim_products
GROUP BY
	product_key
HAVING COUNT(*) > 1;

-- Check for NULL product keys
SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- Check model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales s 
LEFT JOIN 
gold.dim_customers c
	ON s.customer_key = c.customer_key
LEFT JOIN 
gold.dim_products p
	ON s.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;

-- Check for NULL foreign keys in gold.fact_sales
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;
