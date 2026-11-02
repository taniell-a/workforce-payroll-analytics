
-- =============================================
-- Workforce Payroll Analytics
-- Data Quality and Reconciliation
-- =============================================

-- 1. Verify record counts
SELECT
    (SELECT COUNT(*) FROM employees) AS employee_count,
    (SELECT COUNT(*) FROM shifts) AS shift_count,
    (SELECT COUNT(*) FROM payroll_results) AS payroll_result_count;


-- 2. Check for orphaned shift records
SELECT COUNT(*) AS orphaned_shifts
FROM shifts s
LEFT JOIN employees e
    ON s.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


-- 3. Check for invalid Rest shifts
SELECT COUNT(*) AS invalid_rest_shifts
FROM shifts
WHERE shift_type = 'Rest'
AND (
    hours_worked <> 0
    OR daily_pay <> 0
    OR shift_start IS NOT NULL
    OR shift_end IS NOT NULL
);


-- 4. Check for invalid working shift durations
SELECT COUNT(*) AS invalid_working_durations
FROM shifts
WHERE shift_type IN ('Day', 'Night')
AND (
    shift_start IS NULL
    OR shift_end IS NULL
    OR ABS(
        EXTRACT(EPOCH FROM (shift_end - shift_start))
        / 3600.0 - hours_worked
    ) > 0.01
);


-- 5. Check for shifts without payroll results
SELECT COUNT(*) AS missing_payroll_results
FROM shifts s
LEFT JOIN payroll_results p
    ON s.record_id = p.record_id
WHERE p.record_id IS NULL;


-- 6. Check payroll reconciliation
SELECT COUNT(*) AS reconciliation_errors
FROM payroll_results
WHERE recorded_pay <> modelled_pay + pay_variance;


-- 7. Check variance classifications
SELECT COUNT(*) AS incorrect_variance_status
FROM payroll_results
WHERE
    (pay_variance < 0 AND variance_status <> 'Below Model')
    OR
    (pay_variance > 0 AND variance_status <> 'Above Model')
    OR
    (pay_variance = 0 AND variance_status <> 'Matches Model');


-- 8. Summarise payroll totals
SELECT
    COUNT(*) AS total_records,
    SUM(recorded_pay) AS total_recorded_pay,
    SUM(modelled_pay) AS total_modelled_pay,
    SUM(pay_variance) AS net_variance
FROM payroll_results;
