-- Purpose: Create tables to store cleaned and standardized CRM and ERP data in the Silver layer.

USE DataWarehouse;
GO

/*============================================================
  Table: silver.crm_cst_info
  Purpose: Stores cleaned and standardized customer data from
           the CRM system.
============================================================*/
IF OBJECT_ID('silver.crm_cst_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cst_info;
GO

CREATE TABLE silver.crm_cst_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  VARCHAR(10),
    cst_gndr            VARCHAR(10),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

/*============================================================
  Table: silver.crm_prd_info
  Purpose: Stores cleaned and standardized product data from
           the CRM system.
============================================================*/
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          VARCHAR(50),
    prd_key         VARCHAR(50),
    prd_nm          VARCHAR(50),
    prd_cost        INT,
    prd_line        VARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*============================================================
  Table: silver.crm_sales_details
  Purpose: Stores cleaned and standardized sales transaction
           data from the CRM system.
============================================================*/
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     VARCHAR(50),
    sls_prd_key     VARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/*============================================================
  Table: silver.erp_cust_az12
  Purpose: Stores cleaned and standardized customer data from
           the ERP system.
============================================================*/
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
);
GO

/*============================================================
  Table: silver.erp_loc_a101
  Purpose: Stores cleaned and standardized customer location
           data from the ERP system.
============================================================*/
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid     VARCHAR(50),
    cntry   NVARCHAR(50)
);
GO

/*============================================================
  Table: silver.erp_px_cat_g1v2
  Purpose: Stores cleaned and standardized product category
           data from the ERP system.
============================================================*/
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              VARCHAR(50),
    cat             VARCHAR(50),
    subcat          VARCHAR(50),
    maintenance     VARCHAR(50)
);
GO
