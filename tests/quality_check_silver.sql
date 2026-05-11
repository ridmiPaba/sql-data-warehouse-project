/*
==========================================================================
Quality Checks
==========================================================================

Script Purpose:
This script performs various quality checks for data consistency, accuracy,
and stindardization across the 'silver' schema. It includes checks for:
- Nuller duplicate primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders.
- Data consistency between related fields.

Usage Notes:
- Run these checks after data loading Silver Layer.
- Investigate and resolve any discrepancies found during the checks.
========================================================================
*/

-- Check For NULL or Duplicates in Primary Key
-- Ecpectation: No RESult

SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

/*
TRIM()
Removes leading and trailing spaces from a string 

If the original value is not equal to
the same value after trimming,
it means there are spaces!!
*/

-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

/*
Quality Check
Check the consistency of values in low cardinality columns 
*/

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

/*
In our data warehouse,
we aim to store clear and meaningful values
rather than using abbreviated terms
*/



--CHECLING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER

-- Check For NULL or Duplicates in Primary Key
-- Ecpectation: No RESult

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT * FROM silver.crm_cust_info;



-- Check quality of product info dataset

-- Check For NULL or Duplicates in Primary Key for product info dataset
-- Ecpectation: No RESult

SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces in product name
-- Expectation: No Results
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or Negative Numbers
-- Expectation : No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL OR prd_cost = 0


-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

SELECT prd_line
FROM bronze.crm_prd_info
WHERE prd_line IS NULL OR TRIM(prd_line) = ''

-- check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt




-- CHECKING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER product info dataset

-- Check For NULL or Duplicates in Primary Key for product info dataset
-- Ecpectation: No RESult

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces in product name
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or Negative Numbers
-- Expectation : No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL 


-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

SELECT prd_line
FROM silver.crm_prd_info
WHERE prd_line IS NULL OR TRIM(prd_line) = ''

-- check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info





-- Check quality of sales details dataset

-- Check for Invalid Dates
SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0

SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LENGTH(sls_order_dt) !=8 
OR sls_order_dt >20500101 
OR sls_order_dt <19000101

SELECT
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LENGTH(sls_ship_dt) !=8 
OR sls_ship_dt >20500101 
OR sls_ship_dt <19000101 



SELECT
NULLIF(sls_due_dt,0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LENGTH(sls_due_dt) !=8 
OR sls_due_dt >20500101 
OR sls_due_dt <19000101 

-- Check Invalid Date Orders
SELECT
*
FROM bronze.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt



/*
Bussiness Rule
Sales = Quantitiy * Price
Negatives,Zeros,Null are not allowed
*/

-- Check Data Consistency: Between Sales, Quantity, and Price
-- » Sales = Quantity * Price
-- » Values must not be NULL, zero, or negative.
SELECT DISTINCT
sls_sales,
sls_quantitiy,
sls_price 
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantitiy * sls_price
OR sls_sales IS NULL 
OR sls_quantitiy IS NULL
OR sls_price IS NULL

OR TRIM(sls_sales) = ''
OR TRIM(sls_quantitiy) = ''
OR TRIM(sls_price) = ''

OR sls_sales <= 0 
OR sls_quantitiy <= 0 
OR sls_price <= 0 
ORDER BY sls_sales, sls_quantitiy, sls_price


-- CHECKING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER sales details dataset
-- Check for Invalid Dates
SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0

SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LENGTH(sls_order_dt) !=8 
OR sls_order_dt >20500101 
OR sls_order_dt <19000101

SELECT
NULLIF(sls_ship_dt,0) sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LENGTH(sls_ship_dt) !=8 
OR sls_ship_dt >20500101 
OR sls_ship_dt <19000101 



SELECT
NULLIF(sls_due_dt,0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
OR LENGTH(sls_due_dt) !=8 
OR sls_due_dt >20500101 
OR sls_due_dt <19000101 

-- Check Invalid Date Orders
SELECT
*
FROM silver.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt



/*
Bussiness Rule
Sales = Quantitiy * Price
Negatives,Zeros,Null are not allowed
*/

-- Check Data Consistency: Between Sales, Quantity, and Price
-- » Sales = Quantity * Price
-- » Values must not be NULL, zero, or negative.
SELECT DISTINCT
sls_sales,
sls_quantitiy,
sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantitiy * sls_price
OR sls_sales IS NULL 
OR sls_quantitiy IS NULL
OR sls_price IS NULL

OR TRIM(sls_sales) = ''
OR TRIM(sls_quantitiy) = ''
OR TRIM(sls_price) = ''

OR sls_sales <= 0 
OR sls_quantitiy <= 0 
OR sls_price <= 0 
ORDER BY sls_sales, sls_quantitiy, sls_price




-- Check quality of erp_cust_az12 dataset

-- Identify Out-Of-Range Dates
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate <'1924-01-01' OR bdate > CURRENT_DATE()

-- DATA Standardization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12


-- CHECKING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER erp_cust_az12 dataset

-- Identify Out-Of-Range Dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate <'1924-01-01' OR bdate > CURRENT_DATE()

-- DATA Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12



-- Check quality of erp_loc_a101 dataset
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- CHECKING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER erp_loc_a101 dataset
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry


-- Check quality of erp_px_cat_g1v2 dataset
-- Checking for unwanted Spaces

SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT 
cat
FROM bronze.erp_px_cat_g1v2

-- Data Standardization & Consistency
SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2

-- Data Standardization & Consistency
SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT 
    maintenance, 
    LENGTH(maintenance) AS character_length
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
    CASE 
        WHEN maintenance LIKE 'yes%' THEN 'yes'
        WHEN maintenance LIKE 'no%'  THEN 'no'
        ELSE 'n/a'
    END AS maintenance
FROM bronze.erp_px_cat_g1v2;


-- - CHECKING ALL THE QUALITY CHECKING QUERIES TO SILVER LAYER erp_px_cat_g1v2 dataset
-- Checking for unwanted Spaces

SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT 
cat
FROM silver.erp_px_cat_g1v2

-- Data Standardization & Consistency
SELECT DISTINCT 
subcat
FROM silver.erp_px_cat_g1v2

-- Data Standardization & Consistency
SELECT DISTINCT 
maintenance
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT 
    maintenance, 
    LENGTH(maintenance) AS character_length
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
    CASE 
        WHEN maintenance LIKE 'yes%' THEN 'yes'
        WHEN maintenance LIKE 'no%'  THEN 'no'
        ELSE 'n/a'
    END AS maintenance
FROM silver.erp_px_cat_g1v2;

