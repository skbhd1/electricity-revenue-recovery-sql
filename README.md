# ⚡ Electricity Revenue Recovery & Bad Debt Analytics in MySQL

A business-focused MySQL analytics project built on **real electricity revenue data** to measure collection efficiency, identify bad debt exposure, uncover recoverable revenue, and support smarter recovery decisions.

This project extends my earlier electricity analytics work in **Python**, **Power BI**, and **machine learning** by showing how the same problem can be solved directly in **SQL**.

---

## 🚀 Project Overview

Electricity utilities need more than dashboards. They need strong SQL analysis to answer questions like:

- Which consumer categories contribute the most to **90-day debt**?
- Which segments have the weakest **collection performance**?
- How does **ID availability** affect bad debt outcomes?
- Where is the biggest **recoverable revenue gap**?
- Which categories should be prioritized for **recovery action**?

This project solves those questions using **MySQL**, real business metrics, and utility-domain data.

---

## 📊 Dataset Source

**Source file used:**
- `Project Data Set - 27.03.2026.xlsx`

**Imported CSV used in this repository:**
- `electricity_revenue_analysis.csv`

**Workbook note:**
- The original Excel workbook contains a sheet named `MunicipalDebtAnalysis`, but the actual business use case is **electricity revenue analysis**, which is how this repository is framed.

**Dataset profile:**
- 🧾 Rows: `138,509`
- 📁 Columns: `16`
- 🏭 Domain: electricity billing, receipting, arrears, write-offs, and bad debt

**Columns used in MySQL:**
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

---

## 🔗 Relation To Previous Project

This SQL project is built from the same electricity revenue dataset used in my earlier:
- Python revenue analysis pipeline
- Power BI dashboard
- Bad debt prediction project

This repository specifically highlights the **SQL layer** of the business problem using:
- schema design
- actual data import
- KPI queries
- analytical SQL
- window functions
- views
- stored procedures

---

## 📌 Real Dataset Highlights

These values come from the actual imported dataset:

- 👥 Total accounts: `138,509`
- 💰 Total billing: `1,494,244,373`
- 💵 Total receipting: `1,312,260,818`
- 📈 Weighted collection rate: `87.82%`
- 🚨 Total 90-day debt: `1,340,353,734`
- 🧹 Total write-off: `79,355,023`
- ⚠️ Bad debt rate: `46.19%`
- 🪪 ID coverage: `42.43%`

**Largest categories by 90-day debt:**
- `Residential`
- `Unknown`
- `Business`
- `Agricultural`
- `Government`
- `Municipal`

---

## 🗂️ Project Structure

```text
electricity-revenue-recovery-sql/
├── 01_schema.sql
├── 02_load_actual_data.sql
├── 03_kpi_queries.sql
├── 04_advanced_analysis.sql
├── 05_run_project.sql
├── electricity_revenue_analysis.csv
└── README.md
