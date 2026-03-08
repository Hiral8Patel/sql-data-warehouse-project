/*
===============================================================================
Data Quality Validation – Bronze vs Silver Layer
===============================================================================

Script Purpose:
This script performs data quality validation checks on the CRM and ERP datasets
by comparing the raw data stored in the Bronze Layer with the cleaned and
standardized data stored in the Silver Layer.

The purpose of these checks is to verify that the data transformation process
performed during the Silver Layer load successfully cleans and standardizes
the data.

The checks focus on identifying common data quality issues such as:
- NULL values in primary keys
- Duplicate records
- Unwanted spaces in text fields
- Invalid categorical values
- Incorrect or inconsistent date formats
- Invalid numeric values such as negative price or quantity
- Data inconsistencies between related fields
- Improperly formatted identifiers
- Non-standardized country names and codes

Usage Notes:
- Run this script after executing the Silver Layer loading procedure.
- Each test is executed on both the Bronze and Silver tables.
- Results from the Bronze layer highlight raw data issues.
- The expectation is that the Silver layer should contain cleaned,
  standardized, and validated data with minimal or no issues.

Expected Result:
Most validation queries on the Silver tables should return no rows or 
cleaned data.
Any returned records indicate remaining data quality issues that need
further investigation.

===============================================================================
*/


-- =============================================================================
-- Checking 'crm_cust_info'
-- =============================================================================
-- Description:
-- This table contains customer master data from the CRM system including
-- personal details such as name, gender, marital status, and creation date.
-- =============================================================================

-- Test 1: NULL Primary Key Check
-- Ensures that every customer record has a valid customer ID.
-- Expectation: No NULL values in cst_id.
	-- before cleaning
	SELECT *
	FROM bronze.crm_cust_info
	WHERE cst_id IS NULL;

	-- after cleaning
	SELECT *
	FROM silver.crm_cust_info
	WHERE cst_id IS NULL;

-- Test 2: Duplicate Customer ID Check
-- Verifies that each customer ID is unique and not duplicated.
-- Expectation: No duplicate cst_id values in the Silver table.
	-- before cleaning
	SELECT cst_id, COUNT(*) AS duplicate_count
	FROM bronze.crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 1;

	-- after cleaning
	SELECT cst_id, COUNT(*) AS duplicate_count
	FROM silver.crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 1;

-- Test 3: Unwanted Spaces in Customer Names
-- Detects leading or trailing spaces in first or last names.
-- Expectation: No records with extra spaces after cleaning.
	-- before cleaning
	SELECT *
	FROM bronze.crm_cust_info
	WHERE cst_firstname LIKE ' %'
	   OR cst_firstname LIKE '% '
	   OR cst_lastname LIKE ' %'
	   OR cst_lastname LIKE '% ';

	-- after cleaning
	SELECT *
	FROM silver.crm_cust_info
	WHERE cst_firstname LIKE ' %'
	   OR cst_firstname LIKE '% '
	   OR cst_lastname LIKE ' %'
	   OR cst_lastname LIKE '% ';

-- Test 4: Marital Status Standardization
-- Validates that marital status values are standardized (e.g., Married/Single).
-- Expectation: Only valid standardized values appear in the Silver table.
	-- before cleaning
	SELECT DISTINCT cst_marital_stauts
	FROM bronze.crm_cust_info;
	
	-- after cleaning
	SELECT DISTINCT cst_marital_stauts
	FROM silver.crm_cust_info;

-- Test 5: Gender Standardization
-- Ensures gender values are properly standardized and consistent.
-- Expectation: Only valid gender categories exist after cleaning.
	-- before cleaning
	SELECT DISTINCT cst_gndr
	FROM bronze.crm_cust_info;

	-- after cleaning
	SELECT DISTINCT cst_gndr
	FROM silver.crm_cust_info;

-- =============================================================================
-- Checking 'crm_prd_info'
-- =============================================================================
-- Description:
-- This table contains product information including product identifiers,
-- product line categories, cost, and product start dates.
-- =============================================================================

-- Test 1: NULL or Negative Product Cost
-- Ensures that product costs are valid numeric values and not negative.
-- Expectation: No NULL or negative product costs in the Silver table.
	-- before cleaning
	SELECT *
	FROM bronze.crm_prd_info
	WHERE prd_cost IS NULL OR prd_cost < 0;

	-- after cleaning
	SELECT *
	FROM silver.crm_prd_info
	WHERE prd_cost IS NULL OR prd_cost < 0;

-- Test 2: Product Line Standardization
-- Verifies that product line codes are properly mapped to standardized names.
-- Expectation: Only valid product line categories exist.
	-- before imporving
	SELECT DISTINCT prd_line
	FROM bronze.crm_prd_info;

	-- after imporving
	SELECT DISTINCT prd_line
	FROM silver.crm_prd_info;

-- Test 3: Duplicate Product Records
-- Checks whether multiple records exist for the same product key.
-- Expectation: No duplicate product keys in the cleaned dataset.
	-- before cleaning
	SELECT prd_key, COUNT(*) AS duplicate_count
	FROM bronze.crm_prd_info
	GROUP BY prd_key
	HAVING COUNT(*) > 1;

	-- after cleaning
	SELECT prd_key, COUNT(*) AS duplicate_count
	FROM silver.crm_prd_info
	GROUP BY prd_key
	HAVING COUNT(*) > 1;

