import random

import pytest

from orstac_agent import risk


def test_break_even_and_expectancy():
    assert risk.break_even_win_rate(1.0) == pytest.approx(0.5)
    assert risk.break_even_win_rate(0.95) == pytest.approx(1 / 1.95)
    # at break-even the expectancy is zero
    p = risk.break_even_win_rate(0.95)
    assert risk.expectancy(p, 0.95) == pytest.approx(0.0, abs=1e-12)
    # 90% win rate risking 10 to win 1 has negative edge (classic corpus example)
    assert risk.expectancy(0.90, 0.1) < 0


def test_position_size_caps_at_two_percent():
    assert risk.position_size(500) == 5.0
    assert risk.position_size(500, risk_pct=5) == 10.0  # capped at 2%


def test_kelly_zero_without_edge_and_capped():
    assert risk.kelly_fraction(0.5, 0.95) == 0.0
    assert risk.kelly_fraction(0.9, 1.0) == 0.02  # huge edge is still capped at 2%


def test_max_consecutive_losses_doubling():
    # stakes 1..256 sum to 511 (9 losses); the 10th stake (512) needs 1023 > 1000
    assert risk.max_consecutive_losses(1000, 1, 2) == 9
    assert risk.max_consecutive_losses(1023, 1, 2) == 10
    # flat stake: losses limited only by balance
    assert risk.max_consecutive_losses(10, 1, 1) == 10


def _brute_force_streak(streak, n, q, sims=40000, seed=7):
    rng = random.Random(seed)
    hits = 0
    for _ in range(sims):
        run = 0
        for _ in range(n):
            if rng.random() < q:
                run += 1
                if run >= streak:
                    hits += 1
                    break
            else:
                run = 0
    return hits / sims


@pytest.mark.parametrize("streak,n,q", [(3, 10, 0.5), (5, 50, 0.48), (9, 1000, 0.5)])
def test_prob_losing_streak_matches_simulation(streak, n, q):
    exact = risk.prob_losing_streak(streak, n, q)
    approx = _brute_force_streak(streak, n, q)
    assert exact == pytest.approx(approx, abs=0.012)


def test_prob_losing_streak_edge_cases():
    assert risk.prob_losing_streak(3, 2, 0.5) == 0.0
    assert risk.prob_losing_streak(1, 1, 0.3) == pytest.approx(0.3)
    assert risk.prob_losing_streak(2, 2, 0.5) == pytest.approx(0.25)


def test_simulation_flat_stake_matches_expectancy():
    # flat stake, no ruin possible: mean final balance ~ balance + n * stake * expectancy
    res = risk.simulate_progression(1000, 1, win_rate=0.5, payout=0.95, n_contracts=500, simulations=4000, seed=1)
    expected = 1000 + 500 * 1 * risk.expectancy(0.5, 0.95)
    assert res.ruin_probability == 0
    assert res.mean_final_balance == pytest.approx(expected, abs=1.5)


def test_martingale_ruin_probability_consistent_with_streak_math():
    # uncapped doubling at fair odds: ruin probability is close to the probability of a 9-loss streak
    res = risk.simulate_progression(1000, 1, win_rate=0.5, payout=1.0, multiplier=2, n_contracts=1000, simulations=4000, seed=3)
    streak = risk.ruin_streak_probability(1000, 1, 2, loss_prob=0.5, n_contracts=1000)
    assert streak["ruinous_streak_length"] == 9
    # profits accumulated before the streak raise the threshold slightly, so the simulation is a bit lower
    assert res.ruin_probability <= streak["probability_within_session"] + 0.02
    assert res.ruin_probability > 0.5 * streak["probability_within_session"]
    assert res.ruin_probability > 0.3  # the point: likely ruin in a single long session


def test_describe_progression():
    d = risk.describe_progression(1000, 1, 2, max_steps=5)
    assert d["worst_case_cycle_loss"] == 31.0
    assert d["largest_stake_in_cycle"] == 16.0


def test_invalid_inputs_raise():
    with pytest.raises(ValueError):
        risk.break_even_win_rate(0)
    with pytest.raises(ValueError):
        risk.expectancy(1.5, 1)
