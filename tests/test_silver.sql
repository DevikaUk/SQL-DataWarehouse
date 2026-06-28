/*============================================================
  Purpose:
  Validate data quality before and after loading data from the
  Bronze layer into the Silver layer.

  Tables Tested:
  - crm_cst_info
  - crm_prd_info
  - crm_sales_details
  - erp_cust_az12
  - erp_loc_a101
  - erp_px_cat_g1v2
============================================================*/


USE DataWarehouse;
GO


/*======================================================================================================================
Validate data quality before and after loading customer data from the Bronze layer (crm_cst_info)into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL customer IDs
  - Detect leading and trailing whitespace in text columns
    (first name, last name, gender, and marital status)
  - Verify the distinct values of gender and marital status
    before and after standardization
  - Compare data quality between the Bronze and Silver layers
========================================================================================================================*/

-- Preview existing records in crm_cst_info in Bronze Layer
SELECT * FROM bronze.crm_cst_info;


-- ============================================================
-- Validate data quality of crm_cst_info table in the Bronze layer
-- ============================================================

-- Detect duplicate or NULL customer IDs
SELECT cst_id, COUNT(*)
FROM bronze.crm_cst_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces in first name
SELECT cst_firstname
FROM bronze.crm_cst_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for unwanted spaces in last name
SELECT cst_lastname
FROM bronze.crm_cst_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for unwanted spaces in gender
SELECT cst_gndr
FROM bronze.crm_cst_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check cardinality for gender
SELECT DISTINCT cst_gndr FROM bronze.crm_cst_info;

-- Check cardinality for marital status
SELECT DISTINCT cst_marital_status FROM bronze.crm_cst_info;



-- ============================================================
-- Validate data quality of crm_cst_info in Silver Layer
-- ============================================================

-- Preview records in the silver table
SELECT * FROM silver.crm_cst_info;


-- Detect duplicate or NULL customer IDs
SELECT cst_id, COUNT(*)
FROM silver.crm_cst_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces in first name
SELECT cst_firstname
FROM silver.crm_cst_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for unwanted spaces in last name
SELECT cst_lastname
FROM silver.crm_cst_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for unwanted spaces in gender
SELECT cst_gndr
FROM silver.crm_cst_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Check for unwanted spaces in marital status
SELECT cst_marital_status
FROM silver.crm_cst_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Verify standardized gender values
SELECT DISTINCT cst_gndr
FROM silver.crm_cst_info;

-- Verify standardized marital status values
SELECT DISTINCT cst_marital_status
FROM silver.crm_cst_info;


/*=====================================================================================================================
Validate data quality before and after loading product data from the Bronze layer (crm_prd_info) into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL product IDs
  - Detect leading and trailing whitespace in product names
  - Identify NULL or negative product costs
  - Verify the distinct values of product lines before and
    after standardization
  - Identify invalid product date ranges where the end date
    precedes the start date
  - Compare data quality between the Bronze and
    Silver layers
========================================================================================================================*/


-- Preview existing records in crm_prd_info in Bronze layer
SELECT * FROM bronze.crm_prd_info;


-- ============================================================
-- Validate data quality of crm_prd_info table in the Bronze layer
-- ============================================================

-- Detect duplicate or NULL product IDs
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Detect unwanted whitespace in product names
SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for negative or NULL product costs
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Review distinct product line values
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Check for invalid date ranges where the end date precedes the start date
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



-- ============================================================
-- Validate data quality of crm_prd_info table in the Silver layer
-- ============================================================

-- Preview records in the Silver table
SELECT * FROM silver.crm_prd_info;

-- Detect duplicate or NULL product IDs
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Detect unwanted whitespace in product names
SELECT *
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for negative or NULL product costs
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Verify standardized product line values
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for invalid date ranges where the end date precedes the start date
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;




/*========================================================================================================================
Validate data quality before and after loading sales data from the Bronze layer (crm_sales_details) into the Silver layer.

  Checks Performed:
  - Detect leading and trailing whitespace in sales order numbers
  - Identify invalid order, shipping, and due date values
  - Verify the chronological order of sales dates
    (Order Date ≤ Ship Date ≤ Due Date)
  - Detect invalid or inconsistent sales, quantity,
    and price values
  - Compare data quality between the Bronze and
    Silver layers
===========================================================================================================================*/

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

