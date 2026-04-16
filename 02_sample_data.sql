USE electricity_revenue_sql;

INSERT INTO regions (region_name, division_name, urban_rural_flag) VALUES
('Hyderabad Central', 'Circle A', 'Urban'),
('Hyderabad South', 'Circle B', 'Urban'),
('Warangal', 'Circle C', 'Urban'),
('Nalgonda Rural', 'Circle D', 'Rural');

INSERT INTO tariff_plans (tariff_code, category_name, rate_per_kwh, fixed_charge) VALUES
('DOM-1', 'Domestic', 6.50, 75.00),
('COM-1', 'Commercial', 8.25, 150.00),
('IND-1', 'Industrial', 7.80, 500.00),
('AGR-1', 'Agriculture', 2.00, 40.00);

INSERT INTO customers
    (customer_no, customer_name, account_category, region_id, tariff_id, sanctioned_load_kw, connection_status, has_id_proof, join_date)
VALUES
('C1001', 'Aarav Residency', 'Domestic', 1, 1, 3.00, 'Active', TRUE, '2021-01-10'),
('C1002', 'Meera Towers', 'Domestic', 2, 1, 4.00, 'Active', TRUE, '2022-05-18'),
('C1003', 'City Mart', 'Commercial', 1, 2, 12.00, 'Active', TRUE, '2020-09-01'),
('C1004', 'Sunrise Hospital', 'Commercial', 3, 2, 20.00, 'Active', TRUE, '2019-11-12'),
('C1005', 'Steel Works Pvt Ltd', 'Industrial', 3, 3, 75.00, 'Active', TRUE, '2018-02-20'),
('C1006', 'Green Agro Farms', 'Agriculture', 4, 4, 15.00, 'Active', FALSE, '2021-07-25'),
('C1007', 'Lakshmi Rice Mill', 'Industrial', 4, 3, 40.00, 'Active', TRUE, '2020-04-14'),
('C1008', 'Royal Bakery', 'Commercial', 2, 2, 8.00, 'Active', TRUE, '2023-03-30'),
('C1009', 'Nexa Apartments', 'Domestic', 1, 1, 5.00, 'Active', FALSE, '2022-12-10'),
('C1010', 'Metro Hardware', 'Commercial', 2, 2, 10.00, 'Active', TRUE, '2021-08-08');

INSERT INTO meter_readings
    (customer_id, billing_month, previous_reading, current_reading, units_consumed, meter_status)
VALUES
(1, '2026-01-01', 12450, 12820, 370, 'Normal'),
(1, '2026-02-01', 12820, 13185, 365, 'Normal'),
(2, '2026-01-01', 8400, 8710, 310, 'Normal'),
(2, '2026-02-01', 8710, 9055, 345, 'Normal'),
(3, '2026-01-01', 20990, 21940, 950, 'Normal'),
(3, '2026-02-01', 21940, 22980, 1040, 'Normal'),
(4, '2026-01-01', 17880, 19010, 1130, 'Normal'),
(4, '2026-02-01', 19010, 20160, 1150, 'Normal'),
(5, '2026-01-01', 50200, 55800, 5600, 'Normal'),
(5, '2026-02-01', 55800, 62050, 6250, 'Normal'),
(6, '2026-01-01', 11300, 12120, 820, 'Provisional'),
(6, '2026-02-01', 12120, 12940, 820, 'Door Locked'),
(7, '2026-01-01', 31250, 35450, 4200, 'Normal'),
(7, '2026-02-01', 35450, 39810, 4360, 'Normal'),
(8, '2026-01-01', 9650, 10125, 475, 'Normal'),
(8, '2026-02-01', 10125, 10670, 545, 'Normal'),
(9, '2026-01-01', 14980, 15360, 380, 'Normal'),
(9, '2026-02-01', 15360, 15790, 430, 'Meter Fault'),
(10, '2026-01-01', 11050, 11720, 670, 'Normal'),
(10, '2026-02-01', 11720, 12410, 690, 'Normal');

INSERT INTO bills
    (customer_id, reading_id, bill_month, energy_charge, fixed_charge, surcharge_amount, total_bill_amount, due_date, bill_status)
