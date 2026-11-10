"""Static risk audit of Deriv Bot (DBot / Blockly) XML files.

The audit is heuristic: it reads the block structure, never executes the bot, and reports
what it found together with how confident it is. It answers the questions a careful trader
asks before running a downloaded bot: what does it trade, how does the stake change after a
loss, and does it stop by itself?
"""

from __future__ import annotations

import math
import re
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field, asdict
from pathlib import Path

INDICATOR_BLOCKS = {
    "rsi": "RSI", "rsia": "RSI", "rsi_statement": "RSI",
    "sma": "SMA", "smaa": "SMA", "sma_statement": "SMA",
    "ema": "EMA", "emaa": "EMA", "ema_statement": "EMA",
    "bb": "Bollinger Bands", "bba": "Bollinger Bands", "bb_statement": "Bollinger Bands",
    "macda": "MACD", "macd": "MACD", "macd_statement": "MACD",
    "last_digit": "Last digit", "is_candle_black": "Candle colour",
    "ohlc": "OHLC", "ohlc_values": "OHLC", "read_ohlc": "OHLC", "get_ohlc": "OHLC",
}
PROGRESSION_NAME = re.compile(r"martin|gale|multipl|fator|factor|mult\b|recover", re.I)
SOROS_NAME = re.compile(r"soros", re.I)
LOSS_LIMIT_NAME = re.compile(r"loss|lose|loose|perda|preju|\bsl\b|stop(?!.{0,6}(win|gain|lucro|profit|meta|ganho))", re.I)
PROFIT_TARGET_NAME = re.compile(r"take.?profit|target|meta|expected.?profit|expectativa|lucro|\btp\b|profit.?goal", re.I)
STAKE_NAME = re.compile(r"stake|amount|aposta|valor|entrada|initial|inicial|montante", re.I)


def _strip_ns(root: ET.Element) -> None:
    for el in root.iter():
        if isinstance(el.tag, str) and "}" in el.tag:
            el.tag = el.tag.split("}", 1)[1]


def _field(el: ET.Element, name: str) -> str | None:
    for f in el.iter("field"):
        if f.get("name") == name:
            return (f.text or "").strip()
    return None


def _numbers(el: ET.Element) -> list[float]:
    out = []
    for b in el.iter("block"):
        if b.get("type") == "math_number":
            try:
                out.append(float(_field(b, "NUM") or "nan"))
            except ValueError:
                pass
    return [x for x in out if x == x]


def _static_number(value: ET.Element) -> tuple[float | None, bool]:
    """(number, dynamic) for a block input: a literal math_number (block or shadow) or something computed."""
    kids = [c for c in value if c.tag in ("block", "shadow")]
    node = next((c for c in kids if c.tag == "block"), None)
    if node is None:
        node = next((c for c in kids if c.tag == "shadow"), None)
    if node is None:
        return None, False
    if node.get("type") == "math_number":
        try:
            return float(_field(node, "NUM") or "nan"), False
        except ValueError:
            return None, True
    return None, True


TRADE_OPTIONS_TYPES = ("tradeOptions", "trade_definition_tradeoptions")  # legacy and current Deriv Bot


def _value_numbers(b: ET.Element) -> list[float]:
    """Numbers in a variables_set's own VALUE input, not in the statements chained after it (<next>)."""
    v = next((x for x in b.findall("value") if x.get("name") == "VALUE"), None)
    return _numbers(v) if v is not None else []


def _var_names(el: ET.Element) -> list[str]:
    return [(f.text or "").strip() for f in el.iter("field") if f.get("name") == "VAR"]


