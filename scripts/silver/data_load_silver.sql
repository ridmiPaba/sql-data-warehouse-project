/*
=============================================================
Script: Load Silver Layer Data (Source -> Silver)
=============================================================
Script Purpose:
    This script loads data into the 'silver' database from
    external CSV files. It performs the following actions:
    - Calls the silver.load_silver() procedure to truncate tables.
    - Uses LOAD DATA LOCAL INFILE to load data from CSV files
      into silver tables.
    - Tracks and displays load duration for each table.
    - Displays total load duration at the end.

Note:
    This script must be run from the terminal using:
    mysql -u root -p --local-infile=1 < data_load_silver.sql. This is 
    because SQLTools MySQL driver v2.0+ does not support 
    LOAD DATA LOCAL INFILE directly.

Parameters:
    None.

Usage Example:
    mysql -u root -p --local-infile=1 < data_load_silver.sql
=============================================================
*/

SET @batch_start_time =  NOW();

-- Call procedure first to truncate tables
CALL silver.load_silver();

-- Then load data
SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.crm_cust_info' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE silver.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';

SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.crm_prd_info' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE silver.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';

SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.crm_sales_details' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE silver.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';




SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.erp_cust_az12' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
INTO TABLE silver.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';


SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.erp_loc_a101' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
INTO TABLE silver.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';


SET @start_time = NOW();
SELECT '>>Inserting Data Into: silver.erp_px_cat_g1v2' AS '';
LOAD DATA LOCAL INFILE '/Users/prabhavihemachandra/Desktop/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE silver.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET @end_time = NOW();
SELECT CONCAT('>>Loading Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS '';

SET @batch_end_time =  NOW();

SELECT CONCAT('>>Loading Silver Layer is Comleted - Total Load Duration: ',TIMESTAMPDIFF(SECOND,@Start_time,@end_time), ' seconds') AS ''; 




/*

mysql -u root -p -e "SET GLOBAL local_infile = 1;"  

**Every time you restart MySQL server, local_infile resets to OFF.
 So you have to run it every time.


create the procedure:

mysql -u root -p < /Users/prabhavihemachandra/Desktop/DataAnalyst_Portfolio/procedure_silver.sql

Every time you want to load data:
mysql -u root -p --local-infile=1 < /Users/prabhavihemachandra/Desktop/DataAnalyst_Portfolio/data_load_silver.sql

Now verify the data is actually there:
mysql -u root -p -e "
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM silver.crm_cust_info UNION ALL
SELECT 'crm_prd_info', COUNT(*) FROM silver.crm_prd_info UNION ALL
SELECT 'crm_sales_details', COUNT(*) FROM silver.crm_sales_details UNION ALL
SELECT 'erp_cust_az12', COUNT(*) FROM silver.erp_cust_az12 UNION ALL
SELECT 'erp_loc_a101', COUNT(*) FROM silver.erp_loc_a101 UNION ALL
SELECT 'erp_px_cat_g1v2', COUNT(*) FROM silver.erp_px_cat_g1v2; 
"
*/


/*Breaking down the full command:

mysql -u root -p --local-infile=1 -e "your sql here"

Part                 Meaning
mysql                start the MySQL program
-u root              username = root
-p                   ask for password
--local-infile=1     enable loading local files from your computer (1 = ON)
-e                   execute this SQL command and exit
"your sql here"the   actual SQL query to run

Without -e, MySQL would stay open waiting for more commands (that's the interactive shell).
With -e it runs the query and exits automatically.

*/



