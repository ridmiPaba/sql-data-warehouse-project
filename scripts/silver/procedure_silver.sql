/*
=============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=============================================================
Script Purpose:
This stored procedure performs the ETL process that populates
the 'silver' schema from the 'bronze' schema. For each table,
the procedure:
  - Truncates the target silver table.
  - Reads raw data from the corresponding bronze table.
  - Applies cleaning and standardization transformations such
    as trimming whitespace, normalizing coded values to readable
    labels, deduplicating by latest record, validating dates,
    deriving missing fields, and handling NULL/invalid inputs.
  - Inserts the cleaned, transformed rows into the silver table.
  - Prints truncating and inserting status messages.
  - Catches and reports errors via a SQLEXCEPTION EXIT HANDLER,
    surfacing the error message, MySQL error number, and SQL state.

Source: bronze.* tables (raw data loaded from CSV files)
Target: silver.* tables (cleaned, standardized data)

Note:
The silver layer reads from bronze tables only — never from CSV
files directly. CSV loading is the responsibility of the bronze
pipeline (load_bronze.sql). The MySQL restriction that disallows
LOAD DATA inside stored procedures therefore does not apply here,
because the silver procedure performs no file I/O.

Parameters:
None. This procedure does not accept any parameters and does
not return any values.

Usage Example:
CALL silver.load_silver();
=============================================================
*/

-- DELIMITER is required because the procedure body contains many
-- semicolons (one after each internal statement). Without changing
-- the delimiter, MySQL's parser would terminate the CREATE PROCEDURE
-- statement at the first internal ';' and raise a syntax error.
-- The delimiter is temporarily changed to '$$' for the duration of
-- the procedure definition, then restored to ';' afterwards.


-- =============================================================
-- SILVER LAYER: combined procedure definition + execution
-- Reads from bronze.* tables, applies cleaning, writes to silver.*
-- =============================================================

DROP PROCEDURE IF EXISTS silver.load_silver;

DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
    DECLARE v_error_msg   VARCHAR(500);
    DECLARE v_error_state VARCHAR(10);
    DECLARE v_error_code  INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_msg   = MESSAGE_TEXT,
            v_error_state = RETURNED_SQLSTATE,
            v_error_code  = MYSQL_ERRNO;
        SELECT '=============================' AS '';
        SELECT 'ERROR OCCURRED DURING LOADING SILVER LAYER' AS '';
        SELECT CONCAT('Error Message : ', v_error_msg)   AS '';
        SELECT CONCAT('Error Number  : ', v_error_code)  AS '';
        SELECT CONCAT('Error State   : ', v_error_state) AS '';
        SELECT '=============================' AS '';
    END;

    SELECT '============================' AS '';
    SELECT 'Loading Silver Layer'         AS '';
    SELECT '============================' AS '';

    SELECT '============================' AS '';
    SELECT 'Loading CRM Tables'           AS '';
    SELECT '============================' AS '';

    -- ---------- silver.crm_cust_info ----------
    SELECT '>>Truncating Table: silver.crm_cust_info' AS '';
    TRUNCATE TABLE silver.crm_cust_info;

    SELECT '>>Inserting Data Into: silver.crm_cust_info' AS '';
    INSERT INTO silver.crm_cust_info(
        cst_id, cst_key, cst_firstname, cst_lastname,
        cst_maritial_status, cst_gndr, cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_maritial_status)) = 'S' THEN 'Single'
             WHEN UPPER(TRIM(cst_maritial_status)) = 'M' THEN 'Married'
             ELSE 'n/a'
        END AS cst_maritial_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
             WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
             ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_maritial_status, cst_gndr,
            CASE WHEN cst_create_date LIKE '%0000-00-00%' THEN NULL
                 ELSE cst_create_date
            END AS cst_create_date,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY CASE WHEN cst_create_date LIKE '%0000-00-00%' THEN NULL
                              ELSE cst_create_date END DESC
            ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL AND cst_id != 0
    ) t
    WHERE flag_last = 1;

    -- ---------- silver.crm_prd_info ----------
    SELECT '>>Truncating Table: silver.crm_prd_info' AS '';
    TRUNCATE TABLE silver.crm_prd_info;

    SELECT '>>Inserting Data Into: silver.crm_prd_info' AS '';
    INSERT INTO silver.crm_prd_info(
        prd_id, cat_id, prd_key, prd_nm, prd_cost,
        prd_line, prd_start_dt, prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key))      AS prd_key,
        prd_nm,
        prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        prd_start_dt,
        DATE_SUB(
            LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
            INTERVAL 1 DAY
        ) AS prd_end_dt
    FROM bronze.crm_prd_info;

    -- ---------- silver.crm_sales_details ----------
    SELECT '>>Truncating Table: silver.crm_sales_details' AS '';
    TRUNCATE TABLE silver.crm_sales_details;

    SELECT '>>Inserting Data Into: silver.crm_sales_details' AS '';
    INSERT INTO silver.crm_sales_details(
        sls_ord_num, sls_prd_key, sls_cust_id,
        sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantitiy, sls_price
    )
    SELECT
        sls_ord_num, sls_prd_key, sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
             ELSE CAST(sls_order_dt AS DATE)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
             ELSE CAST(sls_ship_dt AS DATE)
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
             ELSE CAST(sls_due_dt AS DATE)
        END AS sls_due_dt,
        CASE WHEN old_sls_sales IS NULL OR old_sls_sales <= 0
                  OR old_sls_sales != sls_quantitiy * ABS(sls_price)
             THEN sls_quantitiy * ABS(sls_price)
             ELSE old_sls_sales
        END AS sls_sales,
        sls_quantitiy,
        sls_price
    FROM (
        SELECT
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales AS old_sls_sales,
            sls_quantitiy,
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                 THEN sls_sales / NULLIF(sls_quantitiy, 0)
                 ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details
    ) t;

    SELECT '============================' AS '';
    SELECT 'Loading ERP Tables'           AS '';
    SELECT '============================' AS '';

    -- ---------- silver.erp_cust_az12 ----------
    SELECT '>>Truncating Table: silver.erp_cust_az12' AS '';
    TRUNCATE TABLE silver.erp_cust_az12;

    SELECT '>>Inserting Data Into: silver.erp_cust_az12' AS '';
    INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
             ELSE cid
        END AS cid,
        CASE WHEN bdate > CURRENT_DATE() THEN NULL
             ELSE bdate
        END AS bdate,
        CASE WHEN UPPER(gen) LIKE 'F%' THEN 'Female'
             WHEN UPPER(gen) LIKE 'M%' THEN 'Male'
             ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;

    -- ---------- silver.erp_loc_a101 ----------
    SELECT '>>Truncating Table: silver.erp_loc_a101' AS '';
    TRUNCATE TABLE silver.erp_loc_a101;

    SELECT '>>Inserting Data Into: silver.erp_loc_a101' AS '';
    INSERT INTO silver.erp_loc_a101(cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '') = 'DE' THEN 'Germany'
            WHEN REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '') IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE REPLACE(REPLACE(TRIM(cntry), '\r', ''), '\n', '')
        END AS cntry
    FROM bronze.erp_loc_a101;

    -- ---------- silver.erp_px_cat_g1v2 ----------
    SELECT '>>Truncating Table: silver.erp_px_cat_g1v2' AS '';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    SELECT '>>Inserting Data Into: silver.erp_px_cat_g1v2' AS '';
    INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
    SELECT
        id,
        cat,
        subcat,
        CASE WHEN maintenance LIKE 'yes%' THEN 'yes'
             WHEN maintenance LIKE 'no%'  THEN 'no'
             ELSE 'n/a'
        END AS maintenance
    FROM bronze.erp_px_cat_g1v2;

END$$

DELIMITER ;

-- =============================================================
-- Execute the procedure and report total duration
-- =============================================================

SET @batch_start_time = NOW();

CALL silver.load_silver();

SET @batch_end_time = NOW();

SELECT CONCAT('>>Silver Load Total Duration: ',
              TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time),
              ' seconds') AS '';
