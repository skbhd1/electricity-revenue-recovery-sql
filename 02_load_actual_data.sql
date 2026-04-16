USE electricity_revenue_sql;

TRUNCATE TABLE electricity_revenue_analysis;

LOAD DATA LOCAL INFILE 'dataset/electricity_revenue_analysis.csv'
INTO TABLE electricity_revenue_analysis
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    account_category_id,
    account_category,
    acc_cat_abbr,
    property_value,
    property_size,
    total_billing,
    avg_billing,
    total_receipting,
    avg_receipting,
    total_90_debt,
    total_write_off,
    collection_ratio,
    debt_billing_ratio,
    total_elec_bill,
    has_id_no,
    bad_debt
);
