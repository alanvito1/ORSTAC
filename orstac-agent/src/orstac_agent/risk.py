"""Risk arithmetic for fixed-stake contracts (Rise/Fall, Digits, etc.).

Conventions
-----------
payout: net profit per 1 unit of stake on a win (e.g. 0.95 means a 1.00 stake returns 1.95).
A loss loses the whole stake. Contracts are assumed independent unless stated otherwise.
All functions are pure and deterministic (Monte Carlo uses an explicit seed).
"""

from __future__ import annotations

import math
import random
from dataclasses import dataclass, asdict


def _check_prob(p: float, name: str = "p") -> None:
    if not 0.0 <= p <= 1.0:
        raise ValueError(f"{name} must be between 0 and 1, got {p}")


def _check_positive(x: float, name: str) -> None:
    if not x > 0:
        raise ValueError(f"{name} must be > 0, got {x}")


def break_even_win_rate(payout: float) -> float:
    """Minimum win probability for zero expectancy: p * payout = (1 - p)  ->  p = 1 / (1 + payout)."""
    _check_positive(payout, "payout")
    return 1.0 / (1.0 + payout)


def expectancy(win_rate: float, payout: float) -> float:
    """Expected net result per 1 unit of stake."""
    _check_prob(win_rate, "win_rate")
    _check_positive(payout, "payout")
    return win_rate * payout - (1.0 - win_rate)


def position_size(balance: float, risk_pct: float = 1.0, max_pct: float = 2.0) -> float:
    """Stake for a fixed-stake contract where the stake is the maximum loss.

    risk_pct is capped at max_pct (ORSTAC premise: 1%, ceiling 2%).
    """
    _check_positive(balance, "balance")
    _check_positive(risk_pct, "risk_pct")
    pct = min(risk_pct, max_pct)
    return round(balance * pct / 100.0, 2)


def kelly_fraction(win_rate: float, payout: float, fraction: float = 0.25) -> float:
    """Fractional Kelly stake as a share of balance (0 when there is no positive edge).

    Full Kelly for a binary bet: f* = (p * b - q) / b. ORSTAC uses it only as a ceiling,
    scaled by `fraction` (default 1/4), and never above 2%.
    """
    _check_prob(win_rate, "win_rate")
    _check_positive(payout, "payout")
    if not 0 < fraction <= 1:
        raise ValueError("fraction must be in (0, 1]")
    full = (win_rate * payout - (1.0 - win_rate)) / payout
    if full <= 0:
        return 0.0
    return min(full * fraction, 0.02)


def progression_stakes(base_stake: float, multiplier: float, steps: int) -> list[float]:
    """Stakes of a progression that multiplies the stake after each loss."""
    _check_positive(base_stake, "base_stake")
    _check_positive(multiplier, "multiplier")
    return [base_stake * multiplier ** k for k in range(steps)]


def max_consecutive_losses(balance: float, base_stake: float, multiplier: float, max_steps: int | None = None) -> int:
    """Number of consecutive losses a balance can absorb while still paying every required stake.

    With balance 1000, base 1, multiplier 2: stakes 1,2,4,...,256 sum to 511 (9 losses);
    the 10th stake (512) would need 1023 in total, so the answer is 9.
    If max_steps is given, the progression resets after that many losses (capped progression),
    so the answer is the number of losses until the balance can no longer pay the next stake.
    """
    _check_positive(balance, "balance")
    _check_positive(base_stake, "base_stake")
    _check_positive(multiplier, "multiplier")
    spent, losses, step = 0.0, 0, 0
    while True:
        stake = base_stake * multiplier ** step
        if spent + stake > balance + 1e-9:
            return losses
        spent += stake
        losses += 1
        step += 1
        if max_steps is not None and step >= max_steps:
            step = 0
        if losses > 10_000:  # multiplier < 1 or tiny stakes: effectively unbounded
            return losses


def prob_losing_streak(streak: int, n_contracts: int, loss_prob: float) -> float:
    """Exact probability of at least one run of `streak` consecutive losses in n independent contracts.

    Dynamic programming over the current run length (O(n * streak)).
    """
    _check_prob(loss_prob, "loss_prob")
    if streak <= 0:
        return 1.0
    if n_contracts < streak:
        return 0.0
    # state[k] = probability that the current trailing run of losses is k and no full run occurred yet
    state = [0.0] * streak
    state[0] = 1.0
    hit = 0.0
    for _ in range(n_contracts):
        new = [0.0] * streak
        for k, pr in enumerate(state):
            if pr == 0.0:
                continue
            new[0] += pr * (1.0 - loss_prob)  # a win resets the run
            if k + 1 == streak:
                hit += pr * loss_prob
            else:
                new[k + 1] += pr * loss_prob
        state = new
    return hit


