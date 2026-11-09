"""ORSTAC MCP server: exposes the toolkit to AI assistants (Claude, ChatGPT, n8n, any MCP client).

Run:  orstac-mcp            (stdio transport)
All tools are read-only. No tool can place a trade or access an account.
"""

from __future__ import annotations

import os
from pathlib import Path

from mcp.server.mcpserver import MCPServer
from mcp.server.mcpserver.exceptions import ToolError

from . import risk, stats
from .deriv_api import DerivPublicClient
from .premises import PREMISES, premises_text
from .xml_audit import audit_file, audit_xml

REPO_ROOT = Path(os.environ.get("ORSTAC_REPO", Path(__file__).resolve().parents[3])).resolve()

INSTRUCTIONS = f"""You are using the ORSTAC toolkit for Deriv trading bots. It is read-only: it audits bots,
computes risk and reads public market data. It never trades.
Always follow the ORSTAC premises when you answer:
{premises_text()}
Report sample sizes and limitations with every number. Never promise profit."""

server = MCPServer(name="orstac", instructions=INSTRUCTIONS, version="2.0.0")


@server.tool()
def orstac_premises() -> list[dict]:
    """The ORSTAC risk premises that every answer must respect."""
    return PREMISES


@server.tool()
def audit_bot_xml(xml: str) -> dict:
    """Static risk audit of a Deriv Bot XML: market, contract, stake progression (martingale), session limits and a risk grade (A best, D worst)."""
    return audit_xml(xml).to_dict()


@server.tool()
def audit_repository_bot(relative_path: str) -> dict:
    """Audit a bot from the ORSTAC repository, e.g. 'champions/safe profit pro.xml' or 'Bots_XML/A/AT bot.xml'."""
    target = (REPO_ROOT / relative_path).resolve()
    if REPO_ROOT not in target.parents or target.suffix.lower() != ".xml":
        raise ToolError("Path must point to an .xml file inside the ORSTAC repository.")
    if not target.exists():
        raise ToolError(f"File not found in the repository: {relative_path}")
    result = audit_file(target).to_dict()
    result["file"] = str(target.relative_to(REPO_ROOT)).replace("\\", "/")
    return result


@server.tool()
def risk_break_even(payout: float) -> dict:
    """Break-even win rate for a fixed-payout contract. payout = net profit per 1 unit of stake (e.g. 0.95)."""
    return {"payout": payout, "break_even_win_rate": risk.break_even_win_rate(payout)}


@server.tool()
def risk_position_size(balance: float, risk_pct: float = 1.0) -> dict:
    """Stake for a fixed-stake contract under the ORSTAC 1% rule (capped at 2%)."""
    return {"balance": balance, "risk_pct_requested": risk_pct, "stake": risk.position_size(balance, risk_pct)}


@server.tool()
def risk_progression(
    balance: float,
    base_stake: float,
    multiplier: float = 2.0,
    win_rate: float = 0.5,
    payout: float = 0.95,
    max_steps: int | None = None,
    n_contracts: int = 1000,
    simulations: int = 3000,
) -> dict:
    """What a loss progression (martingale when multiplier >= 1.5) commits, and its simulated ruin probability over a session."""
    out = {
        "progression": risk.describe_progression(balance, base_stake, multiplier, max_steps),
        "simulation": risk.simulate_progression(balance, base_stake, win_rate, payout, multiplier, max_steps,
                                                n_contracts, min(simulations, 20000)).to_dict(),
        "expectancy_per_unit_stake": risk.expectancy(win_rate, payout),
    }
    if max_steps is None and multiplier > 1:
        out["ruinous_streak"] = risk.ruin_streak_probability(balance, base_stake, multiplier, 1 - win_rate, n_contracts)
    out["note"] = "Assumes independent contracts and the stated win rate. Measure the real win rate on demo before trusting any number."
    return out


@server.tool()
async def market_symbols(market: str = "synthetic_index") -> list[dict]:
    """Active Deriv symbols for a market (synthetic_index, forex, indices, commodities, cryptocurrency)."""
    async with DerivPublicClient() as api:
        return await api.active_symbols(market)


@server.tool()
async def market_quote(symbol: str, contract_type: str = "CALL", duration: int = 5, duration_unit: str = "t",
                       stake: float = 10.0, barrier: str | None = None) -> dict:
    """Live price of a contract from the public Deriv API (no purchase): payout and the implied break-even win rate."""
    async with DerivPublicClient() as api:
        return await api.proposal(symbol, contract_type, duration, duration_unit, stake, barrier=barrier)


@server.tool()
async def market_tick_analysis(symbol: str = "R_100", count: int = 2000) -> dict:
    """Fetch recent ticks and test them for exploitable patterns (last-digit balance, up/down runs, momentum)."""
    async with DerivPublicClient() as api:
        ticks = await api.ticks_history(symbol, count)
    result = stats.analyze_ticks(ticks["prices"], ticks["pip_size"])
    result["symbol"] = symbol
    return result


def main() -> None:
    server.run("stdio")


if __name__ == "__main__":
    main()
