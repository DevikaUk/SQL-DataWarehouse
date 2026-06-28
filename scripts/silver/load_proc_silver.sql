/*============================================================
  Purpose: Clean, standardize, and load CRM data from the
           Bronze layer into the Silver layer.

  Tables Processed:
    - crm_cst_info      (Customer Information)
    - crm_prd_info      (Product Information)
    - crm_sales_details (Sales Transactions)
    - erp_cust_az12     (Extra Customer Information)
    - erp_loc_a101      (Customer Location)
    - erp_px_cat_g1v2   (Product Categories)

  Transformations Applied:
    - Remove duplicate records
    - Handle NULL and missing values
    - Trim leading and trailing spaces from text fields
    - Standardize categorical values
    - Split composite columns into separate fields
    - Replace and normalize values
    - Remove unwanted prefixes and special characters
    - Convert data to appropriate data types
    - Correct invalid, missing, or negative values


============================================================*/

USE DataWarehouse;
GO


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE()

        PRINT '================================================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================================================';

        PRINT '================================================================================';
        PRINT 'Loading CRM Tables';
        PRINT '================================================================================';


        -- ============================================================
        -- Load Customer Information (crm_cst_info)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.crm_cst_info';
        TRUNCATE TABLE silver.crm_cst_info;

        -- Load cleaned and standardized customer data
        PRINT '>> INSERTING DATA INTO: silver.crm_cst_info';

        INSERT INTO silver.crm_cst_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS flg
            FROM bronze.crm_cst_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE flg = 1;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        -- ============================================================
        -- Load Product Information (crm_prd_info)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        -- Load cleaned and standardized product data
        PRINT '>> INSERTING DATA INTO: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            TRIM(prd_nm) AS prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1
                AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        -- ============================================================
        -- Load Sales Details (crm_sales_details)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        -- Load cleaned and standardized sales transaction data
        PRINT '>> INSERTING DATA INTO: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert valid order dates; replace invalid values with NULL
            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            -- Convert valid ship dates; replace invalid values with NULL
            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            -- Convert valid due dates; replace invalid values with NULL
            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,

            -- Recalculate invalid or missing sales amounts
            CASE
                WHEN sls_sales != sls_quantity * sls_price
                  OR sls_sales IS NULL
                  OR sls_sales < 0
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            -- Correct missing or negative prices
            CASE
                WHEN sls_price IS NULL
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                WHEN sls_price < 0
                    THEN ABS(sls_price)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        PRINT '================================================================================';
        PRINT 'Loading ERP Tables';
        PRINT '================================================================================';

        -- ============================================================
        -- Load Extra Customer Information (erp_cust_az12)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        -- Load cleaned and standardized customer data
        PRINT '>> INSERTING DATA INTO: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            -- Remove the 'NAS' prefix from customer IDs
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            -- Replace future birth dates with NULL
            CASE
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            -- Standardize gender values
            CASE
                WHEN TRIM(UPPER(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN TRIM(UPPER(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        -- ============================================================
        -- Load Customer Location (erp_loc_a101)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        -- Load cleaned and standardized location data
        PRINT '>> INSERTING DATA INTO: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            -- Remove hyphens from customer IDs
            REPLACE(cid, '-', '') AS cid,

            -- Standardize country names and replace missing values
            CASE
                WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'n/a'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        -- ============================================================
        -- Load Product Categories (erp_px_cat_g1v2)
        -- ============================================================

        SET @start_time = GETDATE();
        -- Remove existing records from the Silver table
        PRINT '>> TRUNCATING TABLE silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        -- Load validated product category data
        PRINT '>> INSERTING DATA INTO: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        SET @batch_end_time = GETDATE();
        PRINT 'Batch Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        PRINT '=================================================================================';
        PRINT 'ERROR WHILE LOADING SILVER LAYER';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT '=================================================================================';
    END CATCH

END

EXEC silver.load_silver;
