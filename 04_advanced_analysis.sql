USE electricity_revenue_sql;

-- 1. Rank categories by 90-day debt contribution
SELECT
    account_category,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(SUM(total_90_debt) / SUM(SUM(total_90_debt)) OVER () * 100, 2) AS debt_share_pct,
    DENSE_RANK() OVER (ORDER BY SUM(total_90_debt) DESC) AS debt_rank
FROM electricity_revenue_analysis
GROUP BY account_category
ORDER BY debt_rank;

-- 2. Consumer risk segmentation using debt and collection behavior
WITH risk_base AS (
    SELECT
        record_id,
        account_category,
        total_billing,
        total_receipting,
        total_90_debt,
        total_write_off,
        collection_ratio,
        debt_billing_ratio,
        has_id_no,
        bad_debt,
        NTILE(4) OVER (ORDER BY total_90_debt DESC) AS debt_quartile
    FROM electricity_revenue_analysis
)
SELECT
    debt_quartile,
    COUNT(*) AS accounts,
    ROUND(AVG(collection_ratio), 2) AS avg_collection_ratio,
    ROUND(AVG(debt_billing_ratio), 2) AS avg_debt_billing_ratio,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt
FROM risk_base
GROUP BY debt_quartile
ORDER BY debt_quartile;

-- 3. Property value band analysis
SELECT
    CASE
        WHEN property_value = 0 THEN 'No Property Value'
        WHEN property_value < 100000 THEN 'Below 100K'
        WHEN property_value < 500000 THEN '100K-500K'
        WHEN property_value < 1000000 THEN '500K-1M'
        ELSE 'Above 1M'
    END AS property_value_band,
    COUNT(*) AS accounts,
    ROUND(SUM(total_billing), 2) AS total_billing,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(AVG(collection_ratio), 2) AS avg_collection_ratio,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct
FROM electricity_revenue_analysis
GROUP BY property_value_band
ORDER BY total_90_debt DESC;

-- 4. Categories where no-ID accounts increase recovery risk
SELECT
    account_category,
    SUM(CASE WHEN has_id_no = 0 THEN 1 ELSE 0 END) AS no_id_accounts,
    ROUND(AVG(CASE WHEN has_id_no = 0 THEN bad_debt END) * 100, 2) AS no_id_bad_debt_rate_pct,
    ROUND(AVG(CASE WHEN has_id_no = 1 THEN bad_debt END) * 100, 2) AS id_bad_debt_rate_pct
FROM electricity_revenue_analysis
GROUP BY account_category
HAVING no_id_accounts > 0
ORDER BY no_id_bad_debt_rate_pct DESC;

-- 5. BI-ready category summary view
CREATE OR REPLACE VIEW vw_category_revenue_summary AS
SELECT
    account_category_id,
    account_category,
    acc_cat_abbr,
    COUNT(*) AS accounts,
    ROUND(SUM(total_billing), 2) AS total_billing,
    ROUND(SUM(total_receipting), 2) AS total_receipting,
    ROUND(SUM(total_90_debt), 2) AS total_90_debt,
    ROUND(SUM(total_write_off), 2) AS total_write_off,
    ROUND(SUM(total_receipting) / NULLIF(SUM(total_billing), 0) * 100, 2) AS collection_rate_pct,
    ROUND(AVG(collection_ratio), 2) AS avg_collection_ratio,
    ROUND(AVG(debt_billing_ratio), 2) AS avg_debt_billing_ratio,
    ROUND(AVG(bad_debt) * 100, 2) AS bad_debt_rate_pct,
    ROUND(AVG(has_id_no) * 100, 2) AS has_id_coverage_pct
FROM electricity_revenue_analysis
GROUP BY account_category_id, account_category, acc_cat_abbr;

-- 6. Stored procedure to review categories above a debt threshold
DELIMITER //
CREATE PROCEDURE sp_high_debt_categories(IN p_min_total_debt DECIMAL(18,2))
BEGIN
    SELECT
        account_category,
        accounts,
        total_billing,
        total_receipting,
        total_90_debt,
        collection_rate_pct,
        bad_debt_rate_pct
    FROM vw_category_revenue_summary
    WHERE total_90_debt >= p_min_total_debt
    ORDER BY total_90_debt DESC;
END //
DELIMITER ;
