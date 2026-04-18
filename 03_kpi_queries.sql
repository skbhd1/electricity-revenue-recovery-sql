-- ============================================================
-- 03_kpi_queries.sql
-- Core Business KPI Queries
-- Answers: How much was billed? How much collected?
--          Where is the revenue gap? Who owes the most?
-- ============================================================

USE electricity_revenue_sql;

-- ── Q1: OVERALL PORTFOLIO SUMMARY ────────────────────────────
-- Total billing, collection, and recovery gap across all accounts
SELECT
    COUNT(DISTINCT c.customer_id)               AS total_customers,
    COUNT(b.bill_id)                             AS total_bills,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed_inr,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_collected_inr,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS recovery_gap_inr,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
FROM customers c
JOIN bills b ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id = p.bill_id;

-- ── Q2: MONTHLY BILLING VS COLLECTION TREND ──────────────────
-- Month-over-month performance
SELECT
    DATE_FORMAT(b.bill_month, '%b %Y')          AS bill_month,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_collected,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS gap,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
FROM bills b
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY b.bill_month
ORDER BY b.bill_month;

-- ── Q3: CATEGORY-WISE BILLING & COLLECTIONS ──────────────────
-- Which customer category generates the most revenue?
-- Which has the worst collection rate?
SELECT
    c.account_category,
    COUNT(DISTINCT c.customer_id)               AS customers,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_collected,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS recovery_gap,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct,
    ROUND(SUM(b.surcharge_amount), 2)            AS total_surcharge_collected
FROM customers c
JOIN bills b ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY c.account_category
ORDER BY recovery_gap DESC;

-- ── Q4: REGION-WISE REVENUE LEAKAGE ──────────────────────────
-- Which regions are underperforming on collections?
SELECT
    r.region_name,
    r.urban_rural,
    COUNT(DISTINCT c.customer_id)               AS customers,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_collected,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS revenue_leakage,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
FROM regions r
JOIN customers c  ON r.region_id  = c.region_id
JOIN bills b      ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id  = p.bill_id
GROUP BY r.region_id, r.region_name, r.urban_rural
ORDER BY revenue_leakage DESC;

-- ── Q5: TOP 10 HIGH-VALUE DEFAULTERS ─────────────────────────
-- Priority recovery targets sorted by outstanding amount
SELECT
    c.customer_no,
    c.customer_name,
    c.account_category,
    r.region_name,
    COUNT(b.bill_id)                             AS overdue_bills,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_paid,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding_amount,
    c.has_id_proof,
    c.connection_status
FROM customers c
JOIN regions r        ON c.region_id   = r.region_id
JOIN bills b          ON c.customer_id = b.customer_id
LEFT JOIN payments p  ON b.bill_id     = p.bill_id
WHERE b.bill_status IN ('Overdue', 'Partially Paid')
GROUP BY c.customer_id, c.customer_no, c.customer_name,
         c.account_category, r.region_name,
         c.has_id_proof, c.connection_status
ORDER BY outstanding_amount DESC
LIMIT 10;

-- ── Q6: BILL STATUS BREAKDOWN ────────────────────────────────
SELECT
    bill_status,
    COUNT(*)                                     AS bill_count,
    ROUND(SUM(total_bill_amount), 2)             AS total_amount,
    ROUND(SUM(total_bill_amount)
          / (SELECT SUM(total_bill_amount) FROM bills) * 100, 2) AS pct_of_total
FROM bills
GROUP BY bill_status
ORDER BY total_amount DESC;

-- ── Q7: ID PROOF IMPACT ON COLLECTIONS ───────────────────────
-- Do customers without ID proof default more?
SELECT
    CASE WHEN c.has_id_proof = 1 THEN 'Has ID Proof'
         ELSE 'No ID Proof' END                  AS id_status,
    COUNT(DISTINCT c.customer_id)               AS customers,
    ROUND(SUM(b.total_bill_amount), 2)           AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2)   AS total_collected,
    ROUND(COALESCE(SUM(p.amount_paid), 0)
          / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct,
    ROUND(SUM(b.total_bill_amount)
          - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding
FROM customers c
JOIN bills b ON c.customer_id = b.customer_id
LEFT JOIN payments p ON b.bill_id = p.bill_id
GROUP BY c.has_id_proof;

-- ── Q8: PAYMENT MODE ANALYSIS ────────────────────────────────
SELECT
    payment_mode,
    COUNT(*)                                     AS transactions,
    ROUND(SUM(amount_paid), 2)                   AS total_collected,
    ROUND(AVG(amount_paid), 2)                   AS avg_payment
FROM payments
GROUP BY payment_mode
ORDER BY total_collected DESC;

-- ── Q9: SURCHARGE EXPOSURE BY CATEGORY ───────────────────────
SELECT
    c.account_category,
    COUNT(b.bill_id)                             AS bills_with_surcharge,
    ROUND(SUM(b.surcharge_amount), 2)            AS total_surcharge,
    ROUND(AVG(b.surcharge_amount), 2)            AS avg_surcharge_per_bill
FROM customers c
JOIN bills b ON c.customer_id = b.customer_id
WHERE b.surcharge_amount > 0
GROUP BY c.account_category
ORDER BY total_surcharge DESC;

-- ── Q10: DATA QUALITY CHECK ───────────────────────────────────
-- Identify anomalies in billing data
SELECT
    'Negative bill amounts'     AS check_name,
    COUNT(*)                     AS count_found
FROM bills WHERE total_bill_amount < 0
UNION ALL
SELECT 'Bills without readings', COUNT(*)
FROM bills b
LEFT JOIN meter_readings mr ON b.reading_id = mr.reading_id
WHERE mr.reading_id IS NULL
UNION ALL
SELECT 'Faulty meter readings', COUNT(*)
FROM meter_readings WHERE reading_status = 'Faulty'
UNION ALL
SELECT 'Customers with no ID proof', COUNT(*)
FROM customers WHERE has_id_proof = 0
UNION ALL
SELECT 'Disconnected accounts with overdue bills', COUNT(DISTINCT c.customer_id)
FROM customers c
JOIN bills b ON c.customer_id = b.customer_id
WHERE c.connection_status = 'Disconnected'
AND b.bill_status = 'Overdue';
