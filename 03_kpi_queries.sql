USE electricity_revenue_sql;

-- 1. Monthly billing, collection and collection efficiency
SELECT
    b.bill_month,
    ROUND(SUM(b.total_bill_amount), 2) AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS total_collected,
    ROUND(COALESCE(SUM(p.amount_paid), 0) / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
FROM bills b
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY b.bill_month
ORDER BY b.bill_month;

-- 2. Revenue leakage by region
SELECT
    r.region_name,
    ROUND(SUM(b.total_bill_amount), 2) AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS collected_amount,
    ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS revenue_leakage,
    ROUND((SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0)) / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS leakage_pct
FROM bills b
JOIN customers c ON c.customer_id = b.customer_id
JOIN regions r ON r.region_id = c.region_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY r.region_name
ORDER BY revenue_leakage DESC;

-- 3. Category-wise billing and arrears exposure
SELECT
    c.account_category,
    ROUND(SUM(b.total_bill_amount), 2) AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS collected_amount,
    ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding_amount
FROM bills b
JOIN customers c ON c.customer_id = b.customer_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY c.account_category
ORDER BY outstanding_amount DESC;

-- 4. Top recoverable accounts by unpaid amount
SELECT
    c.customer_no,
    c.customer_name,
    c.account_category,
    r.region_name,
    ROUND(SUM(b.total_bill_amount), 2) AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS collected_amount,
    ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS recoverable_amount
FROM bills b
JOIN customers c ON c.customer_id = b.customer_id
JOIN regions r ON r.region_id = c.region_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY c.customer_no, c.customer_name, c.account_category, r.region_name
HAVING recoverable_amount > 0
ORDER BY recoverable_amount DESC
LIMIT 10;

-- 5. Accounts with zero or weak collection performance
SELECT
    c.customer_no,
    c.customer_name,
    ROUND(SUM(b.total_bill_amount), 2) AS total_billed,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS total_paid,
    ROUND(COALESCE(SUM(p.amount_paid), 0) / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_ratio_pct
FROM customers c
JOIN bills b ON b.customer_id = c.customer_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY c.customer_no, c.customer_name
HAVING collection_ratio_pct < 60
ORDER BY collection_ratio_pct ASC, total_billed DESC;

-- 6. Overdue accounts needing field action
SELECT
    c.customer_no,
    c.customer_name,
    c.has_id_proof,
    b.bill_month,
    b.total_bill_amount,
    COALESCE(SUM(p.amount_paid), 0) AS amount_paid,
    b.total_bill_amount - COALESCE(SUM(p.amount_paid), 0) AS overdue_amount,
    DATEDIFF(CURDATE(), b.due_date) AS days_past_due
FROM bills b
JOIN customers c ON c.customer_id = b.customer_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY c.customer_no, c.customer_name, c.has_id_proof, b.bill_month, b.total_bill_amount, b.due_date
HAVING overdue_amount > 0
ORDER BY overdue_amount DESC, days_past_due DESC;

-- 7. Meter issue impact on revenue realization
SELECT
    mr.meter_status,
    COUNT(*) AS reading_count,
    ROUND(SUM(b.total_bill_amount), 2) AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS collected_amount,
    ROUND((SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0)), 2) AS unpaid_amount
FROM meter_readings mr
JOIN bills b ON b.reading_id = mr.reading_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY mr.meter_status
ORDER BY unpaid_amount DESC;
