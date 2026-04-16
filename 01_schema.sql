DROP DATABASE IF EXISTS electricity_revenue_sql;
CREATE DATABASE electricity_revenue_sql;
USE electricity_revenue_sql;

CREATE TABLE regions (
    region_id INT PRIMARY KEY AUTO_INCREMENT,
    region_name VARCHAR(50) NOT NULL,
    division_name VARCHAR(50) NOT NULL,
    urban_rural_flag ENUM('Urban', 'Rural') NOT NULL
);

CREATE TABLE tariff_plans (
    tariff_id INT PRIMARY KEY AUTO_INCREMENT,
    tariff_code VARCHAR(20) NOT NULL UNIQUE,
    category_name VARCHAR(50) NOT NULL,
    rate_per_kwh DECIMAL(10,2) NOT NULL,
    fixed_charge DECIMAL(10,2) NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_no VARCHAR(20) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    account_category VARCHAR(50) NOT NULL,
    region_id INT NOT NULL,
    tariff_id INT NOT NULL,
    sanctioned_load_kw DECIMAL(10,2) NOT NULL,
    connection_status ENUM('Active', 'Disconnected') NOT NULL DEFAULT 'Active',
    has_id_proof BOOLEAN NOT NULL DEFAULT TRUE,
    join_date DATE NOT NULL,
    FOREIGN KEY (region_id) REFERENCES regions(region_id),
    FOREIGN KEY (tariff_id) REFERENCES tariff_plans(tariff_id)
);

CREATE TABLE meter_readings (
    reading_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    billing_month DATE NOT NULL,
    previous_reading DECIMAL(12,2) NOT NULL,
    current_reading DECIMAL(12,2) NOT NULL,
    units_consumed DECIMAL(12,2) NOT NULL,
    meter_status ENUM('Normal', 'Door Locked', 'Meter Fault', 'Provisional') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    UNIQUE KEY uq_meter_month (customer_id, billing_month)
);

CREATE TABLE bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    reading_id INT NOT NULL,
    bill_month DATE NOT NULL,
    energy_charge DECIMAL(12,2) NOT NULL,
    fixed_charge DECIMAL(12,2) NOT NULL,
    surcharge_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_bill_amount DECIMAL(12,2) NOT NULL,
    due_date DATE NOT NULL,
    bill_status ENUM('Issued', 'Partially Paid', 'Paid', 'Overdue') NOT NULL DEFAULT 'Issued',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (reading_id) REFERENCES meter_readings(reading_id),
    UNIQUE KEY uq_bill_month (customer_id, bill_month)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_mode ENUM('Cash', 'Online', 'UPI', 'Bank') NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES bills(bill_id)
);

CREATE TABLE disconnection_actions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    action_date DATE NOT NULL,
    action_type ENUM('Reminder', 'Notice', 'Field Visit', 'Disconnected') NOT NULL,
    action_notes VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_customers_region ON customers(region_id);
CREATE INDEX idx_customers_category ON customers(account_category);
CREATE INDEX idx_bills_month ON bills(bill_month);
CREATE INDEX idx_payments_bill_date ON payments(bill_id, payment_date);
CREATE INDEX idx_meter_month ON meter_readings(billing_month);