/*=======================================================================================================================
Validate data quality before and after loading customer data from the Bronze layer (erp_cust_az12) into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL customer IDs
  - Identify invalid future birthdates
  - Verify the distinct values of gender before and
    after standardization
  - Compare data quality between the Bronze and
    Silver layers
===========================================================================================================================*/

-- Preview existing records in erp_cust_az12 in Bronze Layer
SELECT * FROM bronze.erp_cust_az12;


-- ============================================================
-- Validate data quality of erp_cust_az12 table in the Bronze layer
-- ============================================================

-- Detect duplicate or NULL IDs
SELECT cid, COUNT(*)
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Detect invalid birthdates
SELECT bdate FROM bronze.erp_cust_az12 WHERE bdate > GETDATE();

-- Check cardinality of gender
SELECT DISTINCT gen FROM bronze.erp_cust_az12;


-- ============================================================
-- Validate data quality of erp_cust_az12 in Silver Layer
-- ============================================================

-- Preview records in the silver table
SELECT * FROM silver.erp_cust_az12;

-- Detect duplicate or NULL IDs
SELECT cid, COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Detect invalid birthdates
SELECT bdate FROM silver.erp_cust_az12 WHERE bdate > GETDATE();

-- Check cardinality of gender
SELECT DISTINCT gen FROM silver.erp_cust_az12;

/*======================================================================================================================
Validate data quality before and after loading location data from the Bronze layer (erp_loc_a101) into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL customer IDs
  - Detect leading and trailing whitespace in country names
  - Verify the distinct country values before and
    after standardization
  - Compare data quality between the Bronze and
    Silver layers
=========================================================================================================================*/


-- Preview existing records in erp_loc_a101 in the Bronze layer
SELECT *
FROM bronze.erp_loc_a101;

-- ============================================================
-- Validate data quality of erp_loc_a101 table in the Bronze layer
-- ============================================================

-- Detect duplicate or NULL customer IDs
SELECT cid, COUNT(*)
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check for unwanted spaces in country names
SELECT cntry
FROM bronze.erp_loc_a101
WHERE cntry != TRIM(cntry);

-- Check country value consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;



-- ============================================================
-- Validate data quality of erp_loc_a101 table in the Silver layer
-- ============================================================

-- Preview existing records in erp_loc_a101 in the Bronze layer
SELECT *
FROM silver.erp_loc_a101;

-- Check for unwanted spaces in country names
SELECT cntry
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry);

-- Check country value consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;

/*==================================================================================================================================
Validate data quality before and after loading product category data from the Bronze layer (erp_px_cat_g1v2) into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL category IDs
  - Detect leading and trailing whitespace in category
    and subcategory values
  - Verify the distinct values of category,
    subcategory, and maintenance
  - Compare data quality between the Bronze and
    Silver layers
====================================================================================================================================*/


-- Preview existing records in the Bronze layer
SELECT *
FROM bronze.erp_px_cat_g1v2;

-- ============================================================
-- Validate data quality of erp_px_cat_g1v2 table in the Bronze layer
-- ============================================================

-- Detect duplicate or NULL IDs
SELECT id, COUNT(*)
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check for unwanted leading and trailing spaces in category and subcategory
SELECT cat, subcat
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat);

-- Check consistency of maintenance values
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

-- Check consistency of subcategory values
SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

-- Check consistency of category values
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;


-- ============================================================
-- Validate data quality of erp_px_cat_g1v2 table in the Silver layer
-- ============================================================

-- Preview records in the Silver layer
SELECT *
FROM silver.erp_px_cat_g1v2;

-- Detect duplicate or NULL IDs
SELECT id, COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check for unwanted leading and trailing spaces in category and subcategory
SELECT cat, subcat
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat);

-- Check consistency of maintenance values
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;

-- Check consistency of subcategory values
SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

-- Check consistency of category values
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;
