"""Read-only client for the official Deriv API (public WebSocket endpoint).

Uses the public endpoint documented at https://developers.deriv.com/docs/intro/api-overview/
which needs no authentication. Only market-data and pricing calls are allowed: this module
refuses any call that could trade, authenticate or touch an account.
"""

from __future__ import annotations

import asyncio
import itertools
import json
import os
from typing import Any

import websockets

PUBLIC_WS_URL = os.environ.get("DERIV_PUBLIC_WS_URL", "wss://api.derivws.com/trading/v1/options/ws/public")
USER_AGENT = "orstac-agent/2.0 (+https://github.com/alanvito1/ORSTAC)"

# Calls this client may send. Anything else (buy, sell, authorize, transfer, ...) is refused.
ALLOWED_CALLS = {"ping", "time", "active_symbols", "ticks_history", "contracts_for", "proposal"}


class DerivAPIError(RuntimeError):
    def __init__(self, code: str, message: str, details: Any = None):
        super().__init__(f"{code}: {message}")
        self.code, self.details = code, details


class DerivPublicClient:
    """Minimal async client. Use as `async with DerivPublicClient() as api: ...`."""

    def __init__(self, url: str = PUBLIC_WS_URL, timeout: float = 15.0):
        self.url, self.timeout = url, timeout
        self._ws = None
        self._ids = itertools.count(1)

    async def __aenter__(self) -> "DerivPublicClient":
        self._ws = await websockets.connect(self.url, open_timeout=self.timeout, user_agent_header=USER_AGENT)
        return self

    async def __aexit__(self, *exc) -> None:
        if self._ws is not None:
            await self._ws.close()

    async def call(self, request: dict) -> dict:
        name = next((k for k in request if k in ALLOWED_CALLS), None)
        if name is None or any(k in request for k in ("buy", "sell", "authorize", "transfer_between_accounts")):
            raise PermissionError(f"Call not allowed by the read-only ORSTAC client: {sorted(request)}")
        if self._ws is None:
            raise RuntimeError("Client is not connected; use 'async with DerivPublicClient()'.")
        req_id = next(self._ids)
        await self._ws.send(json.dumps({**request, "req_id": req_id}))
        while True:
            msg = json.loads(await asyncio.wait_for(self._ws.recv(), self.timeout))
            if msg.get("req_id") not in (None, req_id):
                continue  # stray message from another request
            if "error" in msg:
                err = msg["error"]
                raise DerivAPIError(err.get("code", "Error"), err.get("message", ""), err.get("details"))
            return msg

    async def ping(self) -> bool:
        return (await self.call({"ping": 1})).get("ping") == "pong"

    async def active_symbols(self, market: str | None = None) -> list[dict]:
        rows = (await self.call({"active_symbols": "brief"}))["active_symbols"]
        if market:
            rows = [r for r in rows if r.get("market") == market]
        return [
            {
                "symbol": r.get("underlying_symbol"),
                "name": r.get("underlying_symbol_name"),
                "market": r.get("market"),
                "submarket": r.get("submarket"),
                "open": bool(r.get("exchange_is_open")),
                "suspended": bool(r.get("is_trading_suspended")),
                "pip_size": r.get("pip_size"),
            }
            for r in rows
        ]

    async def ticks_history(self, symbol: str, count: int = 1000) -> dict:
        count = max(1, min(int(count), 5000))
        msg = await self.call({"ticks_history": symbol, "count": count, "end": "latest", "style": "ticks"})
        hist = msg["history"]
        return {"symbol": symbol, "prices": hist["prices"], "times": hist.get("times", []), "pip_size": msg.get("pip_size")}

    async def contracts_for(self, symbol: str) -> list[str]:
        msg = await self.call({"contracts_for": symbol})
        return sorted({c["contract_type"] for c in msg["contracts_for"]["available"]})

    async def proposal(
        self,
        symbol: str,
        contract_type: str,
        duration: int,
        duration_unit: str = "t",
        stake: float = 10.0,
        currency: str = "USD",
        barrier: str | None = None,
    ) -> dict:
        """Price a contract (no purchase). Returns payout and the implied break-even win rate."""
        req = {
            "proposal": 1, "amount": stake, "basis": "stake", "contract_type": contract_type,
            "currency": currency, "duration": duration, "duration_unit": duration_unit,
            "underlying_symbol": symbol,
        }
        if barrier is not None:
            req["barrier"] = barrier
        p = (await self.call(req))["proposal"]
        stake_paid = float(p["ask_price"])
        payout = float(p["payout"])
        net = (payout - stake_paid) / stake_paid if stake_paid else 0.0
        return {
            "symbol": symbol,
            "contract_type": contract_type,
            "duration": f"{duration}{duration_unit}",
            "stake": stake_paid,
            "payout": payout,
            "net_payout_ratio": round(net, 4),
            "break_even_win_rate": round(1 / (1 + net), 4) if net > 0 else None,
            "description": p.get("longcode"),
        }


def run(coro):
    """Run a coroutine from synchronous code (CLI, tests)."""
    return asyncio.run(coro)
