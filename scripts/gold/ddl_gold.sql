-- Purpose: Create business-level views in the Gold layer.

USE DataWarehouse;
GO

/*=============================================
  VIEW: gold.dim_customers
  Purpose: Stores business-level customer data
==============================================*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
    ca.cst_id AS customer_id,
    ca.cst_key AS customer_number,
    ca.cst_firstname AS customer_firstname,
    ca.cst_lastname AS customer_lastname,
    CASE
	    WHEN ca.cst_gndr != 'n/a' THEN ca.cst_gndr
	    ELSE COALESCE(cb.gen, 'n/a')
    END AS customer_gender,
    cb.bdate AS birthdate,
    cc.cntry AS country,
    ca.cst_marital_status AS customer_marital_status,
    ca.cst_create_date AS create_date
FROM silver.crm_cst_info ca 
LEFT JOIN silver.erp_cust_az12 AS cb
    ON ca.cst_key = cb.cid
LEFT JOIN silver.erp_loc_a101 AS cc
    ON cb.cid = cc.cid
;
GO 

/*============================================
  VIEW: gold.dim_products
  Purpose: Stores business-level product data
=============================================*/

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO


CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pa.prd_start_dt, pa.prd_key) AS product_key,
    pa.prd_id AS product_id,
    pa.prd_key AS product_number,
    pa.prd_nm AS product_name,
    pa.cat_id AS category_id,
    pb.cat AS category,
    pb.subcat AS subcategory,
    pb.maintenance,
    pa.prd_cost AS product_cost,
    pa.prd_line AS product_line,
    pa.prd_start_dt AS start_date
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pb
    ON pa.cat_id = pb.id
WHERE pa.prd_end_dt IS NULL; -- FILTER OUT HISTORICAL DATA
GO


/*============================================
  VIEW: gold.fact_sales
  Purpose: Stores business-level sales data
=============================================*/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sa.sls_ord_num AS order_number,
    pa.product_key,
    ca.customer_key,
    sa.sls_order_dt AS order_date,
    sa.sls_ship_dt AS shipping_date,
    sa.sls_due_dt AS due_date,
    sa.sls_sales AS sales_amount,
    sa.sls_quantity AS quantity,
    sa.sls_price AS price
FROM silver.crm_sales_details sa
LEFT JOIN gold.dim_products pa 
    ON sa.sls_prd_key = pa.product_number
LEFT JOIN gold.dim_customers ca
    ON sa.sls_cust_id = ca.customer_id;
