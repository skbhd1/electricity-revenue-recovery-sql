-- ============================================================
-- 04_advanced_analysis.sql
-- Advanced SQL Analysis
-- Demonstrates: CTEs, Window Functions, Views,
--               Stored Procedures, Risk Segmentation
-- ============================================================

USE electricity_revenue_sql;

-- ── A1: ARREARS AGING BUCKETS ─────────────────────────────────
-- How long have overdue bills been outstanding?
SELECT
    c.customer_name,
    c.account_category,
    r.region_name,
    b.bill_month,
    b.total_bill_amount,
    COALESCE(SUM(p.amount_paid), 0)                  AS amount_paid,
    b.total_bill_amount - COALESCE(SUM(p.amount_paid), 0) AS outstanding,
    CASE
        WHEN DATEDIFF(CURDATE(), b.due_date) BETWEEN 1  AND 30  THEN '0-30 Days'
        WHEN DATEDIFF(CURDATE(), b.due_date) BETWEEN 31 AND 60  THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), b.due_date) BETWEEN 61 AND 90  THEN '61-90 Days'
        WHEN DATEDIFF(CURDATE(), b.due_date) > 90               THEN '90+ Days'
        ELSE 'Current'
    END                                               AS aging_bucket
FROM customers c
JOIN regions r       ON c.region_id   = r.region_id
JOIN bills b         ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id     = p.bill_id
WHERE b.bill_status IN ('Overdue', 'Partially Paid')
GROUP BY c.customer_id, c.customer_name, c.account_category,
         r.region_name, b.bill_id, b.bill_month,
         b.total_bill_amount, b.due_date
HAVING outstanding > 0
ORDER BY DATEDIFF(CURDATE(), b.due_date) DESC;

-- ── A2: CUSTOMER RISK SEGMENTATION (CTE) ─────────────────────
-- Segment customers into risk tiers for recovery prioritisation
WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.customer_no,
        c.customer_name,
        c.account_category,
        c.connection_status,
        c.has_id_proof,
        r.region_name,
        COUNT(b.bill_id)                              AS total_bills,
        SUM(b.total_bill_amount)                      AS total_billed,
        COALESCE(SUM(p.amount_paid), 0)               AS total_paid,
        SUM(b.total_bill_amount)
            - COALESCE(SUM(p.amount_paid), 0)         AS outstanding,
        SUM(CASE WHEN b.bill_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_count
    FROM customers c
    JOIN regions r       ON c.region_id   = r.region_id
    JOIN bills b         ON c.customer_id = b.customer_id
    LEFT JOIN payments p ON b.bill_id     = p.bill_id
    GROUP BY c.customer_id, c.customer_no, c.customer_name,
             c.account_category, c.connection_status,
             c.has_id_proof, r.region_name
)
SELECT
    customer_no,
    customer_name,
    account_category,
    region_name,
    ROUND(total_billed, 2)     AS total_billed,
    ROUND(outstanding, 2)      AS outstanding,
    overdue_count,
    has_id_proof,
    connection_status,
    CASE
        WHEN outstanding > 50000                        THEN 'CRITICAL'
        WHEN outstanding BETWEEN 10000 AND 50000        THEN 'HIGH'
        WHEN outstanding BETWEEN 3000  AND 9999         THEN 'MEDIUM'
        WHEN outstanding > 0                            THEN 'LOW'
        ELSE 'CLEAR'
    END                        AS risk_tier,
    ROUND(outstanding
          / NULLIF(total_billed, 0) * 100, 2)          AS outstanding_pct
FROM customer_summary
ORDER BY outstanding DESC;

-- ── A3: MONTH-OVER-MONTH BILLING GROWTH (WINDOW FUNCTION) ────
-- Track billing trend by category using LAG()
WITH monthly_category AS (
    SELECT
        c.account_category,
        b.bill_month,
        ROUND(SUM(b.total_bill_amount), 2)        AS monthly_billing
    FROM customers c
    JOIN bills b ON c.customer_id = b.customer_id
    GROUP BY c.account_category, b.bill_month
)
SELECT
    account_category,
    DATE_FORMAT(bill_month, '%b %Y')              AS month,
    monthly_billing,
    LAG(monthly_billing) OVER (
        PARTITION BY account_category
        ORDER BY bill_month)                       AS prev_month_billing,
    ROUND(
        (monthly_billing
         - LAG(monthly_billing) OVER (
               PARTITION BY account_category
               ORDER BY bill_month))
        / NULLIF(LAG(monthly_billing) OVER (
               PARTITION BY account_category
               ORDER BY bill_month), 0) * 100
    , 2)                                           AS mom_growth_pct
FROM monthly_category
ORDER BY account_category, bill_month;

