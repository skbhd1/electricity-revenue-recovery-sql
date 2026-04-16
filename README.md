# Electricity Revenue Recovery & Bad Debt Analytics in MySQL

MySQL project built from the actual dataset used in the earlier Python and Power BI electricity revenue analytics project.

This repository focuses on the SQL layer of the same business problem: identifying bad debt exposure, measuring collection performance, detecting recovery risk, and highlighting which electricity consumer categories contribute most to revenue stress.

## Project Objective

Build a SQL-based analysis project on real electricity revenue data to answer business questions such as:

- Which account categories contribute the most to 90-day debt?
- Which segments have the weakest collection performance?
- How does ID availability affect bad debt outcomes?
- Where is recoverable revenue concentrated?
- Which categories should recovery teams prioritize first?

## Dataset Source

Source file used for this project:

- `Project Data Set - 27.03.2026.xlsx`

Imported project dataset file:

- `dataset/electricity_revenue_analysis.csv`

Source workbook note:

- The Excel workbook contains a sheet named `MunicipalDebtAnalysis`, but this repository is framed and documented as an electricity revenue analysis project because that is the actual business use case.

Dataset profile:

- Rows: `138,509`
- Columns: `16`
- Domain: electricity billing, receipting, arrears, write-offs, and bad debt

Original columns used in MySQL:

- `Account Category ID`
- `Account Category`
- `Acc Cat Abbr`
- `Property Value`
- `Property Size`
- `Total Billing`
- `Avg Billing`
- `Total Receipting`
- `Avg Receipting`
- `Total 90 Debt`
- `Total Write Off`
- `Collection Ratio`
- `Debt Billing Ratio`
- `Total Elec Bill`
- `Has ID No`
- `Bad Debt`

## Relation To Previous Project

This SQL project is built from the same electricity revenue dataset used in the earlier Python analysis, Power BI dashboard, and bad debt prediction work. The difference is that this repository shows how the same business problem can be solved directly in MySQL using:

- SQL schema design
- actual data import
- KPI queries
- analytical SQL
- window functions
- views
- stored procedures

## Real Dataset Highlights

These values come from the actual imported dataset:

- Total accounts: `138,509`
- Total billing: `1,494,244,373`
- Total receipting: `1,312,260,818`
- Weighted collection rate: `87.82%`
- Total 90-day debt: `1,340,353,734`
- Total write-off: `79,355,023`
- Bad debt rate: `46.19%`
- ID coverage: `42.43%`

Largest categories by 90-day debt include:

- `Residential`
- `Unknown`
- `Business`
- `Agricultural`
- `Government`
- `Municipal`

## Project Structure

```text
electricity-revenue-sql-project/
├── 01_schema.sql
├── 02_load_actual_data.sql
├── 03_kpi_queries.sql
├── 04_advanced_analysis.sql
├── 05_run_project.sql
├── dataset/
│   └── electricity_revenue_analysis.csv
└── README.md
```

## SQL Skills Demonstrated

- MySQL table creation and indexing
- Importing real CSV data into MySQL
- Revenue and debt KPI analysis
- Category-level business aggregation
- `CASE`-based segmentation
- Window functions such as `DENSE_RANK()` and `NTILE()`
- BI-ready views
- Stored procedures for debt-focused reporting
- Data quality checks on business metrics

## Main Analyses Included

### KPI Queries

- overall portfolio KPI summary
- category-wise billing, receipting, debt, and write-off summary
- collection performance by ID availability
- top high-risk consumer records by debt exposure
- categories with largest recoverable revenue gap
- write-off concentration by category
- anomaly and data quality checks

### Advanced Analysis

- category ranking by 90-day debt contribution
- debt-quartile risk segmentation
- property value band analysis
- no-ID recovery risk by category
- BI-ready category summary view
- stored procedure for high-debt categories

## How To Run

Run from inside this project folder with `LOCAL INFILE` enabled:

```bash
mysql --local-infile=1 -u root -p < 05_run_project.sql
```

If you prefer MySQL Workbench, execute the files in this order:

1. `01_schema.sql`
2. `02_load_actual_data.sql`
3. `03_kpi_queries.sql`
4. `04_advanced_analysis.sql`

Then run:

```sql
CALL sp_high_debt_categories(10000000);
SELECT * FROM vw_category_revenue_summary ORDER BY total_90_debt DESC;
```

## Business Value

This project shows how SQL can be used in electricity revenue operations to:

- measure collection efficiency
- identify debt-heavy customer categories
- quantify recoverable revenue gaps
- compare bad debt behavior across account types
- support recovery prioritization using actual utility data

## Output

The project produces:

- portfolio-level KPI summaries
- category rankings by debt and recovery gap
- risk segmentation outputs
- BI-ready category summary data
- a reusable stored procedure for debt-threshold review
