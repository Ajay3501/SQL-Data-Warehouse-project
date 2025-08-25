/*
===============================================================================================
DDL Script: Create silver Layers.
===============================================================================================
Script Purpose:
    This Script creates table in the 'silver' schema,dropping existing table if they exist.
    Run this script to re-define the DDL structure of 'silver' Tables.
===============================================================================================
*/

-- Building silver layer--

-- TABLE 1 OF silver CRM (1) --
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE IF NOT EXISTS silver.crm_cust_info (
cst_id             INT ,
cst_key            VARCHAR(50),
cst_firstname      VARCHAR(50),
cst_lastname       VARCHAR(50),
cst_marital_status VARCHAR(50),
cst_gndr           VARCHAR(50),
cst_create_date    DATE,
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- TABLE 2 silver CRM (2)--
DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE IF NOT EXISTS silver.crm_prd_info (
prd_id               INT NULL  ,
cat_id               VARCHAR(50),
prd_key              VARCHAR(50),
prd_nm               VARCHAR(50),
prd_cost             INT NULL,
prd_line             VARCHAR(50),
prd_start_dt         DATE NULL ,
prd_end_dt           DATE NULL,
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

);


-- TABLE 3 silver CRM (3)--
DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE IF NOT EXISTS silver.crm_sales_details (
sls_ord_num        VARCHAR(50) ,
sls_prd_key        VARCHAR(50),
sls_cust_id        INT,
sls_order_dt       DATE,
sls_ship_dt        DATE,
sls_due_dt         DATE,
sls_sales          INT,
sls_quantity       INT,
sls_price          INT,
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

);

-- TABLE 4  silver ERP (1) --
DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE IF NOT EXISTS silver.erp_cust_az12 (
cid      VARCHAR(50) ,
bdate    DATE ,
gen      VARCHAR(50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

);

-- TABLE 5 silver ERP(2) --
DROP TABLE IF EXISTS silver.erp_loc_A101;
CREATE TABLE IF NOT EXISTS silver.erp_loc_A101 (
sid    VARCHAR(50),
cntry  VARCHAR(50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

);

-- TABlE 6 silver ERP (3)--
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE IF NOT EXISTS silver.erp_px_cat_g1v2 (
id          VARCHAR(50),
cat         VARCHAR(50),
subcat      VARCHAR(50),
maintenance VARCHAR(50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
     
);
