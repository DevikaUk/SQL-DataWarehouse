/*============================================================
  Purpose: Validate data quality before and after loading
           customer data from the Bronze layer (crm_cst_info)
           into the Silver layer.

  Checks Performed:
  - Detect duplicate or NULL customer IDs
  - Detect leading and trailing whitespace in text columns
    (first name, last name, gender, and marital status)
  - Verify the distinct values of gender and marital status
    before and after standardization
  - Compare data quality between the Bronze and Silver layers
============================================================*/

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