@dataclass
class BotAudit:
    file: str = ""
    parsed: bool = False
    error: str | None = None
    market: str | None = None
    submarket: str | None = None
    symbol: str | None = None
    trade_category: str | None = None
    trade_type: str | None = None
    contract_side: str | None = None
    duration: float | None = None
    duration_unit: str | None = None
    prediction: float | None = None     # digit prediction / barrier when it is a fixed number
    prediction_dynamic: bool = False    # True when the prediction comes from a variable or expression
    initial_stake: float | None = None
    indicators: list[str] = field(default_factory=list)
    progression: str = "none"          # none | soft | martingale | soros
    progression_multiplier: float | None = None
    has_loss_limit: bool = False
    has_profit_target: bool = False
    asks_user_input: bool = False
    risk_grade: str = "?"
    flags: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return asdict(self)


PROGRESSION_COUNTER = re.compile(r"level|n[ií]vel|qtde|count|contador|step|passo", re.I)
PROFIT_VAR = re.compile(r"lucro|profit|ganho|\bwin\b|payout|retorno", re.I)
NUMBER_LIST = re.compile(r"^\s*\d+(?:\.\d+)?(?:\s*[,;]\s*\d+(?:\.\d+)?){3,}\s*$")


def _stake_factor_lists(root: ET.Element) -> list[list[float]]:
    """Comma-separated number lists that a bot splits into a list (lists_split) or builds with
    lists_create_with: the usual way to encode a step-by-step stake table."""
    out: list[list[float]] = []
    types = {b.get("type") for b in root.iter("block")}
    if "lists_split" in types:
        for b in root.iter("block"):
            if b.get("type") == "text":
                txt = _field(b, "TEXT") or ""
                if NUMBER_LIST.match(txt):
                    out.append([float(x) for x in re.split(r"\s*[,;]\s*", txt.strip())])
    for b in root.iter("block"):
        if b.get("type") == "lists_create_with":
            direct = [c for c in b.findall("value")]
            nums = []
            for v in direct:
                inner = v.find("block")
                if inner is not None and inner.get("type") == "math_number":
                    try:
                        nums.append(float(_field(inner, "NUM") or "nan"))
                    except ValueError:
                        pass
            if len(nums) >= 4 and len(nums) == len(direct):
                out.append(nums)
    return out


def _stake_vars(root: ET.Element) -> set[str]:
    """Variables that hold the stake: the one wired into the trade AMOUNT, plus stake-like names."""
    out: set[str] = set()
    for b in root.iter("block"):
        if b.get("type") in TRADE_OPTIONS_TYPES:
            for v in b.findall("value"):
                if v.get("name") == "AMOUNT":
                    out.update(_var_names(v))
        if b.get("type") == "purchase":
            pass
    for b in root.iter("block"):
        if b.get("type") in ("variables_set", "math_change"):
            names = _var_names(b)[:1]
            if names and STAKE_NAME.search(names[0]) and not PROGRESSION_NAME.search(names[0]):
                out.add(names[0])
    return out


