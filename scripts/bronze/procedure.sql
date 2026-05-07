/*
Stored Procedure: Load Bronze Layer (Source - Bronze)
--------
Script Purpose:
This stored procedure loads data into the 'bronze' database
from external CSV files. It performs the following actions:
- Truncates the bronze tables before loading fresh data.
- Prints truncating status messages for each table.
- Handles errors using MySQL exception handler.

Note:
In MySQL, LOAD DATA is not allowed inside stored procedures.
Therefore this procedure only handles TRUNCATING tables.
The actual data loading is done in "load_bronze. sql'.

Parameters:
None. This procedure does not accept any parameters or return any values.

Usage Example:
CALL bronze.load_bronze ();
===-
*/


-- MySQL needs DELIMITER because a procedure contains multiple semicolons (;)
-- Without this, MySQL would stop reading at the first ; and never finish the procedure
-- So we temporarily change the end signal from ; to $$ while creating the procedure


DELIMITER $$

DROP PROCEDURE IF EXISTS bronze.load_bronze$$

CREATE PROCEDURE bronze.load_bronze()
BEGIN
    DECLARE v_error_msg VARCHAR(500);
    DECLARE v_error_state VARCHAR(10);
    DECLARE v_error_code INT;
   
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_msg   = MESSAGE_TEXT ,
            v_error_state = RETURNED_SQLSTATE ,
            v_error_code = MySQL_ERRNO ;
        SELECT '=============================' AS '';
        SELECT 'ERROR OCCURED DURING LOADING BRONZE LAYER' AS '';
        SELECT CONCAT('Error Message :',v_error_msg) AS '';
        SELECT CONCAT('Error Number :', v_error_code) AS '' ;
        SELECT CONCAT('Error State :', v_error_state) AS '' ;
        SELECT '=============================' AS '';

    END;

    SELECT '============================' AS '';
    SELECT 'Loading Bronze Layer' AS '';
    SELECT '============================' AS '';

    SELECT '============================' AS '';
    SELECT'Loading CRM Tables' AS '';
    SELECT '============================' AS '';

   
    SELECT '>>Truncating Table: bronze.crm_cust_info' AS '';
    TRUNCATE TABLE bronze.crm_cust_info;
    
    SELECT '>>Truncating Table: bronze.crm_prd_info' AS '';
    TRUNCATE TABLE bronze.crm_prd_info;
  
    SELECT '>>Truncating Table: bronze.crm_sales_details' AS '';
    TRUNCATE TABLE bronze.crm_sales_details;
    

    SELECT'============================' AS '';
    SELECT 'Loading ERP Tables ' AS '';
    SELECT '============================' AS '';
    
   
    SELECT '>>Truncating Table: bronze.erp_cust_az12' AS '';
    TRUNCATE TABLE bronze.erp_cust_az12;
   
   
    SELECT '>>Truncating Table: bronze.erp_loc_a101' AS '';
    TRUNCATE TABLE bronze.erp_loc_a101;
    
   
    SELECT '>>Truncating Table: bronze.erp_px_cat_g1v2' AS '';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
   
END$$      -- End of procedure

DELIMITER ; -- Change back to normal semicolon
