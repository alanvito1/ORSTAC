"""Statistical checks on tick data: is there anything a strategy could exploit?

Synthetic indices are generated to behave randomly. These tests look for the patterns that
community bots usually assume (digit imbalance, streaks, momentum). Failing to find a pattern
does not prove there is none; finding one in a small sample usually means noise. Every result
reports its sample size.
"""

from __future__ import annotations

import math
from collections import Counter


def _normal_sf(z: float) -> float:
    """P(Z > z) for a standard normal variable."""
    return 0.5 * math.erfc(z / math.sqrt(2))


def _gamma_q(a: float, x: float) -> float:
    """Regularized upper incomplete gamma Q(a, x) (series / continued fraction, Numerical Recipes)."""
    if x <= 0:
        return 1.0
    gln = math.lgamma(a)
    if x < a + 1:
        term = total = 1.0 / a
        ap = a
        for _ in range(500):
            ap += 1
            term *= x / ap
            total += term
            if abs(term) < abs(total) * 1e-14:
                break
        return 1.0 - total * math.exp(-x + a * math.log(x) - gln)
    b = x + 1 - a
    c = 1 / 1e-300
    d = 1 / b
    h = d
    for i in range(1, 500):
        an = -i * (i - a)
        b += 2
        d = an * d + b
        d = 1e-300 if abs(d) < 1e-300 else d
        c = b + an / c
        c = 1e-300 if abs(c) < 1e-300 else c
        d = 1 / d
        delta = d * c
        h *= delta
        if abs(delta - 1) < 1e-14:
            break
    return math.exp(-x + a * math.log(x) - gln) * h


def chi_square_pvalue(stat: float, dof: int) -> float:
    return _gamma_q(dof / 2.0, stat / 2.0)


def last_digits(prices: list[float], pip_size: float | int | None) -> list[int]:
    """Last displayed digit of each price. pip_size may be 0.01 or the number of decimals (2)."""
    if pip_size is None:
        decimals = 2
    elif pip_size >= 1 and float(pip_size).is_integer():
        decimals = int(pip_size)
    else:
        decimals = max(0, round(-math.log10(pip_size)))
    return [int(round(p * 10 ** decimals)) % 10 for p in prices]


def digit_test(digits: list[int]) -> dict:
    n = len(digits)
    counts = Counter(digits)
    expected = n / 10
    stat = sum((counts.get(d, 0) - expected) ** 2 / expected for d in range(10)) if n else 0.0
    return {
        "n": n,
        "frequencies": {d: round(counts.get(d, 0) / n, 4) if n else 0 for d in range(10)},
        "chi_square": round(stat, 3),
        "p_value": round(chi_square_pvalue(stat, 9), 4) if n else None,
    }


def runs_test(moves: list[int]) -> dict:
    """Wald-Wolfowitz runs test on up (+1) / down (-1) moves; flat moves are dropped."""
    seq = [m for m in moves if m != 0]
    n1, n2 = seq.count(1), seq.count(-1)
    n = n1 + n2
    if n1 == 0 or n2 == 0:
        return {"n": n, "runs": None, "z": None, "p_value": None}
    runs = 1 + sum(1 for a, b in zip(seq, seq[1:]) if a != b)
    mu = 2 * n1 * n2 / n + 1
    var = (mu - 1) * (mu - 2) / (n - 1)
    z = (runs - mu) / math.sqrt(var) if var > 0 else 0.0
    return {"n": n, "runs": runs, "expected_runs": round(mu, 2), "z": round(z, 3), "p_value": round(2 * _normal_sf(abs(z)), 4)}


def autocorrelation(xs: list[float], lag: int = 1) -> dict:
    n = len(xs)
    if n <= lag + 2:
        return {"n": n, "lag": lag, "r": None, "p_value": None}
    mean = sum(xs) / n
    den = sum((x - mean) ** 2 for x in xs)
    num = sum((xs[i] - mean) * (xs[i + lag] - mean) for i in range(n - lag))
    r = num / den if den else 0.0
    z = r * math.sqrt(n)
    return {"n": n, "lag": lag, "r": round(r, 4), "p_value": round(2 * _normal_sf(abs(z)), 4)}


def analyze_ticks(prices: list[float], pip_size: float | int | None = None, alpha: float = 0.01) -> dict:
    """Runs the three checks and gives a plain-language verdict."""
    moves = [(b > a) - (b < a) for a, b in zip(prices, prices[1:])]
    returns = [b - a for a, b in zip(prices, prices[1:])]
    up = moves.count(1)
    nonflat = up + moves.count(-1)
    result = {
        "ticks": len(prices),
        "up_ratio": round(up / nonflat, 4) if nonflat else None,
        "last_digit": digit_test(last_digits(prices, pip_size)),
        "runs": runs_test(moves),
        "autocorrelation_lag1": autocorrelation(returns, 1),
        "alpha": alpha,
    }
    flagged = [name for name, key in (("last-digit distribution", "last_digit"), ("up/down runs", "runs"),
                                      ("lag-1 autocorrelation", "autocorrelation_lag1"))
               if (result[key].get("p_value") is not None and result[key]["p_value"] < alpha)]
    if len(prices) < 500:
        verdict = "Sample too small to conclude anything (use at least 1,000 ticks)."
    elif flagged:
        verdict = (f"Possible deviation in: {', '.join(flagged)} (p < {alpha}). With several tests, one low p-value "
                   "is expected by chance now and then: re-test on a fresh, larger sample before believing it.")
    else:
        verdict = ("No detectable pattern in this sample. Digit, streak and momentum strategies have no "
                   "statistical edge here; the payout's house edge still applies.")
    result["verdict"] = verdict
    return result
