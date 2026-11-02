
from decimal import Decimal, ROUND_HALF_UP


def calculate_shift_pay(hours, shift_type, rules):
    """
    Calculate modelled shift pay using fictional payroll rules.
    """

    hours = Decimal(str(hours))

    base_rate = rules["base_hourly_rate"]
    threshold = rules["overtime_threshold"]

    if hours < 0:
        raise ValueError("Hours worked cannot be negative")

    if shift_type == "Rest":
        if hours != 0:
            raise ValueError("Rest shifts must have zero hours")
        return Decimal("0.00")

    if shift_type not in ["Day", "Night"]:
        raise ValueError("Invalid shift type")

    ordinary_hours = min(hours, threshold)
    overtime_hours = max(
        hours - threshold,
        Decimal("0")
    )

    if shift_type == "Day":
        multiplier = rules["day_multiplier"]
    else:
        multiplier = rules["night_multiplier"]

    ordinary_pay = (
        ordinary_hours
        * base_rate
        * multiplier
    )

    overtime_pay = (
        overtime_hours
        * base_rate
        * rules["overtime_multiplier"]
    )

    total_pay = ordinary_pay + overtime_pay

    return total_pay.quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP
    )


def calculate_pay_variance(recorded_pay, modelled_pay):
    """
    Calculate the difference between recorded
    and modelled payroll amounts.
    """

    recorded_pay = Decimal(str(recorded_pay))
    modelled_pay = Decimal(str(modelled_pay))

    variance = recorded_pay - modelled_pay

    return variance.quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP
    )