def _detect_progression(root: ET.Element) -> tuple[str, float | None]:
    # Stake changes after a result live in after_purchase or in functions it calls.
    scopes = [b for b in root.iter("block")
              if b.get("type") in ("after_purchase", "procedures_defnoreturn", "procedures_defreturn")]
    if not scopes:
        scopes = [root]
    stake_vars = _stake_vars(root)
    multipliers: list[float] = []
    positive_progression = False
    for s in scopes:
        for b in s.iter("block"):
            kind = b.get("type")
            target = (_var_names(b)[:1] or [""])[0]
            if kind not in ("variables_set", "math_change") or target not in stake_vars:
                continue
            value = next((v for v in b.findall("value") if v.get("name") in ("VALUE", "DELTA")), None)
            if value is None:
                continue
            mults = [m for m in value.iter("block") if m.get("type") == "math_arithmetic" and _field(m, "OP") == "MULTIPLY"]
            if kind == "variables_set":
                # stake = something x f  (f > 1 grows the stake after a loss)
                for m in mults:
                    multipliers += [n for n in _numbers(m) if 1.0 < n <= 20.0]
            else:
                # stake += something x f  ->  next stake ~ (1 + f) x previous when "something" is the lost stake
                for m in mults:
                    multipliers += [1.0 + n for n in _numbers(m) if 0.0 < n <= 20.0]
                inner = {x.get("type") for x in value.iter("block")}
                if not mults and inner & {"read_details", "math_single"}:
                    multipliers.append(2.0)  # stake += |last loss|: classic recovery doubling
            # stake = stake + profit  /  stake += profit: reinvesting winnings (Soros, positive progression)
            if not mults:
                adds_profit = any(PROFIT_VAR.search(v) for v in _var_names(value)) and (
                    kind == "math_change" or any(_field(m, "OP") == "ADD" for m in value.iter("block")
                                                 if m.get("type") == "math_arithmetic"))
                if adds_profit:
                    positive_progression = True
    multiply_blocks = [m for s in scopes for m in s.iter("block")
                       if m.get("type") == "math_arithmetic" and _field(m, "OP") == "MULTIPLY"]

    # A factor stored in a variable with a telling name ("Martingale Factor" = 2.1),
    # possibly typed by the user at start (value unknown statically).
    factor_vars = {v for m in multiply_blocks for v in _var_names(m)
                   if PROGRESSION_NAME.search(v) and not PROGRESSION_COUNTER.search(v)}
    runtime_factor = False
    for b in root.iter("block"):
        if b.get("type") == "variables_set":
            names = _var_names(b)[:1]
            if names and names[0] in factor_vars:
                nums = [n for n in _value_numbers(b) if 1.0 < n <= 20.0]
                if nums:
                    multipliers += nums
                else:
                    runtime_factor = True
    if factor_vars and not multipliers:
        runtime_factor = True

    # Progression through a list of stake factors chosen by step (e.g. "0.35,0.72,1.5,3.1,6.43").
    for factors in _stake_factor_lists(root):
        ratios = [b / a for a, b in zip(factors, factors[1:]) if a > 0]
        if ratios and all(r > 1.0 for r in ratios):
            multipliers.append(math.exp(sum(math.log(r) for r in ratios) / len(ratios)))

    if multipliers:
        m = max(multipliers)
        return ("martingale" if m >= 1.5 else "soft"), m
    if runtime_factor:
        return "martingale", None  # factor defined at runtime: treat conservatively
    if positive_progression or any(SOROS_NAME.search(n) for n in _var_names(root)):
        return "soros", None
    return "none", None


SESSION_NAME = re.compile(r"total|lucro|profit|saldo|balance|banca|pnl|resultado", re.I)


def _detect_limits(root: ET.Element) -> tuple[bool, bool]:
    """Session-level limits: comparisons on the session result (total_profit or a session variable).

    A comparison on the last contract only (read_details) is a per-contract rule, not a session stop.
    What is compared against decides the kind: loss-like names / negative values -> loss limit;
    profit-like names / positive values -> profit target.
    """
    loss, profit = False, False
    for b in root.iter("block"):
        if b.get("type") != "logic_compare":
            continue
        types = {x.get("type") for x in b.iter("block")}
        names = _var_names(b)
        session = "total_profit" in types or any(SESSION_NAME.search(n) and not LOSS_LIMIT_NAME.search(n) for n in names)
        if not session:
            continue
        negative = any(x.get("type") == "math_single" and _field(x, "OP") == "NEG" for x in b.iter("block")) \
            or any(n < 0 for n in _numbers(b))
        loss_named = any(LOSS_LIMIT_NAME.search(n) for n in names)
        profit_named = any(PROFIT_TARGET_NAME.search(n) and not SESSION_NAME.fullmatch(n.strip()) for n in names
                           if not LOSS_LIMIT_NAME.search(n))
        positive_number = any(n > 0 for n in _numbers(b))
        if loss_named or negative:
            loss = True
        elif profit_named or positive_number:
            profit = True
    return loss, profit


