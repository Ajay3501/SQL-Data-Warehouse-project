/*
==============================================================================================================
                                               Quality checks
==============================================================================================================
Script Purpose:
		This script perforsm various quality checks for data consistency, accuracy and
        standardisation across the'silver'schema . It includes checks for:
        - NULL or duplicaes primary keys.alter
        - Unwanted spaces in string fields.
        - Data standardization and consistency.
        - Invalid date ranges and orders.
        - Data consistency between related fields.
        
Usage notes :
	- Run hese checks after loading silver layer.alter- Investigate and resolve any discripancies found during checks.
    ============================================================================================================
*/
/*===================================
-- SILVER TABLE 1--
===================================*/
                           
-- HERE WE WILL CLEANUP DATA INSIDE CRM TABLE 1 AND INSERT INTO SILVER LAYER------------------
-- check for NULLS and DUPLICATES in cst_id column the Primary key on crm table (1)
-- expectation : no nulls and duplicates
           -- transformationstarts from here
SELECT 
cst_id,
COUNT(cst_id) as DUPLICATE_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(cst_id) > 1 OR cst_id = 'NULL';

-- HERE DUPLICATE DETECTED AN NO NULLS DETECTED
-- NOW TRANSFORM DUPLICATES

SELECT *
FROM(
	SELECT 
	*,
	row_number() over(PARTITION BY cst_id order by cst_create_date desc) as ranking
	FROM bronze.crm_cust_info
)as tt
WHERE ranking  = 1;

/* till now cst_id column sorted correctly
>>> now lets move to next columns and check because of these are string check extra spaces 
    and TRIM 4 columns (first_name,last_name,martial status and gender) */
-- CHECK NNWANTED sapces
-- expectation : no result

SELECT
-- cst_firstname          -- (issue found)
-- cst_lastname           -- (issue found)
-- cst_marital_status       -- (correct in space)
 cst_gndr                   -- (corect in space)
FROM  bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
    
-- found result means needs to trim this column
-- (1) now transform firstname nad last name column trim function
-- (2)ALSO fix the abbreviation issue in columns martialstatus and gender transform into full form

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status))= 'S' THEN 'Single'
         ELSE 'N/A'
	END AS cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
         ELSE 'N/A'
	END AS cst_gndr,
	cst_create_date 
FROM bronze.crm_cust_info;

