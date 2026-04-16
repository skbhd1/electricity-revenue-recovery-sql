USE electricity_revenue_sql;

-- 1. Arrears aging bucket for collection prioritization
WITH bill_balance AS (
    SELECT
        b.bill_id,
        b.customer_id,
        b.bill_month,
        b.due_date,
        b.total_bill_amount,
        COALESCE(SUM(p.amount_paid), 0) AS amount_paid,
        b.total_bill_amount - COALESCE(SUM(p.amount_paid), 0) AS outstanding_amount
    FROM bills b
    LEFT JOIN payments p ON p.bill_id = b.bill_id
    GROUP BY b.bill_id, b.customer_id, b.bill_month, b.due_date, b.total_bill_amount
),
aged_balance AS (
    SELECT
        customer_id,
        bill_month,
        outstanding_amount,
        CASE
            WHEN DATEDIFF(CURDATE(), due_date) <= 30 THEN '0-30 Days'
            WHEN DATEDIFF(CURDATE(), due_date) <= 60 THEN '31-60 Days'
            WHEN DATEDIFF(CURDATE(), due_date) <= 90 THEN '61-90 Days'
            ELSE '90+ Days'
        END AS arrears_bucket
    FROM bill_balance
    WHERE outstanding_amount > 0
)
SELECT
    arrears_bucket,
    COUNT(*) AS overdue_bills,
    ROUND(SUM(outstanding_amount), 2) AS outstanding_amount
FROM aged_balance
GROUP BY arrears_bucket
ORDER BY FIELD(arrears_bucket, '0-30 Days', '31-60 Days', '61-90 Days', '90+ Days');

-- 2. Rank top defaulters within each region using window functions
WITH customer_dues AS (
    SELECT
        c.customer_id,
        c.customer_no,
        c.customer_name,
        r.region_name,
        ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding_amount
    FROM customers c
    JOIN regions r ON r.region_id = c.region_id
    JOIN bills b ON b.customer_id = c.customer_id
    LEFT JOIN payments p ON p.bill_id = b.bill_id
    GROUP BY c.customer_id, c.customer_no, c.customer_name, r.region_name
)
SELECT
    region_name,
    customer_no,
    customer_name,
    outstanding_amount,
    DENSE_RANK() OVER (PARTITION BY region_name ORDER BY outstanding_amount DESC) AS region_rank
FROM customer_dues
WHERE outstanding_amount > 0
ORDER BY region_name, region_rank, customer_no;

-- 3. Month-over-month billing growth by account category
WITH monthly_category AS (
    SELECT
        c.account_category,
        b.bill_month,
        ROUND(SUM(b.total_bill_amount), 2) AS billed_amount
    FROM bills b
    JOIN customers c ON c.customer_id = b.customer_id
    GROUP BY c.account_category, b.bill_month
)
SELECT
    account_category,
    bill_month,
    billed_amount,
    LAG(billed_amount) OVER (PARTITION BY account_category ORDER BY bill_month) AS previous_month_billed,
    ROUND(
        (billed_amount - LAG(billed_amount) OVER (PARTITION BY account_category ORDER BY bill_month))
        / NULLIF(LAG(billed_amount) OVER (PARTITION BY account_category ORDER BY bill_month), 0) * 100,
        2
    ) AS growth_pct
FROM monthly_category
ORDER BY account_category, bill_month;

-- 4. Risk segmentation for recovery team
WITH customer_risk AS (
    SELECT
        c.customer_no,
        c.customer_name,
        c.account_category,
        r.region_name,
        c.has_id_proof,
        ROUND(SUM(b.total_bill_amount), 2) AS total_billed,
        ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS total_paid,
        ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding_amount,
        ROUND(COALESCE(SUM(p.amount_paid), 0) / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
    FROM customers c
    JOIN regions r ON r.region_id = c.region_id
    JOIN bills b ON b.customer_id = c.customer_id
    LEFT JOIN payments p ON p.bill_id = b.bill_id
    GROUP BY c.customer_no, c.customer_name, c.account_category, r.region_name, c.has_id_proof
)
SELECT
    customer_no,
    customer_name,
    account_category,
    region_name,
    outstanding_amount,
    collection_rate_pct,
    CASE
        WHEN outstanding_amount >= 20000 AND collection_rate_pct < 60 THEN 'Critical'
        WHEN outstanding_amount >= 8000 AND collection_rate_pct < 75 THEN 'High'
        WHEN outstanding_amount >= 3000 THEN 'Medium'
        ELSE 'Low'
    END AS risk_segment,
    CASE
        WHEN has_id_proof = 0 THEN 'Recovery risk: missing KYC'
        ELSE 'KYC available'
    END AS id_status
FROM customer_risk
ORDER BY outstanding_amount DESC;

-- 5. Executive-ready view for BI tools
CREATE OR REPLACE VIEW vw_revenue_recovery_summary AS
SELECT
    b.bill_month,
    r.region_name,
    c.account_category,
    COUNT(DISTINCT c.customer_id) AS accounts,
    ROUND(SUM(b.total_bill_amount), 2) AS billed_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0), 2) AS collected_amount,
    ROUND(SUM(b.total_bill_amount) - COALESCE(SUM(p.amount_paid), 0), 2) AS outstanding_amount,
    ROUND(COALESCE(SUM(p.amount_paid), 0) / NULLIF(SUM(b.total_bill_amount), 0) * 100, 2) AS collection_rate_pct
FROM bills b
JOIN customers c ON c.customer_id = b.customer_id
JOIN regions r ON r.region_id = c.region_id
LEFT JOIN payments p ON p.bill_id = b.bill_id
GROUP BY b.bill_month, r.region_name, c.account_category;

-- 6. Stored procedure for region performance review
DELIMITER //
CREATE PROCEDURE sp_region_collection_performance(IN p_month DATE)
BEGIN
    SELECT
        region_name,
        accounts,
        billed_amount,
        collected_amount,
        outstanding_amount,
        collection_rate_pct
    FROM vw_revenue_recovery_summary
    WHERE bill_month = p_month
    ORDER BY outstanding_amount DESC, collection_rate_pct ASC;
END //
DELIMITER ;
