
-- =============================================
-- Workforce Payroll Analytics
-- Reporting Views
-- =============================================

-- View 1: Shift-level payroll details

CREATE OR REPLACE VIEW vw_payroll_detail AS
SELECT
    s.record_id,
    e.employee_id,
    e.employee_name,
    s.shift_date,
    s.shift_type,
    s.shift_start,
    s.shift_end,
    s.hours_worked,

    GREATEST(s.hours_worked - 8, 0)
        AS overtime_hours,

    p.recorded_pay,
    p.modelled_pay,
    p.pay_variance,

    ABS(p.pay_variance)
        AS absolute_variance,

    p.variance_status,
    p.rule_set_version,
    p.calculated_at

FROM shifts s

INNER JOIN employees e
    ON s.employee_id = e.employee_id

INNER JOIN payroll_results p
    ON s.record_id = p.record_id;


-- View 2: Employee-level payroll summary

CREATE OR REPLACE VIEW vw_employee_payroll_summary AS
SELECT
    employee_id,
    employee_name,

    COUNT(*)
        AS total_shift_records,

    COUNT(*) FILTER (
        WHERE shift_type != 'Rest'
    ) AS worked_shifts,

    SUM(hours_worked)
        AS total_hours,

    SUM(overtime_hours)
        AS overtime_hours,

    SUM(recorded_pay)
        AS total_recorded_pay,

    SUM(modelled_pay)
        AS total_modelled_pay,

    SUM(pay_variance)
        AS net_variance,

    ROUND(AVG(absolute_variance), 2)
        AS average_absolute_variance

FROM vw_payroll_detail

GROUP BY
    employee_id,
    employee_name;