-- check data consistency in martial and gendr column
SELECT DISTINCT 
-- st_marital_status    -- (issue found (''))
cst_gndr                -- (issue found blankstr and  (("))
FROM bronze.crm_cust_info;


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- =========================
 -- SILVER TABLE 2
 -- =========================

-- HERE WE WILL CLEANUP DATA INSIDE CRM TABLE 2------------------

-- check for NULLS and DUPLICATES in prd_id column the Primary key on crm table (2)
-- expectation : NO nulls and  NO duplicates
           -- cleaning nd transformation starts from here--
select*
from( 
SELECT 
	prd_id,
	COUNT(*) AS REPETETION
FROM silver.crm_prd_info
GROUP BY prd_id
)tt
where REPETETION != 1; -- result showing nothing means everything is fine in prd_id column

-- lets move to another columns >>>>>>

select *
from bronze.crm_prd_info;

-- In second columns a lot of thing to do and need to get sunstring because this column will be join from other
 -- we want to split this colmn in two different column alter
 -- 1st 5 character and remaining character will be splited just to use to join other columns
 
-- Simultaneously  we will be transforming all columns here >>>>>>>>>>>

SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,      -- here to match or joi from other columns in place of '-' this '_' required  
	SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,       -- substringed
    prd_nm,                                                 -- for this column quality any unwanted spaces which written below 
	IfNULL(prd_cost,0) AS prd_cost,                         -- FOUND NULL inside this need to transform 'null' into '0'
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'  -- seems like abbreviations convert into full fornm after checking
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'  
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'N/A'   
	END AS prd_line ,                                        
	CAST(prd_start_dt AS DATE) AS prd_start_dt,                                            -- now in START and END date always check if start date > than end date
	DATE_FORMAT(LEAD(CAST(prd_start_dt AS DATE)) OVER (PARTITION BY prd_key ORDER BY CAST(prd_start_dt AS DATE)),'%Y-%m-%d') AS prd_end_dt,   
	CURRENT_TIMESTAMP AS dwh_create_date                                                     -- if yes then there is data quality issue will have to think about this
FROM bronze.crm_prd_info;

-- ========================================================================================================================
          -- quality check for column prd_nm whi is completely fine
          -- expectation NO extra spances
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


 -- quality check for column prd_cost 
 -- expectation NO NULLs ,NO negative number  or no results
 SELECT
	prd_cost
 FROM silver.crm_prd_info
	HAVING prd_cost IS NULL OR  prd_cost < 0;   -- WE GOT NULL NEEDS TO BE TRANSFORM NULL INTO '0';
    
 -- quality check for column prd_line 
 SELECT DISTINCT
 prd_line
 FROM silver.crm_prd_info; -- FOUND NULL AND ABBREVIATED VALUE CONVERT INTO FULL FORM

-- conditions in start and end date are:- 
		-- condition(1) quality check if start date > end date,
		-- condition(2) BETWEEN two session after ending first only and only after 2nd can start
		-- condition(3) in one session if there is srart then end date in not necessary but 
		-- condition(4) if there is end date then there must be start date.
-- expectation NO results

SELECT*
FROM  bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt; 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          
          
-- DATA QUALITY CHECK FOR TABLE SILVER CRM(3)
-- IST column contains so check extra spaces contains or not
-- expectation: no result

SELECT
	sls_ord_num,
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt, 
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price, 
		CURRENT_TIMESTAMP AS dwh_create_date                    
FROM  silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);  -- NO Rresult returned means everything is fine in this column

-- quality check 2--
-- next two columns are important because these columns will be used to join other tables so check all prd_key are present on connecting table or not
-- expectation: NO RESULT

SELECT 
	sls_ord_num,
	-- sls_prd_key               -- CHECK THIS SO WE CAN ASSURE EVERY DATA WILL JOIN OR NOT
    sls_cust_id             -- CHECK THIS SO WE CAN ASSURE EVERY DATA WILL JOIN OR NOT
 FROM  silver.crm_sales_details
 WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)   ; -- comparing with the table which we be connect later

    -- no result found it means every thing is fine to join table from this column
    -- till now 3 columns looks fine 
    
             -- CHECK FOR INVALID DATE --
    -- CHECK FOR NEXT 3 DATE COLUMNS 
    -- CONDITION CHECK:-
    /*  
        1) (= 0) , (= < 0) ,ORD<SHIP<DUE   IF THESE THINGS EXISTS THEN CONVERT ALL VALUES TO 'NULL',CHECK NULLS
	*/  
	
	SELECT 
         sls_order_dt
		-- sls_ship_dt
        --  sls_due_dt
	FROM silver.crm_sales_details
    WHERE sls_order_dt IS NULL;
																 -- HERE IN THESE THERE ARE NO 0 VALUES
																 -- NOT NULL FOUNDED
	-- CHECK DATE LENGTH
    
    SELECT 
         -- sls_order_dt
		-- sls_ship_dt
         sls_due_dt
	FROM silver.crm_sales_details
    WHERE LENGTH(sls_due_dt) != 10 ;                        -- SEEMS TO BE FINE
    
    -- DATE INTERVAL LEAD AND LAG ISSUE
    --  EXPECTATION : NO result
    SELECT *
	FROM silver.crm_sales_details
    WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt OR sls_ship_dt >sls_due_dt;
    
    -- completely fine till now
    
    -- DATA CONSISTENCE check for other columns
--  must follow (sales = quantity * price )
-- if there is any issue in specific column you ca ignore that column and derive expression from other 2 columns
-- issue could be ( -ve value , 0 ,calculation issue  and null)
SELECT 
	sls_sales,
	sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <= 0 OR  sls_quantity  <= 0 OR sls_price  <= 0 
or sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales,sls_quantity, sls_price;
                                            -- a lot of issue found need to fix all in all 3 columns
-- ===========================================================================================================================

SELECT
	sls_ord_num,
	sls_prd_key, 
	sls_cust_id, 
    CASE
		WHEN LENGTH(sls_order_dt) != 10 THEN 'NULL'
    ELSE sls_order_dt                                                  -- cleaning
    END AS sls_order_dt, 
	CASE
		WHEN LENGTH(sls_ship_dt) != 10 THEN 'NULL'                     -- cleaning
    ELSE sls_ship_dt
    END AS sls_ship_dt, 
	CASE
		WHEN LENGTH(sls_due_dt) != 10 THEN 'NULL'                       -- cleaning
    ELSE sls_due_dt
    END AS sls_due_dt, 
	CASE 
		WHEN sls_sales =' NULL' OR sls_sales  <= 0 OR sls_sales != ABS(sls_quantity)*ABS(sls_price)
			THEN sls_quantity* ABS(sls_price)
        ELSE sls_sales
	END AS sls_sales,                                         -- cleaning and calculating
	sls_quantity, 
    CASE                                                      -- cleaning and calculating
		WHEN sls_price is NULL OR sls_price <= 0
        THEN ROUND(sls_sales / NULLIF(sls_quantity,0),0)
        ELSE sls_price
	END AS sls_price ,
	CURRENT_TIMESTAMP AS dwh_create_date                    
FROM  bronze.crm_sales_details;
                                                   -- everything done cleaning and transforming check DDL THEN INSERT
                                                   
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- SULVER TABLE 4--CLEANSING and checkups 
      
      -- Data Quality checkup and INSERTING IN SILVER--
	  -- CHECK either this column is going to be join to another table or not
      -- if yes then match both table  ids and makesure both column match completely no unique should left
      -- THIS TABLE WILL BE JOIN WITH CRM_CUST_INFO with column cust_key which contains little different data check and make it similar
SELECT*
FROM bronze.erp_cust_az12;
SELECT *FROM SILVER.crm_cust_info;
         -- AFTER COMPALIRING BOTH CONNECTING TABLES COLUMNS THERE ARE SOME EXTRA CHARACTERS BEFORE MATCHING SO MAKE IT SIMILAR
		-- AND ALSO THEN check all columns are present on both tables or not ?
        
SELECT
	cid,
    CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
		ELSE cid
	END AS cid
FROM bronze.erp_cust_az12;
                                    -- NOW TRUNCATE SUCCESFULL MEANS THEY ARE MATCHING
									-- NOW CHECK EVERY ROW MATCHING OR NOT
SELECT
	cid,
    CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
		ELSE cid
	END AS cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
		ELSE cid
	END NOT IN (SELECT distinct cst_key from silver.crm_cust_info );
                       
                                      -- there are not any unmatching data between 2 tables
                                      
 -- Now check date quality wheather it contains too old age or not
 -- or also check date must not lie in future date
 
 SELECT *
 FROM bronze.erp_cust_az12
 WHERE bdate < 1800-05-01 or bdate > current_date()  ;        -- yeah there are some invalid date detacted here lets fix this
                                                             -- there are 3 option left here changed to null , ask expert,leave it as bad data 
               
-- check for gender
SELECT  DISTINCT gen from  bronze.erp_cust_az12   ;

												-- here a lot of issue detected fullfoem,abbreviated,empty strig
   SELECT  distinct
   gen,
		CASE 
	WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female'      -- correcting gen columns data
   	WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12;
                           -- now gen sorted

SELECT *
FROM silver.erp_cust_az12 ;  -- NOW AGAIN QUALITY CHECK 


SELECT DISTINCT gen from silver.erp_cust_az12   ;            -- checked fine

           
select bdate
from silver.erp_cust_az12 
where bdate > current_date();                                -- no result fine 

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- CLEANSING and checkups  silver table 5--
-- sid column is connecting column in cst_info table with cst_key so match these

SELECT 
	sid,
    cntry
FROM silver.erp_loc_a101;

select cst_key from silver.crm_cust_info;
                                             -- only difference i could see is hypen after 2nd character so fix this and cnvert into ''nothing
SELECT 
	REPLACE(sid,'-','') AS sid,
    cntry
FROM bronze.erp_loc_a101;

--  NOW CHECK all values are similar to both table or not if not then do something
-- EX[ECTATION : NO RESULT

  SELECT 
	REPLACE(sid,'-','') AS sid,
    cntry
FROM silver.erp_loc_a101  
WHERE REPLACE(sid,'-','') NOT IN (select cst_key from silver.crm_cust_info);       -- DONE NO RESULT FOUND 

-- CHECK 2ND COLUMNS ALL POSSIBLES CALUES

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;
                         -- detacted a lot of inconsentency in abbreviaions and full forms and empty string
                         
       SELECT distinct
       cntry ,
        CASE                                                   
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'                      -- fix abbreviations
		WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry) = '' or null THEN 'N\A'
        ELSE TRIM(cntry)
	END AS cntry
    FROM bronze.erp_loc_a101 ;

-- =====================================================================================================
-- all done
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- SILVER TABLE 6 CLEANSING and checkups --
SELECT *
FROM bronze.erp_px_cat_g1v2;

-- 1st column is a connecting one match from other wheather similar or not
SELECT id
FROM bronze.erp_px_cat_g1v2;

select cat_id
from silver.crm_prd_info;
                            -- no problem in matching syntax 
-- check all are present on other table or not
SELECT id
FROM bronze.erp_px_cat_g1v2
where id NOT IN (select cat_id from silver.crm_prd_info);     -- ONE RESULT FOUND WHICH IN NOT SIMILAR

-- CHECK NEXT 2 columns which contains string check spaces

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) or subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);             -- no extra spaces result found
  
  -- check data standardition and quality 2nd and 3rd an d4th
  SELECT DISTINCT 
	-- cat
	subcat
 FROM bronze.erp_px_cat_g1v2 ;          -- all seems good
 -- check last column as distinct
 SELECT DISTINCT maintenance                                  -- all fine 
 FROM bronze.erp_px_cat_g1v2;