VALUES
(1, 1, '2026-01-01', 2405.00, 75.00, 0.00, 2480.00, '2026-01-20', 'Paid'),
(1, 2, '2026-02-01', 2372.50, 75.00, 0.00, 2447.50, '2026-02-20', 'Paid'),
(2, 3, '2026-01-01', 2015.00, 75.00, 0.00, 2090.00, '2026-01-20', 'Partially Paid'),
(2, 4, '2026-02-01', 2242.50, 75.00, 45.00, 2362.50, '2026-02-20', 'Overdue'),
(3, 5, '2026-01-01', 7837.50, 150.00, 0.00, 7987.50, '2026-01-20', 'Paid'),
(3, 6, '2026-02-01', 8580.00, 150.00, 0.00, 8730.00, '2026-02-20', 'Partially Paid'),
(4, 7, '2026-01-01', 9322.50, 150.00, 0.00, 9472.50, '2026-01-20', 'Paid'),
(4, 8, '2026-02-01', 9487.50, 150.00, 0.00, 9637.50, '2026-02-20', 'Paid'),
(5, 9, '2026-01-01', 43680.00, 500.00, 0.00, 44180.00, '2026-01-20', 'Partially Paid'),
(5, 10, '2026-02-01', 48750.00, 500.00, 1200.00, 50450.00, '2026-02-20', 'Overdue'),
(6, 11, '2026-01-01', 1640.00, 40.00, 0.00, 1680.00, '2026-01-20', 'Paid'),
(6, 12, '2026-02-01', 1640.00, 40.00, 35.00, 1715.00, '2026-02-20', 'Overdue'),
(7, 13, '2026-01-01', 32760.00, 500.00, 0.00, 33260.00, '2026-01-20', 'Paid'),
(7, 14, '2026-02-01', 34008.00, 500.00, 800.00, 35308.00, '2026-02-20', 'Partially Paid'),
(8, 15, '2026-01-01', 3918.75, 150.00, 0.00, 4068.75, '2026-01-20', 'Paid'),
(8, 16, '2026-02-01', 4496.25, 150.00, 0.00, 4646.25, '2026-02-20', 'Paid'),
(9, 17, '2026-01-01', 2470.00, 75.00, 0.00, 2545.00, '2026-01-20', 'Partially Paid'),
(9, 18, '2026-02-01', 2795.00, 75.00, 50.00, 2920.00, '2026-02-20', 'Overdue'),
(10, 19, '2026-01-01', 5527.50, 150.00, 0.00, 5677.50, '2026-01-20', 'Paid'),
(10, 20, '2026-02-01', 5692.50, 150.00, 0.00, 5842.50, '2026-02-20', 'Paid');

INSERT INTO payments (bill_id, payment_date, amount_paid, payment_mode) VALUES
(1, '2026-01-15', 2480.00, 'Online'),
(2, '2026-02-16', 2447.50, 'UPI'),
(3, '2026-01-18', 1200.00, 'Cash'),
(5, '2026-01-19', 7987.50, 'Bank'),
(6, '2026-02-23', 4000.00, 'Online'),
(7, '2026-01-17', 9472.50, 'Bank'),
(8, '2026-02-18', 9637.50, 'Bank'),
(9, '2026-01-25', 22000.00, 'Bank'),
(11, '2026-01-16', 1680.00, 'Cash'),
(13, '2026-01-18', 33260.00, 'Bank'),
(14, '2026-02-25', 15000.00, 'Bank'),
(15, '2026-01-14', 4068.75, 'UPI'),
(16, '2026-02-16', 4646.25, 'UPI'),
(17, '2026-01-27', 1500.00, 'Cash'),
(19, '2026-01-16', 5677.50, 'Online'),
(20, '2026-02-17', 5842.50, 'Online');

INSERT INTO disconnection_actions (customer_id, action_date, action_type, action_notes) VALUES
(2, '2026-02-25', 'Reminder', 'Part-payment received; follow-up pending'),
(5, '2026-02-27', 'Notice', 'High-value industrial overdue account'),
(6, '2026-03-01', 'Field Visit', 'Meter inaccessible during collection cycle'),
(9, '2026-02-28', 'Reminder', 'Repeated delay and missing ID proof');
