import asyncio
import json

import pytest

pytest.importorskip("mcp")

from orstac_agent.mcp_server import server  # noqa: E402

EXPECTED_TOOLS = {
    "orstac_premises", "audit_bot_xml", "audit_repository_bot", "risk_break_even",
    "risk_position_size", "risk_progression", "market_symbols", "market_quote", "market_tick_analysis",
}


def _call(name, args):
    return asyncio.run(server.call_tool(name, args))


def _payload(result):
    """Extract the structured or text payload from an MCP call result across SDK shapes."""
    if isinstance(result, tuple) and len(result) == 2:
        result = result[1] if result[1] is not None else result[0]
    if isinstance(result, dict):
        return result.get("result", result)
    if isinstance(result, list) and result and hasattr(result[0], "text"):
        return json.loads(result[0].text)
    if hasattr(result, "structured_content") and result.structured_content is not None:
        sc = result.structured_content
        return sc.get("result", sc) if isinstance(sc, dict) else sc
    if hasattr(result, "content"):
        return json.loads(result.content[0].text)
    return result


def test_tools_are_registered():
    tools = asyncio.run(server.list_tools())
    names = {t.name for t in (tools.tools if hasattr(tools, "tools") else tools)}
    assert EXPECTED_TOOLS <= names


def test_audit_repository_bot_and_traversal_guard():
    res = _payload(_call("audit_repository_bot", {"relative_path": "champions/Rise-Fall - Consistent - Trends.xml"}))
    assert res["risk_grade"] == "D" and res["file"].startswith("champions/")
    for bad in ("../../Windows/win.ini", "orstac-agent/pyproject.toml"):
        with pytest.raises(Exception):
            _payload(_call("audit_repository_bot", {"relative_path": bad}))


def test_risk_tools():
    be = _payload(_call("risk_break_even", {"payout": 1.0}))
    assert be["break_even_win_rate"] == pytest.approx(0.5)
    size = _payload(_call("risk_position_size", {"balance": 500, "risk_pct": 3}))
    assert size["stake"] == 10.0
    prog = _payload(_call("risk_progression", {"balance": 1000, "base_stake": 1, "multiplier": 2, "simulations": 500}))
    assert prog["progression"]["max_consecutive_losses_survivable"] == 9
    assert 0 < prog["simulation"]["ruin_probability"] < 1
