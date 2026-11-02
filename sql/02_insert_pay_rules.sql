
-- =============================================
-- Workforce Payroll Analytics
-- Fictional Payroll Rules
-- =============================================

-- These rules are illustrative only.
-- They do not represent actual WA Health
-- employment awards or entitlements.

INSERT INTO pay_rules (
    rule_name,
    rule_value,
    effective_from,
    effective_to
)
VALUES
    ('base_hourly_rate', 20.00, '2015-01-01', NULL),
    ('day_multiplier', 1.00, '2015-01-01', NULL),
    ('night_multiplier', 1.25, '2015-01-01', NULL),
    ('overtime_multiplier', 1.50, '2015-01-01', NULL),
    ('overtime_threshold', 8.00, '2015-01-01', NULL)

ON CONFLICT (rule_name) DO NOTHING;
