-- ============================================================
-- 01_schema.sql
-- Electricity Revenue Recovery & Billing Intelligence
-- MySQL Relational Schema
-- Author  : Shaik Abdullah
-- GitHub  : github.com/skbhd1
-- Version : 2.0
-- ============================================================
-- Business Context:
-- Models a Telangana electricity utility (TGSPDCL-style)
-- covering customers, tariffs, billing, collections,
-- disconnection workflows, and revenue recovery analytics.
-- ============================================================

DROP DATABASE IF EXISTS electricity_revenue_sql;
CREATE DATABASE electricity_revenue_sql
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE electricity_revenue_sql;

-- ── 1. REGIONS ───────────────────────────────────────────────
-- Represents operational circles / divisions
CREATE TABLE regions (
    region_id       INT             PRIMARY KEY AUTO_INCREMENT,
    region_name     VARCHAR(100)    NOT NULL,
    division_name   VARCHAR(50)     NOT NULL,
    urban_rural     ENUM('Urban','Rural') NOT NULL DEFAULT 'Urban',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ── 2. TARIFF PLANS ──────────────────────────────────────────
-- Electricity tariff slabs by consumer category
CREATE TABLE tariff_plans (
    tariff_id       INT             PRIMARY KEY AUTO_INCREMENT,
    tariff_code     VARCHAR(20)     NOT NULL UNIQUE,
    category_name   VARCHAR(50)     NOT NULL,
    rate_per_kwh    DECIMAL(6,2)    NOT NULL COMMENT 'Rate in INR per kWh',
    fixed_charge    DECIMAL(8,2)    NOT NULL COMMENT 'Fixed monthly charge in INR',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ── 3. CUSTOMERS ─────────────────────────────────────────────
-- Consumer master data
CREATE TABLE customers (
    customer_id         INT             PRIMARY KEY AUTO_INCREMENT,
    customer_no         VARCHAR(20)     NOT NULL UNIQUE,
    customer_name       VARCHAR(150)    NOT NULL,
    account_category    ENUM('Domestic','Commercial','Industrial',
                             'Agriculture','Government') NOT NULL,
    region_id           INT             NOT NULL,
    tariff_id           INT             NOT NULL,
    sanctioned_load_kw  DECIMAL(8,2)    NOT NULL,
    connection_status   ENUM('Active','Disconnected','Suspended') NOT NULL DEFAULT 'Active',
    has_id_proof        TINYINT(1)      NOT NULL DEFAULT 1
                            COMMENT '1 = ID proof on file, 0 = Missing',
    join_date           DATE            NOT NULL,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customer_region  FOREIGN KEY (region_id)  REFERENCES regions(region_id),
    CONSTRAINT fk_customer_tariff  FOREIGN KEY (tariff_id)  REFERENCES tariff_plans(tariff_id)
);

-- ── 4. METER READINGS ────────────────────────────────────────
-- Monthly meter reading records
CREATE TABLE meter_readings (
    reading_id          INT             PRIMARY KEY AUTO_INCREMENT,
    customer_id         INT             NOT NULL,
    reading_month       DATE            NOT NULL COMMENT 'First day of billing month',
    previous_reading    INT             NOT NULL DEFAULT 0,
    current_reading     INT             NOT NULL,
    units_consumed      INT             GENERATED ALWAYS AS (current_reading - previous_reading) STORED,
    reading_status      ENUM('Actual','Estimated','Faulty','Blocked') NOT NULL DEFAULT 'Actual',
    recorded_at         TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reading_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    UNIQUE KEY uq_reading (customer_id, reading_month)
);

-- ── 5. BILLS ─────────────────────────────────────────────────
-- Monthly bill records generated from meter readings
CREATE TABLE bills (
    bill_id             INT             PRIMARY KEY AUTO_INCREMENT,
    customer_id         INT             NOT NULL,
    reading_id          INT             NOT NULL,
    bill_month          DATE            NOT NULL COMMENT 'First day of billing month',
    energy_charge       DECIMAL(12,2)   NOT NULL,
    fixed_charge        DECIMAL(8,2)    NOT NULL,
    surcharge_amount    DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    total_bill_amount   DECIMAL(12,2)   NOT NULL,
    due_date            DATE            NOT NULL,
    bill_status         ENUM('Paid','Partially Paid','Overdue','Waived') NOT NULL DEFAULT 'Overdue',
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bill_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_bill_reading  FOREIGN KEY (reading_id)  REFERENCES meter_readings(reading_id),
    UNIQUE KEY uq_bill (customer_id, bill_month)
);

-- ── 6. PAYMENTS ──────────────────────────────────────────────
-- Payment transactions against bills
CREATE TABLE payments (
    payment_id      INT             PRIMARY KEY AUTO_INCREMENT,
    bill_id         INT             NOT NULL,
    payment_date    DATE            NOT NULL,
    amount_paid     DECIMAL(12,2)   NOT NULL,
    payment_mode    ENUM('Cash','UPI','Online','Bank','Cheque') NOT NULL DEFAULT 'Cash',
    reference_no    VARCHAR(50)     NULL,
    recorded_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_bill FOREIGN KEY (bill_id) REFERENCES bills(bill_id)
);

-- ── 7. DISCONNECTION ACTIONS ─────────────────────────────────
-- Field actions taken on overdue accounts
CREATE TABLE disconnection_actions (
    action_id       INT             PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT             NOT NULL,
    action_date     DATE            NOT NULL,
    action_type     ENUM('Reminder','Notice','Field Visit',
                         'Disconnection','Reconnection') NOT NULL,
    action_notes    VARCHAR(500)    NULL,
    actioned_by     VARCHAR(100)    NOT NULL DEFAULT 'Field Team',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_action_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ── INDEXES FOR QUERY PERFORMANCE ────────────────────────────
CREATE INDEX idx_customer_region       ON customers(region_id);
CREATE INDEX idx_customer_category     ON customers(account_category);
CREATE INDEX idx_customer_status       ON customers(connection_status);
CREATE INDEX idx_bill_month            ON bills(bill_month);
CREATE INDEX idx_bill_status           ON bills(bill_status);
CREATE INDEX idx_bill_customer         ON bills(customer_id);
CREATE INDEX idx_payment_date          ON payments(payment_date);
CREATE INDEX idx_payment_bill          ON payments(bill_id);
CREATE INDEX idx_reading_month         ON meter_readings(reading_month);
CREATE INDEX idx_action_type           ON disconnection_actions(action_type);
CREATE INDEX idx_action_customer       ON disconnection_actions(customer_id);
