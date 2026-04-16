SOURCE 01_schema.sql;
SOURCE 02_sample_data.sql;
SOURCE 03_kpi_queries.sql;
SOURCE 04_advanced_analysis.sql;

-- Example procedure call
CALL sp_region_collection_performance('2026-02-01');

-- Example BI-ready view query
SELECT * FROM vw_revenue_recovery_summary ORDER BY bill_month, region_name, account_category;
