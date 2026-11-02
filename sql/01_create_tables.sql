
-- =============================================
-- Workforce Payroll Analytics
-- Database Schema
-- =============================================

-- Employee master table
CREATE TABLE IF NOT EXISTS employees (
    employee_id VARCHAR(6) PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL
);

-- Shift records
CREATE TABLE IF NOT EXISTS shifts (
    record_id INTEGER PRIMARY KEY,
    employee_id VARCHAR(6) NOT NULL,
    shift_date DATE NOT NULL,
    shift_type VARCHAR(10) NOT NULL,
    shift_start TIMESTAMP,
    shift_end TIMESTAMP,
    hours_worked NUMERIC(5,2) NOT NULL,
    daily_pay NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_shifts_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    CONSTRAINT chk_shift_type
        CHECK (shift_type IN ('Day', 'Night', 'Rest')),

    CONSTRAINT chk_hours_worked
        CHECK (hours_worked >= 0),

    CONSTRAINT chk_daily_pay
        CHECK (daily_pay >= 0)
);

-- Fictional payroll rules
CREATE TABLE IF NOT EXISTS pay_rules (
    rule_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL UNIQUE,
    rule_value NUMERIC(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,

    CONSTRAINT chk_rule_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        )
);

-- Modelled payroll results
CREATE TABLE IF NOT EXISTS payroll_results (
    result_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    record_id INTEGER NOT NULL UNIQUE,
    recorded_pay NUMERIC(10,2) NOT NULL,
    modelled_pay NUMERIC(10,2) NOT NULL,
    pay_variance NUMERIC(10,2) NOT NULL,
    variance_status VARCHAR(20) NOT NULL,
    rule_set_version VARCHAR(30) NOT NULL,
    calculated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payroll_shift
        FOREIGN KEY (record_id)
        REFERENCES shifts(record_id),

    CONSTRAINT chk_variance_status
        CHECK (
            variance_status IN (
                'Above Model',
                'Below Model',
                'Matches Model'
            )
        ),

    CONSTRAINT chk_recorded_pay
        CHECK (recorded_pay >= 0),

    CONSTRAINT chk_modelled_pay
        CHECK (modelled_pay >= 0),

    CONSTRAINT chk_pay_variance
        CHECK (
            pay_variance = recorded_pay - modelled_pay
        )
);


