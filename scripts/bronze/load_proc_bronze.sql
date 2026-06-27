 -- Purpose: Load/Refresh the customer table with the latest data from the CRM and ERP source file.

 USE DataWarehouse;
 GO

/*============================================================
  Procedure: bronze.load_bronze
  Purpose: Load raw CRM and ERP data into the Bronze layer by
           truncating existing tables and performing bulk
           inserts from the source CSV files.
============================================================*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================================================';

        PRINT '================================================================================';
        PRINT 'Loading CRM Tables';
        PRINT '================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cst_info';
        -- Remove all existing records while keeping the table structure.
        TRUNCATE TABLE bronze.crm_cst_info;

        PRINT '>> Inserting Data Into Table: bronze.crm_cst_info';
        -- Bulk load customer data from the CSV file.
        BULK INSERT bronze.crm_cst_info
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        -- Remove all existing product records.
        TRUNCATE TABLE bronze.crm_prd_info;
        -- Bulk load product data from the CSV file.

        PRINT '>> Inserting Data Into Table: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        -- Remove all existing sales records.
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into Table: bronze.crm_sales_details';
        -- Bulk load sales transaction data from the CSV file.
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        PRINT '================================================================================';
        PRINT 'Loading ERP Tables';
        PRINT '================================================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        -- Remove all existing records.
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into Table: bronze.erp_cust_az12';
        -- Bulk load customer demographic data from the CSV file.
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        -- Remove all existing records.
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into Table: bronze.erp_loc_a101';
        -- Bulk load customer location data from the CSV file.
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        -- Remove all existing records.
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into Table: bronze.erp_px_cat_g1v2';
        -- Bulk load product category data from the CSV file.
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\devik\Desktop\Data Analytics\Data Warehouse\Baraa\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(10))+'seconds';

        PRINT '================================================================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT '================================================================================';
        
        SET @batch_end_time = GETDATE()
        PRINT 'Batch Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(10));
    END TRY
    BEGIN CATCH
        PRINT '=================================================================================';
        PRINT 'ERROR WHILE LOADING BRONZE LAYER';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT '=================================================================================';
    END CATCH;
END
