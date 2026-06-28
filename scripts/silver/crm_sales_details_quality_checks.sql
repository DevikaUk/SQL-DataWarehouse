/*============================================================
  Purpose: Validate data quality before and after loading
           sales data from the Bronze layer
           (crm_sales_details) into the Silver layer.

  Checks Performed:
  - Detect leading and trailing whitespace in sales order numbers
  - Identify invalid order, shipping, and due date values
  - Verify the chronological order of sales dates
    (Order Date ≤ Ship Date ≤ Due Date)
  - Detect invalid or inconsistent sales, quantity,
    and price values
  - Compare data quality between the Bronze and
    Silver layers
============================================================*/

-- Preview existing records in the Bronze layer
SELECT *
FROM bronze.crm_sales_details;


-- ============================================================
-- Validate data quality of crm_sales_details table in the Bronze layer
-- ============================================================

-- Check for unwanted spaces in sales order numbers
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check for invalid order dates (0 or negative values)
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;

-- Check for invalid shipping dates (0 or negative values)
SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0;

-- Check for invalid due dates (0 or negative values)
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0;

-- Check for inconsistent date sequence
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check for invalid sales, quantity, and price values
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;


-- ============================================================
-- Validate data quality of crm_sales_details table in the Silver layer
-- ============================================================

-- Preview records in the Silver layer
SELECT *
FROM silver.crm_sales_details;

-- Check for unwanted spaces in sales order numbers
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check for NULL order dates after cleaning
SELECT sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL;

-- Check for NULL shipping dates after cleaning
SELECT sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL;

-- Check for NULL due dates after cleaning
SELECT sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL;

-- Check for inconsistent date sequence
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check for invalid sales, quantity, and price values after cleaning
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0;
