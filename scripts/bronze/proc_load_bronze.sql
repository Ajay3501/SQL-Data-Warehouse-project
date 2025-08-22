/*
======================================================================================================================
Stored Procedure: load Bronze Layer (Source -> Bronze)
======================================================================================================================
Script Purpose:
    These scripts Load Data into the Table 'Bronze' schema from external CSV files.
    It Performs the Following actions :
        - Truncates the bronze tables before loading data.
        - uses the 'Data Load Infile'  command to load data from CSV files to Bronze tables.

*/
-- =================================================================================================
-- NOW INSERT DATA INTO TABLES (BULK)
-- ========================================================================================================================

-- BULK INSERT DATA INTO TABLE CRM(1)
-- before that truncate table just to avoid duplicate if in case you executed twice

TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- to view table --
SELECT count(*) FROM bronze.crm_cust_info;

-- BULK INSERT DATA INTO TABLE CRM(2) =====================================================================================

TRUNCATE TABLE bronze.prd_cust_info;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\prd_info.csv"
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    @prd_id,
    @prd_key,
    @prd_nm,
    @prd_cost,
    @prd_line,
    @prd_start_dt,
    @prd_end_dt
)
SET
    prd_id       = NULLIF(@prd_id,''),
    prd_key      = NULLIF(@prd_key,''),
    prd_nm       = NULLIF(@prd_nm,''),
    prd_cost     = NULLIF(@prd_cost,''),
    prd_line     = NULLIF(@prd_line,''),
    prd_start_dt = STR_TO_DATE(NULLIF(@prd_start_dt,''), '%Y-%m-%d'),
    prd_end_dt   = STR_TO_DATE(NULLIF(@prd_end_dt,''), '%Y-%m-%d');
    
SELECT * FROM bronze.crm_prd_info;

-- BULK INSERT DATA INTO TABLE CRM(3) AFTER TRUNCATING ==========================================================================

TRUNCATE TABLE crm_sales_details;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\sales_details.csv'
INTO TABLE crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
                  -- BELOW THESE EXTRA QUERY I HAVE TO DO JUST BECAUSE DATA CLEANSING IS NOT PROCEED
	(@sls_ord_num,@sls_prd_key,@sls_cust_id,@sls_order_dt,@sls_ship_dt,@sls_due_dt,@sls_sales,@sls_quantity,@sls_price
)
SET 
	sls_ord_num		= NULLIF(@sls_ord_num,''),
    sls_prd_key		= NULLIF(@sls_prd_key,''),
    sls_cust_id		= NULLIF(@sls_cust_id,''),
    sls_order_dt	= NULLIF(@sls_order_dt,''),
    sls_ship_dt		= NULLIF(@sls_ship_dt,''),
    sls_due_dt		= NULLIF(@sls_due_dt,''),
    sls_sales		= NULLIF(@sls_sales,''),
    sls_quantity	= NULLIF(@sls_quantity,''),
    sls_price		= NULLIF(@sls_price,'');

SELECT *FROM crm_sales_details;
-- BULK INSERT DATA INTO TABLE ERP(1) AFTER TRUNCATING ==========================================================================

TRUNCATE TABLE erp_cust_az12;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CUST_AZ12.csv'
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *FROM erp_cust_az12;

-- BULK INSERT DATA INTO TABLE ERP(2) AFTER TRUNCATING ==========================================================================

TRUNCATE TABLE erp_loc_a101 ;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\LOC_A101.csv'
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *FROM erp_loc_a101;

-- BULK INSERT DATA INTO TABLE ERP(3) AFTER TRUNCATING ==========================================================================

TRUNCATE TABLE erp_px_cat_g1v2 ;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *FROM erp_px_cat_g1v2;


