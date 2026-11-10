"""Command line interface: `orstac-agent <command>`.

Examples
  orstac-agent audit "champions/safe profit pro.xml"
  orstac-agent audit-repo Bots_XML --top 20
  orstac-agent ruin --balance 1000 --stake 1 --multiplier 2 --win-rate 0.5 --payout 0.95
  orstac-agent quote R_100 --type CALL --duration 5
  orstac-agent analyze R_100 --count 3000
  orstac-agent lab Bots_XML --out knowledge/lab_ranking.json
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path

from . import risk, stats
from .deriv_api import DerivPublicClient, run
from .xml_audit import audit_file


def _print(obj) -> None:
    print(json.dumps(obj, indent=2, ensure_ascii=True))


def cmd_audit(args) -> None:
    for p in args.paths:
        _print(audit_file(p).to_dict())


def cmd_audit_repo(args) -> None:
    files = sorted(Path(args.folder).rglob("*.xml"))
    audits = [audit_file(f) for f in files]
    ok = [a for a in audits if a.parsed]
    n = len(ok) or 1
    summary = {
        "folder": args.folder,
        "files": len(files),
        "parsed": len(ok),
        "risk_grades": dict(sorted(Counter(a.risk_grade for a in ok).items())),
        "progression": dict(Counter(a.progression for a in ok)),
        "with_session_loss_limit_pct": round(100 * sum(a.has_loss_limit for a in ok) / n, 1),
        "with_profit_target_pct": round(100 * sum(a.has_profit_target for a in ok) / n, 1),
        "trade_types": dict(Counter(a.trade_type for a in ok).most_common(8)),
        "symbols": dict(Counter(a.symbol for a in ok).most_common(8)),
        "indicators": dict(Counter(i for a in ok for i in a.indicators).most_common(8)),
        "method": "Static heuristic audit of Blockly XML; see orstac_agent/xml_audit.py.",
    }
    if args.top:
        summary["grade_a_examples"] = [a.file for a in ok if a.risk_grade == "A"][: args.top]
    _print(summary)


def cmd_ruin(args) -> None:
    out = {
        "progression": risk.describe_progression(args.balance, args.stake, args.multiplier, args.max_steps),
        "break_even_win_rate": round(risk.break_even_win_rate(args.payout), 4),
        "expectancy_per_unit_stake": round(risk.expectancy(args.win_rate, args.payout), 4),
        "simulation": risk.simulate_progression(args.balance, args.stake, args.win_rate, args.payout, args.multiplier,
                                                args.max_steps, args.contracts, args.simulations, args.seed).to_dict(),
    }
    _print(out)


def cmd_quote(args) -> None:
    async def go():
        async with DerivPublicClient() as api:
            return await api.proposal(args.symbol, args.type, args.duration, args.unit, args.stake, barrier=args.barrier)
    _print(run(go()))


def cmd_analyze(args) -> None:
    async def go():
        async with DerivPublicClient() as api:
            return await api.ticks_history(args.symbol, args.count)
    ticks = run(go())
    res = stats.analyze_ticks(ticks["prices"], ticks["pip_size"])
    res["symbol"] = args.symbol
    _print(res)


def cmd_lab(args) -> None:
    from .lab import run_lab

    result = run_lab(args.folder, simulations=args.simulations)
    if args.out:
        Path(args.out).write_text(json.dumps(result, indent=1, ensure_ascii=False), encoding="utf-8")
    top = [{k: e[k] for k in ("file", "contract", "score", "admitted")} for e in result["ranking"][: args.top]]
    _print({k: result[k] for k in ("files", "parsed", "modeled", "admitted", "distinct_strategies_simulated",
                                   "not_modeled")} | {"top": top})


def main(argv: list[str] | None = None) -> None:
    ap = argparse.ArgumentParser(prog="orstac-agent", description="ORSTAC read-only risk and validation toolkit for Deriv bots.")
    sub = ap.add_subparsers(dest="cmd", required=True)

    a = sub.add_parser("audit", help="audit one or more Deriv Bot XML files")
    a.add_argument("paths", nargs="+")
    a.set_defaults(func=cmd_audit)

    r = sub.add_parser("audit-repo", help="aggregate audit of a folder of bots")
    r.add_argument("folder")
    r.add_argument("--top", type=int, default=0, help="list N grade-A examples")
    r.set_defaults(func=cmd_audit_repo)

    s = sub.add_parser("ruin", help="ruin and drawdown simulation for a stake progression")
    s.add_argument("--balance", type=float, required=True)
    s.add_argument("--stake", type=float, required=True)
    s.add_argument("--multiplier", type=float, default=1.0)
    s.add_argument("--max-steps", type=int, default=None)
    s.add_argument("--win-rate", type=float, default=0.5)
    s.add_argument("--payout", type=float, default=0.95)
    s.add_argument("--contracts", type=int, default=1000)
    s.add_argument("--simulations", type=int, default=5000)
    s.add_argument("--seed", type=int, default=42)
    s.set_defaults(func=cmd_ruin)

    q = sub.add_parser("quote", help="live contract price and break-even win rate (no purchase)")
    q.add_argument("symbol")
    q.add_argument("--type", default="CALL")
    q.add_argument("--duration", type=int, default=5)
    q.add_argument("--unit", default="t")
    q.add_argument("--stake", type=float, default=10.0)
    q.add_argument("--barrier", default=None)
    q.set_defaults(func=cmd_quote)

    n = sub.add_parser("analyze", help="test recent ticks for exploitable patterns")
    n.add_argument("symbol")
    n.add_argument("--count", type=int, default=2000)
    n.set_defaults(func=cmd_analyze)

    lb = sub.add_parser("lab", help="price, simulate and rank every bot in a folder (ORSTAC Score)")
    lb.add_argument("folder")
    lb.add_argument("--out", help="write the full ranking JSON here")
    lb.add_argument("--simulations", type=int, default=2000)
    lb.add_argument("--top", type=int, default=10)
    lb.set_defaults(func=cmd_lab)

    args = ap.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
