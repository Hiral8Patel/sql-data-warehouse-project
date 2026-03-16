/*
================================================================================
Quality Checks
================================================================================
Script Purpose:
	This script performs quality checks to validate the integrity, consistency,
	and accuracy of the Gold Layer. These checks ensures:
	- Uniqueness of surrogate keys in dimension tables.
	- Referential integrity between fact and dimension tables.
	- Validation of relationships in the data model for analytical purposes.

Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Invegtigate and resolve any discrepancies found during the checks.
================================================================================
*/

-- ================================================================================
-- Checking 'gold.dim_customers'
-- ================================================================================
-- Check for duplicate customer records after joining CRM, ERP customer,
-- and location tables. Each customer_id should appear only once.
SELECT cst_id, COUNT(*) FROM(
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_stauts,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON		ci.cst_key = la.cid)t
GROUP BY cst_id
HAVING COUNT (*) > 1

-- Validate gender data integration.
-- Since gender information exists in two sources (CRM and ERP),
-- this logic ensures that CRM is treated as the primary source.
-- If CRM gender is missing or 'N/A', the value from ERP is used.
SELECT 
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr -- crm is the master table
		ELSE COALESCE (ca.gen, 'N/A')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON		ci.cst_key = la.cid
ORDER BY 1,2;

-- Final validation of the Gold customer dimension view.
-- Ensures the view returns clean and unique customer records.
SELECT DISTINCT * FROM gold.dim_customers

-- ================================================================================
-- Checking 'gold.dim_products'
-- ================================================================================

-- Check for duplicate product records after joining product information
-- with category data. Each product_key should appear only once.
SELECT prd_key, COUNT (*) FROM (
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id -- not joining the table on the primary key
WHERE pn.prd_end_dt IS NULL
)t GROUP BY prd_key
HAVING COUNT(*) > 1


-- Validate the final product dimension view.
-- Confirms that the dimension contains the expected cleaned
-- and enriched product records.
SELECT * FROM gold.dim_products

-- ================================================================================
-- Checking 'gold.fact_sales'
-- ================================================================================

-- Validate referential integrity between the fact table and dimensions.
-- This query identifies sales records that do not have a matching
-- product record in the product dimension.
-- If any rows are returned, it indicates missing or mismatched product keys.
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