@dataclass
class SimulationResult:
    simulations: int
    contracts_per_session: int
    ruin_probability: float
    mean_final_balance: float
    median_final_balance: float
    p05_final_balance: float
    mean_max_drawdown_pct: float
    seed: int

    def to_dict(self) -> dict:
        return asdict(self)


def simulate_progression(
    balance: float,
    base_stake: float,
    win_rate: float,
    payout: float,
    multiplier: float = 1.0,
    max_steps: int | None = None,
    n_contracts: int = 1000,
    simulations: int = 5000,
    seed: int = 42,
    stop_loss: float | None = None,
    take_profit: float | None = None,
) -> SimulationResult:
    """Monte Carlo of a session with an optional loss progression.

    Ruin = the balance cannot pay the next required stake. stop_loss / take_profit end the
    session when the cumulative result reaches -stop_loss / +take_profit.
    """
    _check_positive(balance, "balance")
    _check_positive(base_stake, "base_stake")
    _check_prob(win_rate, "win_rate")
    _check_positive(payout, "payout")
    if simulations <= 0 or n_contracts <= 0:
        raise ValueError("simulations and n_contracts must be > 0")
    rng = random.Random(seed)
    finals: list[float] = []
    drawdowns: list[float] = []
    ruined = 0
    for _ in range(simulations):
        bal, peak, max_dd, step = balance, balance, 0.0, 0
        for _ in range(n_contracts):
            stake = base_stake * multiplier ** step
            if stake > bal + 1e-9:
                ruined += 1
                break
            if rng.random() < win_rate:
                bal += stake * payout
                step = 0
            else:
                bal -= stake
                step += 1
                if max_steps is not None and step >= max_steps:
                    step = 0
            peak = max(peak, bal)
            max_dd = max(max_dd, (peak - bal) / peak if peak > 0 else 0.0)
            pnl = bal - balance
            if stop_loss is not None and pnl <= -stop_loss:
                break
            if take_profit is not None and pnl >= take_profit:
                break
        finals.append(bal)
        drawdowns.append(max_dd)
    finals.sort()
    return SimulationResult(
        simulations=simulations,
        contracts_per_session=n_contracts,
        ruin_probability=ruined / simulations,
        mean_final_balance=round(sum(finals) / len(finals), 2),
        median_final_balance=round(finals[len(finals) // 2], 2),
        p05_final_balance=round(finals[int(len(finals) * 0.05)], 2),
        mean_max_drawdown_pct=round(100 * sum(drawdowns) / len(drawdowns), 2),
        seed=seed,
    )


def describe_progression(balance: float, base_stake: float, multiplier: float, max_steps: int | None = None) -> dict:
    """Plain summary of what a progression commits, for audits and chat answers."""
    survivable = max_consecutive_losses(balance, base_stake, multiplier, max_steps)
    steps = max_steps if max_steps is not None else max(survivable, 1)
    stakes = progression_stakes(base_stake, multiplier, steps)
    return {
        "base_stake": base_stake,
        "multiplier": multiplier,
        "max_steps": max_steps,
        "max_consecutive_losses_survivable": survivable,
        "largest_stake_in_cycle": round(stakes[-1], 2),
        "worst_case_cycle_loss": round(sum(stakes), 2),
        "worst_case_cycle_loss_pct_of_balance": round(100 * sum(stakes) / balance, 2),
    }


def ruin_streak_probability(balance: float, base_stake: float, multiplier: float, loss_prob: float, n_contracts: int) -> dict:
    """Probability that an uncapped progression meets the losing streak that ruins it within n contracts.

    After k = max_consecutive_losses(...) losses in a row the next stake can no longer be paid,
    so a streak of k losses is ruinous (ignoring profits accumulated earlier in the session,
    which make this slightly conservative only in the very first cycles).
    """
    k = max_consecutive_losses(balance, base_stake, multiplier)
    return {
        "ruinous_streak_length": k,
        "probability_within_session": prob_losing_streak(k, n_contracts, loss_prob),
        "expected_number_of_such_streaks_approx": n_contracts * (1 - loss_prob) * loss_prob ** k,
        "note": "Probability is exact for independent contracts at the starting balance; real win rates must be measured, not assumed.",
    }


def isclose(a: float, b: float, tol: float = 1e-9) -> bool:
    return math.isclose(a, b, rel_tol=tol, abs_tol=tol)
