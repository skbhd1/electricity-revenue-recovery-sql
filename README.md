# Electricity Revenue Recovery & Billing Intelligence SQL Project

MySQL portfolio project focused on how a power utility can improve collections, reduce revenue leakage, and prioritize recovery actions using SQL.

This project complements a broader analytics portfolio by showing the SQL backbone behind electricity billing operations. It models customers, tariffs, meter readings, monthly bills, payments, and disconnection workflows, then uses business SQL queries to identify overdue revenue, weak collection areas, and high-priority recovery accounts.

## Business Problem

Electricity distribution companies do not just need dashboards. They need operational queries that answer questions like:

- Which regions have the highest billing-to-collection gap?
- Which customer categories create the largest arrears burden?
- Which high-value accounts should recovery teams target first?
- How much outstanding revenue sits in each aging bucket?
- Which meter-reading issues are linked to poor revenue realization?

This project is designed to answer those questions in MySQL.

## Project Structure

```text
electricity-revenue-sql-project/
├── 01_schema.sql
├── 02_sample_data.sql
├── 03_kpi_queries.sql
├── 04_advanced_analysis.sql
├── 05_run_project.sql
└── README.md
```

## Data Model

The schema includes these core tables:

- `regions`
- `tariff_plans`
- `customers`
- `meter_readings`
- `bills`
- `payments`
- `disconnection_actions`

This structure supports both transactional reporting and analytical SQL.

## SQL Skills Demonstrated

- Database design with primary keys and foreign keys
- Joins across billing, payment, and customer tables
- KPI queries for billing, collections, and leakage
- Common Table Expressions (CTEs)
- Window functions like `DENSE_RANK()` and `LAG()`
- Risk segmentation with `CASE`
- BI-ready SQL views
- Stored procedures for monthly performance reporting
- Indexing for common access patterns

## Key Analyses Included

### KPI Queries

- Monthly billing vs collection rate
- Revenue leakage by region
- Category-wise billing and arrears exposure
- Top recoverable accounts
- Weak collection accounts
- Overdue accounts needing field action
- Meter issue impact on revenue realization

### Advanced Analysis

- Arrears aging buckets
- Region-wise ranking of top defaulters
- Month-over-month billing growth by category
- Customer risk segmentation for recovery teams
- Executive summary view for dashboards
- Stored procedure for region collection review

## How to Run

### Option 1: Run everything from MySQL command line

```bash
mysql -u root -p < 05_run_project.sql
```

Run that command from inside the project folder.

### Option 2: Run step by step in MySQL Workbench

Open and execute the files in this order:

1. `01_schema.sql`
2. `02_sample_data.sql`
3. `03_kpi_queries.sql`
4. `04_advanced_analysis.sql`

Then run:

```sql
CALL sp_region_collection_performance('2026-02-01');
SELECT * FROM vw_revenue_recovery_summary;
```

## Portfolio Value

This project is intentionally business-oriented instead of academic. It shows how SQL can be used in a utility revenue environment to:

- improve collection efficiency
- identify recoverable debt
- support recovery team prioritization
- monitor arrears and leakage
- prepare data for BI dashboards and advanced analytics

## Suggested LinkedIn Project Description

Designed a MySQL-based electricity revenue recovery and billing intelligence system to analyze billing, collections, arrears, and recoverable revenue. Built relational tables, KPI queries, CTEs, window functions, views, and a stored procedure to identify top defaulters, region-wise leakage, collection gaps, and recovery priorities for utility operations.

## Suggested GitHub Repo Name

`electricity-revenue-recovery-sql`

## Suggested Next Enhancement

To make this even stronger later, you can add:

- CSV import scripts for a larger dataset
- triggers for audit logging
- a Power BI dashboard connected to the SQL tables
- monthly snapshot tables for trend reporting
- a Python ETL step that loads raw billing files into MySQL
