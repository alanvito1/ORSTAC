import os
import random

import pytest

from orstac_agent import stats
from orstac_agent.deriv_api import DerivPublicClient, run

LIVE = os.environ.get("ORSTAC_LIVE") == "1"


def test_chi_square_pvalue_known_values():
    # chi-square(9) critical value at 5% is 16.919; at 1% is 21.666
    assert stats.chi_square_pvalue(16.919, 9) == pytest.approx(0.05, abs=1e-3)
    assert stats.chi_square_pvalue(21.666, 9) == pytest.approx(0.01, abs=1e-3)
    assert stats.chi_square_pvalue(0.0, 9) == pytest.approx(1.0)


def test_last_digits_handles_pip_formats():
    assert stats.last_digits([507.78, 507.7], 0.01) == [8, 0]
    assert stats.last_digits([507.78, 507.7], 2) == [8, 0]


def test_random_walk_shows_no_pattern():
    rng = random.Random(11)
    price, prices = 1000.0, []
    for _ in range(5000):
        price += rng.choice((-1, 1)) * rng.randint(1, 50) / 100
        prices.append(round(price, 2))
    res = stats.analyze_ticks(prices, 0.01)
    assert res["runs"]["p_value"] > 0.01
    assert res["last_digit"]["p_value"] > 0.01
    assert res["verdict"].startswith("No detectable pattern")


def test_biased_series_is_flagged():
    # strongly trending, momentum-like series
    rng = random.Random(3)
    price, prices, last = 1000.0, [], 1
    for _ in range(3000):
        last = last if rng.random() < 0.8 else -last
        price += last * 0.37
        prices.append(round(price, 2))
    res = stats.analyze_ticks(prices, 0.01)
    assert res["runs"]["p_value"] < 0.001
    assert res["verdict"].startswith("Possible deviation")


def test_client_refuses_trading_calls():
    client = DerivPublicClient()
    with pytest.raises(PermissionError):
        run(client.call({"buy": "123", "price": 10}))
    with pytest.raises(PermissionError):
        run(client.call({"authorize": "token"}))


@pytest.mark.skipif(not LIVE, reason="set ORSTAC_LIVE=1 to call the public Deriv API")
def test_live_public_api():
    async def go():
        async with DerivPublicClient() as api:
            assert await api.ping()
            syms = await api.active_symbols(market="synthetic_index")
            assert any(s["symbol"] == "R_100" for s in syms)
            ticks = await api.ticks_history("R_100", 50)
            assert len(ticks["prices"]) == 50
            types = await api.contracts_for("R_100")
            assert "CALL" in types and "DIGITDIFF" in types
            quote = await api.proposal("R_100", "CALL", 5, "t", 10)
            assert quote["payout"] > quote["stake"]
            assert 0.5 < quote["break_even_win_rate"] < 0.6
    run(go())
