"""The ORSTAC premises: the rules every ORSTAC tool and article must respect.

Distilled from an audit of the community's published articles and its bot repository.
"""

PREMISES: list[dict[str, str]] = [
    {"id": "demo-first", "rule": "Demo account first, always. Real money only after a recorded demo sample and with minimum stake."},
    {"id": "no-promises", "rule": "No promises of profit. Past results do not predict future results."},
    {"id": "loss-first", "rule": "Define the maximum loss before the expected gain."},
    {"id": "one-percent", "rule": "Risk at most 1% (ceiling 2%) of the balance per contract. On fixed-stake contracts the stake is the maximum loss."},
    {"id": "hard-limits", "rule": "Code hard limits into the bot: daily loss, maximum drawdown, consecutive losses. The bot stops by itself."},
    {"id": "no-martingale", "rule": "ORSTAC recommends against martingale. Any progression needs a hard cap on steps and stake and a ruin test before going live."},
    {"id": "backtest-filter", "rule": "A backtest is a filter, not proof: large samples, out-of-sample tests, and report how many configurations were tried."},
    {"id": "payout-matters", "rule": "Win rate means nothing without the payout: judge by expectancy, break-even rate and drawdown."},
    {"id": "process", "rule": "Rules are written before trading; changes follow a process (hypothesis, test, version), never right after a loss."},
    {"id": "no-data-no-claim", "rule": "No data, no claim: every result comes with sample size, period and limitations."},
]


def premises_text() -> str:
    return "\n".join(f"{i}. {p['rule']}" for i, p in enumerate(PREMISES, start=1))
