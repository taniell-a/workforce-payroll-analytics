
import pytest
from decimal import Decimal

from src.payroll_engine import calculate_shift_pay


# Fictional payroll rules used for testing
TEST_RULES = {
    "base_hourly_rate": Decimal("20.00"),
    "day_multiplier": Decimal("1.00"),
    "night_multiplier": Decimal("1.25"),
    "overtime_multiplier": Decimal("1.50"),
    "overtime_threshold": Decimal("8.00")
}


def test_day_shift():
    result = calculate_shift_pay(
        7, "Day", TEST_RULES
    )
    assert result == Decimal("140.00")


def test_night_shift():
    result = calculate_shift_pay(
        7, "Night", TEST_RULES
    )
    assert result == Decimal("175.00")


def test_day_overtime():
    result = calculate_shift_pay(
        9, "Day", TEST_RULES
    )
    assert result == Decimal("190.00")


def test_night_overtime():
    result = calculate_shift_pay(
        9, "Night", TEST_RULES
    )
    assert result == Decimal("230.00")


def test_rest_shift():
    result = calculate_shift_pay(
        0, "Rest", TEST_RULES
    )
    assert result == Decimal("0.00")


@pytest.mark.parametrize(
    "hours, shift_type, expected",
    [
        (7.5, "Day", "150.00"),
        (8, "Day", "160.00"),
        (8.5, "Day", "175.00"),
        (8, "Night", "200.00"),
        (8.5, "Night", "215.00")
    ]
)
def test_overtime_boundaries(hours, shift_type, expected):
    result = calculate_shift_pay(
        hours,
        shift_type,
        TEST_RULES
    )

    assert result == Decimal(expected)


def test_negative_hours():
    with pytest.raises(ValueError):
        calculate_shift_pay(
            -2,
            "Day",
            TEST_RULES
        )


def test_invalid_shift_type():
    with pytest.raises(ValueError):
        calculate_shift_pay(
            8,
            "Evening",
            TEST_RULES
        )


def test_rest_shift_with_hours():
    with pytest.raises(ValueError):
        calculate_shift_pay(
            4,
            "Rest",
            TEST_RULES
        )


@pytest.mark.parametrize(
    "hours, expected",
    [
        ("1", "20.13"),
        ("2", "40.25"),
        ("3", "60.38")
    ]
)
def test_decimal_rounding(hours, expected):

    custom_rules = TEST_RULES.copy()

    custom_rules["base_hourly_rate"] = Decimal("20.125")

    result = calculate_shift_pay(
        hours,
        "Day",
        custom_rules
    )

    assert result == Decimal(expected)


from src.payroll_engine import calculate_pay_variance


@pytest.mark.parametrize(
    "recorded, modelled, expected",
    [
        ("78.06", "175.00", "-96.94"),
        ("202.98", "140.00", "62.98"),
        ("0.00", "0.00", "0.00"),
        ("160.00", "160.00", "0.00")
    ]
)
def test_pay_variance(recorded, modelled, expected):

    result = calculate_pay_variance(
        recorded,
        modelled
    )

    assert result == Decimal(expected)

    # Verify the reconciliation equation
    assert (
        Decimal(recorded)
        == Decimal(modelled) + result
    )
