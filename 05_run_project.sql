-- ============================================================
-- 05_run_project.sql
-- Master Execution Script — Run Everything In Order
-- Usage: mysql -u root -p < 05_run_project.sql
-- ============================================================

SOURCE 01_schema.sql;
SOURCE 02_sample_data.sql;
SOURCE 03_kpi_queries.sql;
SOURCE 04_advanced_analysis.sql;

-- Final verification
USE electricity_revenue_sql;
SELECT 'Project loaded successfully!' AS status;
SELECT CONCAT(COUNT(*), ' customers loaded') AS customers FROM customers;
SELECT CONCAT(COUNT(*), ' bills loaded')     AS bills     FROM bills;
SELECT CONCAT(COUNT(*), ' payments loaded')  AS payments  FROM payments;

-- Run stored procedure for latest month
CALL sp_region_collection_performance('2026-02-01');

-- Run executive summary view
SELECT * FROM vw_revenue_recovery_summary ORDER BY outstanding DESC;