-- Test 4: Invalid Product Start Dates
-- Ensures start dates are valid and not NULL or future dates.
-- Expectation: All product start dates should be valid historical dates.
	-- before cleaning
	SELECT *
	FROM bronze.crm_prd_info
	WHERE prd_start_dt IS NULL OR prd_start_dt > GETDATE();

	--after cleaning
	SELECT *
	FROM silver.crm_prd_info
	WHERE prd_start_dt IS NULL OR prd_start_dt > GETDATE();

-- =============================================================================
-- Checking 'crm_sales_details'
-- =============================================================================
-- Description:
-- This table stores transactional sales information including order dates,
-- shipping dates, quantities, prices, and calculated sales values.
-- =============================================================================

-- Test 1: Invalid Order/ Shipping/ Due Dates Format
-- Ensures order dates follow the expected 8-digit date format.
-- Expectation: All order/ shipping/ due dates should be valid and properly formatted.
	-- before cleaning
	SELECT *
	FROM bronze.crm_sales_details
	WHERE LEN(sls_order_dt) != 8
	   OR sls_order_dt <= 0;

	SELECT *
	FROM bronze.crm_sales_details
	WHERE LEN(sls_ship_dt) != 8
	   OR sls_ship_dt <= 0;

	SELECT *
	FROM bronze.crm_sales_details
	WHERE LEN(sls_due_dt) != 8
	   OR sls_due_dt <= 0;

	-- after cleaning
	SELECT *
	FROM silver.crm_sales_details
	WHERE LEN(sls_order_dt) != 8
	   OR sls_order_dt <= 0;

	SELECT *
	FROM silver.crm_sales_details
	WHERE LEN(sls_ship_dt) != 8
	   OR sls_ship_dt <= 0;

	SELECT *
	FROM silver.crm_sales_details
	WHERE LEN(sls_due_dt) != 8
	   OR sls_due_dt <= 0;

-- Test 2: Sales Amount Consistency
-- Checks that sales amount equals quantity multiplied by price.
-- Expectation: Sales values should match the calculated business rule.
	-- before cleaning
	SELECT *
	FROM bronze.crm_sales_details
	WHERE sls_sales != sls_quantity * ABS(sls_price);

	-- after cleaning
	SELECT *
	FROM silver.crm_sales_details
	WHERE sls_sales <> sls_quantity * ABS(sls_price);

-- Test 3: Invalid Price or Quantity
-- Detects NULL, zero, or negative values in price or quantity fields.
-- Expectation: Price and quantity should always be valid positive numbers.
	-- before cleaning
	SELECT *
	FROM bronze.crm_sales_details
	WHERE sls_price IS NULL
	   OR sls_price <= 0
	   OR sls_quantity IS NULL
	   OR sls_quantity < 0;

	-- after cleaning
	SELECT *
	FROM silver.crm_sales_details
	WHERE sls_price IS NULL
	   OR sls_price <= 0
	   OR sls_quantity IS NULL
	   OR sls_quantity < 0;

-- =============================================================================
-- Checking 'erp_cust_az12'
-- =============================================================================
-- Description:
-- This table contains additional customer demographic information extracted
-- from the ERP system including birth date and gender.
-- =============================================================================

-- Test 1: Invalid Customer ID Format
-- Detects customer IDs containing system prefixes such as 'NAS'.
-- Expectation: Customer IDs should be cleaned and standardized.
	-- before cleaning
	SELECT *
	FROM bronze.erp_cust_az12
	WHERE cid LIKE 'NAS%';

	-- after cleaning
	SELECT *
	FROM silver.erp_cust_az12
	WHERE cid LIKE 'NAS%';

-- Test 2: Future Birth Date Check
-- Ensures birth dates are not set in the future.
-- Expectation: All birth dates should be valid past dates.
	-- before cleaning
	SELECT *
	FROM bronze.erp_cust_az12
	WHERE bdate > GETDATE();

	-- after cleaning
	SELECT *
	FROM silver.erp_cust_az12
	WHERE bdate > GETDATE();

-- Test 3: Invalid Gender Values
-- Verifies gender values are standardized and valid.
-- Expectation: Only accepted gender values appear after cleaning.
	-- before cleaning
	SELECT DISTINCT gen
	FROM bronze.erp_cust_az12
	WHERE UPPER(TRIM(gen)) NOT IN ('M','MALE','F','FEMALE')
	   OR gen IS NULL;

	-- after cleaning
	SELECT DISTINCT gen
	FROM silver.erp_cust_az12
	WHERE UPPER(TRIM(gen)) NOT IN ('M','MALE','F','FEMALE','N/A');

-- =============================================================================
-- Checking 'erp_loc_a101'
-- =============================================================================
-- Description:
-- This table contains customer location data from the ERP system,
-- primarily focusing on country information.
-- =============================================================================

-- Test: Country Name Standardization
-- Identifies inconsistent or abbreviated country names.
-- Expectation: Country names should be standardized (e.g., Germany, United States).
	-- before cleaning
	SELECT DISTINCT cntry
	FROM bronze.erp_loc_a101

	-- after cleaning
	SELECT DISTINCT cntry
	FROM silver.erp_loc_a101;

-- =============================================================================
-- Checking 'erp_px_cat_g1v2'
-- =============================================================================
-- Description:
-- This table contains product category and subcategory information
-- used for product classification.
-- =============================================================================

-- Test : NULL or Duplicate Category ID Check
-- Ensures that each category record has a valid identifier.
-- Verifies that category identifiers are unique.
-- Expectation: No NULL or duplicate values in the category ID.
	SELECT *
	FROM bronze.erp_px_cat_g1v2
	WHERE id IS NULL;

	SELECT id, COUNT(*) AS duplicate_count
	FROM bronze.erp_px_cat_g1v2
	GROUP BY id
	HAVING COUNT(*) > 1;
