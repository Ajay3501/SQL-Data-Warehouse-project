/* 
=============================================================
Aim is just to INSERT data into all TAbles "silver"
=============================================================
*/

-- SILVER TABLE 1--
	
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info
( cst_id,
cst_key,
cst_firstname ,
cst_lastname ,
cst_marital_status , 
cst_gndr, 
cst_create_date ,
dwh_create_date 
)
SELECT 
	tt.cst_id,
	tt.cst_key,
	TRIM(tt.cst_firstname) AS cst_firstname,
	TRIM(tt.cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(TRIM(tt.cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(tt.cst_marital_status))= 'S' THEN 'Single'
         ELSE 'N/A'
	END AS cst_marital_status,
	CASE WHEN UPPER(TRIM(tt.cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(tt.cst_gndr)) = 'M' THEN 'Male'
         ELSE 'N/A'
	END AS cst_gndr,
	tt.cst_create_date ,
	CURRENT_TIMESTAMP AS dwh_create_date   -- ✅ added this
                                         -- this this coming cst_id after cleaning
          
FROM (
			SELECT 
			*,
			row_number() over(PARTITION BY cst_id order by cst_create_date desc) as ranking
			FROM bronze.crm_cust_info
		)as tt WHERE ranking  = 1;
		
        
-- =======================(Table 1 ends here) ==========/////////////////////////////////////////===========================================================
                      
                      
                         -- SILVER TABLE 2

TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info
(	prd_id,
	cat_id,
	prd_key,
    prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt, 
	prd_end_dt, 
	dwh_create_date
)
SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,         -- here to match or joi from other columns in place of '-' this '_' required  
	SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,           -- substringed
    prd_nm,                                                  -- for this column quality any unwanted spaces which written below 
	IfNULL(prd_cost,0) AS prd_cost,                            -- FOUND NULL inside this need to transform 'null' into '0'
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'  -- seems like abbreviations convert into full fornm after checking
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'  
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'   
	END AS prd_line ,                                        
	CAST(prd_start_dt AS DATE) AS prd_start_dt,                  -- now in START and END date always check if start date > than end date
	DATE_FORMAT(LEAD(CAST(prd_start_dt AS DATE)) OVER (PARTITION BY prd_key ORDER BY CAST(prd_start_dt AS DATE)),'%Y-%m-%d') AS prd_end_dt,
	CURRENT_TIMESTAMP AS dwh_create_date                         -- if yes then there is data quality issue will have to think about this
FROM bronze.crm_prd_info;

-- ==========================(Table 2 ends here)==========/////////////////////////////////////////===========================================================


                              -- TABLE SILVER CRM(3)

-- >>>>>>>>>>>>>>> INSERT NOW IN SILVER (3)
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details
(
	sls_ord_num,
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt, 
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price, 
	dwh_create_date     
)
SELECT
	sls_ord_num,
	sls_prd_key, 
	sls_cust_id, 
    CASE
		WHEN LENGTH(sls_order_dt) != 10 THEN NULL
    ELSE sls_order_dt                                                  -- cleaning
    END AS sls_order_dt, 
	CASE
		WHEN LENGTH(sls_ship_dt) != 10 THEN NULL                          -- cleaning
    ELSE sls_ship_dt
    END AS sls_ship_dt, 
	CASE
		WHEN LENGTH(sls_due_dt) != 10 THEN NULL                           -- cleaning
    ELSE sls_due_dt
    END AS sls_due_dt, 
	CASE 
		WHEN sls_sales is null OR sls_sales  <= 0 OR sls_sales != ABS(sls_quantity)*ABS(sls_price)
			THEN sls_quantity* ABS(sls_price)
        ELSE sls_sales
	END AS sls_sales,                                           -- cleaning and calculating
	sls_quantity, 
    CASE                                                      -- cleaning and calculating
		WHEN sls_price is NULL OR sls_price <= 0
        THEN ROUND(sls_sales / NULLIF(sls_quantity,0),0)
        ELSE sls_price
	END AS sls_price ,
	CURRENT_TIMESTAMP AS dwh_create_date                    
FROM  bronze.crm_sales_details;                               -- INSERT DONE

-- now check silver table "quality check" again        >>>>>>>>>>> all checked completely fine 

-- =====================Table 3 ends here ==========/////////////////////////////////////////===========================================================

           -- SULVER TABLE 4--
-- ==================================================
-- >>>>>>>>>>>>>>>>>>> insert in silver table 4
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12
(
	cid,
    bdate,
    gen,
	dwh_create_date                    
)
SELECT 
	 CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))           -- matching connecting columns 
		ELSE cid
	END AS cid,
		CASE 
			WHEN bdate > CURRENT_DATE() THEN null                           -- correcting invalid date
		ELSE bdate
		END AS bdate,
CASE 
	WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'                -- correcting gen columns data
   	WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
	ELSE 'n/a'
END AS gen,
CURRENT_TIMESTAMP AS dwh_create_date                    
FROM  bronze.erp_cust_az12;

SELECT *
FROM silver.erp_cust_az12 ;  -- NOW AGAIN QUALITY CHECK 

SELECT DISTINCT gen from silver.erp_cust_az12   ;            -- checked fine

           
select bdate
from silver.erp_cust_az12 
where bdate > current_date();                                -- no result fine 


-- Table 4 ends here ==========/////////////////////////////////////////===========================================================

                                 -- SULVER TABLE 5--
-- ====================================================
             -- insert into table silver 5
TRUNCATE TABLE  silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 
(
	sid,
    cntry,
    dwh_create_date
)
SELECT 
	REPLACE(sid,'-','') AS sid,                                     
    CASE                                                   
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'                      
		WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' or null THEN 'N\A'
        ELSE TRIM(cntry)
	END AS cntry,
CURRENT_TIMESTAMP AS dwh_create_date                    
FROM bronze.erp_loc_a101 ;

select *
from silver.erp_loc_a101 

-- Table 5 ends here ==========/////////////////////////////////////////===========================================================


                                      -- >>>>>>> INSERT INTO SILVER 6
	
 TRUNCATE TABLE silver.erp_px_cat_g1v2;
 INSERT INTO silver.erp_px_cat_g1v2
 (
	id,
    cat,
    subcat,
    maintenance,
    dwh_create_date
 )
 SELECT *,
 		CURRENT_TIMESTAMP AS dwh_create_date                    
 FROM  bronze.erp_px_cat_g1v2;
 
 SELECT * FROM silver.erp_px_cat_g1v2;

-- Table 6 ends here ==========/////////////////////////////////////////===========================================================

