/*
===================================================================================================
DDL Scripts : Create GOLD Views
===================================================================================================
Script Purpose :
	This script creates views for the GOLD Layer in the data warehouse.
    The GOLD Layer represents the final dimension an dfact tables (Star Schema)
    
    Each View performs transformations and combines data from the Silver layer
    to produce a clean, enrich, and busniess ready dataset.
    
Usage :
	These views can be queried directly for analytics and reporting.
==================================================================================================
*/

-- ====================================================
-- Create Dimension Table: gold.dim_customers
-- ====================================================

DROP VIEW gold.dim_customers;

CREATE VIEW gold.dim_customers AS          -- VIEW CREATED
	SELECT 
	ROW_NUMBER () OVER (ORDER BY cst_id ) AS Customer_key,
	ci.cst_id AS Customer_id,
	ci.cst_key AS Customer_number,
	ci.cst_firstname AS First_name,
	ci.cst_lastname AS Last_name,
	la.cntry AS Country,
	ci.cst_marital_status AS Marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen,'n/a') 
	END as Gender,
	ca.bdate AS Birthdate,
	ci.cst_create_date AS Create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 as ca
	ON ci.cst_key = ca.cid 
LEFT JOIN erp_loc_a101 AS la
	ON ci.cst_key = la.sid;
-- =======================================================================================================================================
-- ====================================================
-- Create Dimension Table: gold.dim_products
-- ====================================================

DROP VIEW gold.dim_products;

CREATE VIEW  gold.dim_products AS
SELECT
	ROW_NUMBER () OVER( ORDER BY prd_start_dt,prd_key ) AS Product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number, 
	pn.prd_nm AS product_name, 
    pn.cat_id AS category_id, 
	pc.cat AS category,
    pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost, 
	pn.prd_line AS product_line, 
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc           
    ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL                            
;


-- ========================================================================================================================================
-- ====================================================
-- Create fact table: gold.fact_sales
-- ====================================================
DROP VIEW gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num As Order_number, 
	pr.product_key ,
	su.customer_key,
	sd.sls_order_dt AS Order_date, 
	sd.sls_ship_dt AS Shipping_date,
	sd.sls_due_dt AS Due_date, 
	sd.sls_sales AS Sales_amount, 
	sd.sls_quantity  AS Quantity,
	sd.sls_price As Price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS su
	ON sd.sls_cust_id = su.customer_id
;

    
    
