# Electricity Revenue Recovery & Billing Intelligence — SQL Project

A production-style MySQL project modelling electricity billing, collections, arrears tracking, and revenue recovery analytics for a utility company.

Built from real-world experience managing billing operations for 50,000+ consumer accounts at TGSPDCL, Telangana.

---

## Business Problem

Electricity distribution companies face a core operational challenge: **billing is not the same as collecting**. Revenue leakage happens when:

- Customers don't pay on time
- High-value accounts accumulate large arrears
- Rural accounts have missing ID documentation
- Faulty meters lead to estimated billing disputes
- Recovery teams lack data to prioritise field visits

This project uses SQL to answer the operational questions that matter:

| Business Question | SQL Technique |
|---|---|
| Which regions have the highest collection gap? | JOINs + GROUP BY |
| Which accounts are highest priority for recovery? | CTEs + ORDER BY |
| How has billing grown month over month? | Window Functions (LAG) |
| Which customers are in each risk tier? | CASE + CTEs |
| What does the arrears aging look like? | DATEDIFF + CASE |
| How do faulty meters impact revenue? | JOINs across 4 tables |

---

## Database Schema

7 related tables in a fully normalised relational design:

```
electricity_revenue_sql/
├── regions                  -- 5 operational circles (Urban/Rural)
├── tariff_plans             -- 5 consumer tariff categories
├── customers                -- 20 consumer accounts
├── meter_readings           -- 120 monthly readings (6 months)
├── bills                    -- 120 monthly bills generated
├── payments                 -- Payment transactions
└── disconnection_actions    -- Field actions on overdue accounts
```

**Entity Relationship:**
```
regions ──< customers >── tariff_plans
customers ──< meter_readings
customers ──< bills >── meter_readings
bills ──< payments
customers ──< disconnection_actions
```

---

## Dataset Overview

| Metric | Value |
|---|---|
| Customers | 20 across 5 categories |
| Regions | 5 (Hyderabad, Warangal, Nalgonda, Siddipet) |
| Billing months | Sep 2025 – Feb 2026 (6 months) |
| Total billed | ~₹48 Lakhs |
| Recovery gap | ~₹8.2 Lakhs |
| High-risk accounts | 8 accounts flagged CRITICAL/HIGH |
| Largest defaulter | Siddipet Cement Works (Industrial) |
| Disconnected accounts | 1 (Yellamma Households — 5 months overdue) |

---

## SQL Skills Demonstrated

### Schema Design
- Normalised relational schema with primary + foreign keys
- ENUM columns for controlled categorical data
- Generated column for `units_consumed` (current - previous reading)
- 11 indexes for query performance optimisation
- `UNIQUE KEY` constraints to prevent duplicate billing records

### KPI Queries (`03_kpi_queries.sql`)
- Overall portfolio billing vs collection summary
- Monthly billing vs collection trend
- Category-wise revenue and recovery gap
- Region-wise revenue leakage analysis
- Top 10 high-value defaulters
- Bill status breakdown
- ID proof impact on collections
- Payment mode distribution
- Surcharge exposure by category
- Data quality anomaly detection

### Advanced Analysis (`04_advanced_analysis.sql`)
- **Arrears aging buckets** — 0-30, 31-60, 61-90, 90+ days using `DATEDIFF`
- **Customer risk segmentation** — CRITICAL / HIGH / MEDIUM / LOW using CTEs and CASE
- **Month-over-month billing growth** — using `LAG()` window function
- **Region-wise defaulter ranking** — using `DENSE_RANK()` window function
- **Running total of collections** — using `SUM() OVER (ORDER BY)`
- **Meter reading issue impact** — linking faulty meters to revenue gap
- **Disconnection action summary** — field team activity analysis
- **BI-ready view** — `vw_revenue_recovery_summary` for dashboard connection
- **Stored procedure** — `sp_region_collection_performance(bill_month)` for monthly reporting

---

## Project Files

```
electricity-revenue-recovery-sql/
├── 01_schema.sql           -- Database + all 7 tables + indexes
├── 02_sample_data.sql      -- Regions, tariffs, customers, readings,
│                              bills, payments, disconnection actions
├── 03_kpi_queries.sql      -- 10 core business KPI queries
├── 04_advanced_analysis.sql-- CTEs, window functions, view, stored procedure
├── 05_run_project.sql      -- Master script to run everything
└── README.md
```

---

## How to Run

### Option 1: Run Everything (Command Line)
```bash
cd electricity-revenue-recovery-sql
mysql -u root -p < 05_run_project.sql
```

### Option 2: Step by Step (MySQL Workbench)
Run files in this order:
1. `01_schema.sql`
2. `02_sample_data.sql`
3. `03_kpi_queries.sql`
4. `04_advanced_analysis.sql`

### Useful Queries to Run After Setup
```sql
-- Executive summary view
SELECT * FROM vw_revenue_recovery_summary ORDER BY outstanding DESC;

-- Monthly region performance
CALL sp_region_collection_performance('2026-02-01');

-- Risk tier breakdown
SELECT risk_tier, COUNT(*), SUM(outstanding)
FROM vw_revenue_recovery_summary
GROUP BY risk_tier ORDER BY SUM(outstanding) DESC;
```

---

## Key Findings from the Data

- **Industrial accounts** (2 customers) account for ~72% of total billing but have the largest outstanding balance due to Siddipet Cement Works dispute
- **Rural accounts** show 30–40% lower collection rates compared to urban circles
- **Accounts without ID proof** have a collection rate ~25% lower than accounts with ID documentation
- **Siddipet Cement Works** — ₹1.47L in overdue bills — legal notice issued, recovery team assigned
- **Yellamma Households** — disconnected after 5 months non-payment, ₹4,590 bad debt
- **Faulty meter readings** (C1017 Borewell) directly linked to billing dispute and 4 months overdue

---

## Related Projects

- **[Electricity Revenue Analytics — Python Pipeline](https://github.com/skbhd1/electricity-revenue-analytics)** — Python + pandas + ML analysis of 138,509 consumer records with Power BI dashboard

---

## About

Built by **Shaik Abdullah** — Data Analyst with 4+ years of experience in electricity billing operations, MIS reporting, and revenue analytics at TGSPDCL, Telangana.

- LinkedIn: [linkedin.com/in/skbhd1-abdullah](https://linkedin.com/in/skbhd1-abdullah)
- GitHub: [github.com/skbhd1](https://github.com/skbhd1)
- Email: skbhd1@gmail.com
