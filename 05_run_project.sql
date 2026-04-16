SOURCE 01_schema.sql;
SOURCE 02_load_actual_data.sql;
SOURCE 03_kpi_queries.sql;
SOURCE 04_advanced_analysis.sql;

-- Example procedure call
CALL sp_high_debt_categories(10000000);

-- Example BI-ready query
SELECT * FROM vw_category_revenue_summary ORDER BY total_90_debt DESC;
