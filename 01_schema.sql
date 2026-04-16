DROP DATABASE IF EXISTS electricity_revenue_sql;
CREATE DATABASE electricity_revenue_sql;
USE electricity_revenue_sql;

CREATE TABLE electricity_revenue_analysis (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_category_id INT NOT NULL,
    account_category VARCHAR(100) NOT NULL,
    acc_cat_abbr VARCHAR(20) NOT NULL,
    property_value DECIMAL(18,2) NOT NULL,
    property_size DECIMAL(18,2) NOT NULL,
    total_billing DECIMAL(18,2) NOT NULL,
    avg_billing DECIMAL(18,2) NOT NULL,
    total_receipting DECIMAL(18,2) NOT NULL,
    avg_receipting DECIMAL(18,2) NOT NULL,
    total_90_debt DECIMAL(18,2) NOT NULL,
    total_write_off DECIMAL(18,2) NOT NULL,
    collection_ratio DECIMAL(10,4) NOT NULL,
    debt_billing_ratio DECIMAL(10,4) NOT NULL,
    total_elec_bill DECIMAL(18,2) NOT NULL,
    has_id_no TINYINT(1) NOT NULL,
    bad_debt TINYINT(1) NOT NULL
);

CREATE INDEX idx_category ON electricity_revenue_analysis(account_category);
CREATE INDEX idx_bad_debt ON electricity_revenue_analysis(bad_debt);
CREATE INDEX idx_has_id ON electricity_revenue_analysis(has_id_no);
CREATE INDEX idx_collection_ratio ON electricity_revenue_analysis(collection_ratio);
CREATE INDEX idx_debt_billing_ratio ON electricity_revenue_analysis(debt_billing_ratio);