def _initial_stake(root: ET.Element) -> float | None:
    for b in root.iter("block"):
        if b.get("type") in TRADE_OPTIONS_TYPES:
            for v in b.findall("value"):
                if v.get("name") == "AMOUNT":
                    n, dynamic = _static_number(v)
                    if n is not None:
                        return n
                    # stake wired to a variable: use the value the bot assigns to it
                    names = set(_var_names(v))
                    for s in root.iter("block"):
                        if s.get("type") == "variables_set" and _var_names(s)[:1] and _var_names(s)[0] in names:
                            nums = _value_numbers(s)
                            if nums:
                                return nums[0]
    for b in root.iter("block"):
        if b.get("type") == "variables_set":
            names = _var_names(b)[:1]
            if names and STAKE_NAME.search(names[0]) and not PROGRESSION_NAME.search(names[0]):
                nums = _value_numbers(b)
                if nums:
                    return nums[0]
    return None


def _grade(a: BotAudit) -> None:
    flags = []
    if a.progression == "martingale":
        factor = f"x{a.progression_multiplier:g}" if a.progression_multiplier else "a factor set at runtime"
        flags.append(f"Martingale-style progression (stake {factor} after losses): high risk of ruin.")
    elif a.progression == "soft":
        flags.append(f"Soft progression (x{a.progression_multiplier:g} after losses): losses compound; cap the steps.")
    elif a.progression == "soros":
        flags.append("Soros (positive progression): wins are reinvested; cap the reinvestment.")
    if not a.has_loss_limit:
        flags.append("No session loss limit detected: the bot may not stop by itself.")
    if not a.has_profit_target:
        flags.append("No profit target detected.")
    if a.trade_category == "digits":
        flags.append("Digit contract: outcomes depend on the last digit of synthetic ticks; check the payout and break-even rate.")
    if a.asks_user_input:
        flags.append("Asks for input at start: real risk depends on the values you type.")
    if a.initial_stake is None:
        flags.append("Initial stake not found statically.")
    a.flags = flags

    if a.progression == "martingale" and not a.has_loss_limit:
        a.risk_grade = "D"
    elif a.progression == "martingale" or not a.has_loss_limit:
        a.risk_grade = "C"
    elif a.progression in ("soft", "soros"):
        a.risk_grade = "B"
    else:
        a.risk_grade = "A"


def audit_xml(xml_text: str, file: str = "") -> BotAudit:
    a = BotAudit(file=file)
    try:
        root = ET.fromstring(xml_text.encode("utf-8") if isinstance(xml_text, str) else xml_text)
    except ET.ParseError as exc:
        a.error = f"XML parse error: {exc}"
        return a
    _strip_ns(root)
    if not any(b.get("type") in ("trade", "trade_definition", "purchase") for b in root.iter("block")):
        a.error = "Not a Deriv Bot file (no trade or purchase block)."
        return a
    a.parsed = True
    a.market = _field(root, "MARKET_LIST")
    a.submarket = _field(root, "SUBMARKET_LIST")
    a.symbol = _field(root, "SYMBOL_LIST")
    a.trade_category = _field(root, "TRADETYPECAT_LIST")
    a.trade_type = _field(root, "TRADETYPE_LIST")
    a.contract_side = _field(root, "PURCHASE_LIST")
    a.duration_unit = _field(root, "DURATIONTYPE_LIST")
    for b in root.iter("block"):
        if b.get("type") in TRADE_OPTIONS_TYPES:
            for v in b.findall("value"):
                if v.get("name") == "DURATION":
                    a.duration, _ = _static_number(v)
                elif v.get("name") == "PREDICTION":
                    a.prediction, a.prediction_dynamic = _static_number(v)
    a.initial_stake = _initial_stake(root)
    types = [b.get("type") for b in root.iter("block")]
    a.indicators = sorted({INDICATOR_BLOCKS[t] for t in types if t in INDICATOR_BLOCKS})
    a.asks_user_input = "text_prompt_ext" in types
    a.progression, a.progression_multiplier = _detect_progression(root)
    a.has_loss_limit, a.has_profit_target = _detect_limits(root)
    _grade(a)
    return a


def audit_file(path: str | Path) -> BotAudit:
    p = Path(path)
    return audit_xml(p.read_text(encoding="utf-8", errors="replace"), file=str(p))