-- ── A4: REGION-WISE TOP DEFAULTER RANKING (WINDOW FUNCTION) ──
-- Rank top defaulters within each region using DENSE_RANK()
WITH region_defaulters AS (
    SELECT
        r.region_name,
        c.customer_name,
        c.account_category,
        ROUND(SUM(b.total_bill_amount)
              - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding
    FROM regions r
    JOIN customers c  ON r.region_id   = c.region_id
    JOIN bills b      ON c.customer_id = b.customer_id
    LEFT JOIN payments p ON b.bill_id  = p.bill_id
    GROUP BY r.region_name, c.customer_id,
             c.customer_name, c.account_category
    HAVING outstanding > 0
)
SELECT
    region_name,
    customer_name,
    account_category,
    outstanding,
    DENSE_RANK() OVER (
        PARTITION BY region_name
        ORDER BY outstanding DESC)                 AS rank_in_region
FROM region_defaulters
ORDER BY region_name, rank_in_region;

-- ── A5: RUNNING TOTAL OF COLLECTIONS PER MONTH ───────────────
SELECT
    DATE_FORMAT(payment_date, '%b %Y')                AS payment_month,
    ROUND(SUM(amount_paid), 2)                         AS monthly_collected,
    ROUND(SUM(SUM(amount_paid)) OVER (
          ORDER BY MIN(payment_date)), 2)              AS running_total_collected
FROM payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY MIN(payment_date);

-- ── A6: METER READING ISSUES AFFECTING REVENUE ───────────────
SELECT
    mr.reading_status,
    COUNT(*)                                      AS reading_count,
    ROUND(SUM(b.total_bill_amount), 2)            AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)    AS collected_amount,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2)  AS gap
FROM meter_readings mr
JOIN bills b         ON mr.reading_id = b.reading_id
LEFT JOIN payments p ON b.bill_id     = p.bill_id
GROUP BY mr.reading_status
ORDER BY gap DESC;

-- ── A7: DISCONNECTION ACTION SUMMARY ─────────────────────────
SELECT
    action_type,
    COUNT(*)                                      AS actions_taken,
    COUNT(DISTINCT customer_id)                   AS unique_customers,
    MIN(action_date)                              AS first_action,
    MAX(action_date)                              AS latest_action
FROM disconnection_actions
GROUP BY action_type
ORDER BY actions_taken DESC;

-- ── VIEW: EXECUTIVE REVENUE RECOVERY SUMMARY ─────────────────
-- BI-ready view for dashboards and management reports
CREATE OR REPLACE VIEW vw_revenue_recovery_summary AS
SELECT
    c.customer_no,
    c.customer_name,
    c.account_category,
    r.region_name,
    r.urban_rural,
    c.connection_status,
    c.has_id_proof,
    ROUND(SUM(b.total_bill_amount), 2)                AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)        AS total_collected,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2)      AS outstanding,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct,
    CASE
        WHEN SUM(b.total_bill_amount)
             - COALESCE(SUM(p.amount_paid), 0) > 50000  THEN 'CRITICAL'
        WHEN SUM(b.total_bill_amount)
             - COALESCE(SUM(p.amount_paid), 0) > 10000  THEN 'HIGH'
        WHEN SUM(b.total_bill_amount)
             - COALESCE(SUM(p.amount_paid), 0) > 3000   THEN 'MEDIUM'
        WHEN SUM(b.total_bill_amount)
             - COALESCE(SUM(p.amount_paid), 0) > 0      THEN 'LOW'
        ELSE 'CLEAR'
    END                                               AS risk_tier
FROM customers c
JOIN regions r       ON c.region_id   = r.region_id
JOIN bills b         ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id     = p.bill_id
GROUP BY c.customer_id, c.customer_no, c.customer_name,
         c.account_category, r.region_name, r.urban_rural,
         c.connection_status, c.has_id_proof;

-- ── STORED PROCEDURE: REGION COLLECTION PERFORMANCE ──────────
-- Pass any bill_month to get that month's regional performance
DROP PROCEDURE IF EXISTS sp_region_collection_performance;

DELIMITER //
CREATE PROCEDURE sp_region_collection_performance(IN p_bill_month DATE)
BEGIN
    SELECT
        r.region_name,
        r.urban_rural,
        COUNT(DISTINCT c.customer_id)                 AS customers,
        ROUND(SUM(b.total_bill_amount), 2)             AS total_billed,
        ROUND(COALESCE(SUM(p.amount_paid), 0), 2)     AS total_collected,
        ROUND(SUM(b.total_bill_amount)
              - COALESCE(SUM(p.amount_paid), 0), 2)   AS outstanding,
        ROUND(COALESCE(SUM(p.amount_paid), 0)
              / NULLIF(SUM(b.total_bill_amount), 0)
              * 100, 2)                                AS collection_rate_pct
    FROM regions r
    JOIN customers c  ON r.region_id   = c.region_id
    JOIN bills b      ON c.customer_id = b.customer_id
    LEFT JOIN payments p ON b.bill_id  = p.bill_id
    WHERE b.bill_month = p_bill_month
    GROUP BY r.region_id, r.region_name, r.urban_rural
    ORDER BY outstanding DESC;
END //
DELIMITER ;

-- Usage:
-- CALL sp_region_collection_performance('2026-02-01');
-- SELECT * FROM vw_revenue_recovery_summary ORDER BY outstanding DESC;
