USE electricity_revenue_sql;

-- 1. Overall portfolio KPI summary
SELECT
    COUNT(*) AS total_accounts,
    ROUND(SUM(total_billing), 2) AS total_billing,
    ROUND(SUM(total_receipting), 2) AS total_receipting,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(SUM(total_write_off), 2) AS total_write_off,
    ROUND(SUM(total_receipting) / NULLIF(SUM(total_billing), 0) * 100, 2) AS weighted_collection_rate_pct,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct,
    ROUND(AVG(has_id_no) * 100, 2) AS has_id_coverage_pct
FROM electricity_revenue_analysis;

-- 2. Category-wise revenue and debt summary
SELECT
    account_category,
    COUNT(*) AS accounts,
    ROUND(SUM(total_billing), 2) AS total_billing,
    ROUND(SUM(total_receipting), 2) AS total_receipting,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(SUM(total_write_off), 2) AS total_write_off,
    ROUND(SUM(total_receipting) / NULLIF(SUM(total_billing), 0) * 100, 2) AS collection_rate_pct,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct
FROM electricity_revenue_analysis
GROUP BY account_category
ORDER BY total_90_debt DESC;

-- 3. Collection performance by ID availability
SELECT
    CASE WHEN has_id_no = 1 THEN 'Has ID' ELSE 'No ID' END AS id_status,
    COUNT(*) AS accounts,
    ROUND(SUM(total_billing), 2) AS total_billing,
    ROUND(SUM(total_receipting), 2) AS total_receipting,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(SUM(total_receipting) / NULLIF(SUM(total_billing), 0) * 100, 2) AS collection_rate_pct,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct
FROM electricity_revenue_analysis
GROUP BY has_id_no
ORDER BY bad_debt_rate_pct DESC;

-- 4. Top 20 high-risk consumer records by debt exposure
SELECT
    record_id,
    account_category,
    acc_cat_abbr,
    total_billing,
    total_receipting,
    total_90_debt,
    total_write_off,
    collection_ratio,
    debt_billing_ratio,
    has_id_no,
    bad_debt
FROM electricity_revenue_analysis
ORDER BY total_90_debt DESC, collection_ratio ASC
LIMIT 20;

-- 5. Categories with the largest recoverable revenue gap
SELECT
    account_category,
    ROUND(SUM(total_billing - total_receipting), 2) AS recoverable_revenue_gap,
    ROUND(AVG(collection_ratio), 2) AS avg_collection_ratio,
    ROUND(AVG(debt_billing_ratio), 2) AS avg_debt_billing_ratio
FROM electricity_revenue_analysis
GROUP BY account_category
ORDER BY recoverable_revenue_gap DESC;

-- 6. Write-off concentration by account category
SELECT
    account_category,
    ROUND(SUM(total_write_off), 2) AS total_write_off,
    ROUND(SUM(total_write_off) / NULLIF(SUM(total_billing), 0) * 100, 2) AS write_off_to_billing_pct
FROM electricity_revenue_analysis
GROUP BY account_category
HAVING total_write_off > 0
ORDER BY total_write_off DESC;

-- 7. Data quality and anomaly check
SELECT
    SUM(CASE WHEN collection_ratio < 0 THEN 1 ELSE 0 END) AS negative_collection_ratio_rows,
    SUM(CASE WHEN collection_ratio > 1.5 THEN 1 ELSE 0 END) AS unusually_high_collection_ratio_rows,
    SUM(CASE WHEN total_billing < 0 THEN 1 ELSE 0 END) AS negative_billing_rows,
    SUM(CASE WHEN property_value = 0 THEN 1 ELSE 0 END) AS zero_property_value_rows
FROM electricity_revenue_analysis;
