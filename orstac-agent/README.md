# ORSTAC Agent

Open-source, **read-only** risk and validation toolkit for Deriv trading bots, built by the ORSTAC community.
You can use it in three ways: as a **command-line tool**, as a **Python library**, or as an **MCP server** that gives any AI assistant (Claude, ChatGPT, n8n, Cursor, and others) the same tools.

It does three things:

1. **Audits Deriv Bot XML files.** It reports the market, the contract, how the stake changes after a loss (martingale detection), whether the bot stops by itself, and a risk grade from A to D.
2. **Computes risk.** Break-even win rate, position size under the 1% rule, how long a stake progression survives, the exact probability of losing streaks, and seeded Monte Carlo ruin simulations.
3. **Reads the official Deriv API (public endpoint, no account needed).** Live contract prices with the implied break-even rate, active symbols, and tick history with statistical tests for exploitable patterns.

It never places trades, never asks for API tokens and never touches an account.

> Trading involves significant risk and you can lose your entire stake. Test every strategy on a demo account first. Nothing here is financial advice or a promise of profit.

## The ORSTAC premises

Every tool and answer follows these rules ([`premises.py`](src/orstac_agent/premises.py)):

1. Demo account first. Real money only after a recorded demo sample and with minimum stake.
2. No promises of profit. Past results do not predict future results.
3. Define the maximum loss before the expected gain.
4. Risk at most 1% (ceiling 2%) of the balance per contract. On fixed-stake contracts the stake is the maximum loss.
5. Code hard limits into the bot: daily loss, maximum drawdown and consecutive losses. The bot stops by itself.
6. ORSTAC recommends against martingale. Any progression needs a hard cap on steps and stake, and a ruin test before going live.
7. A backtest is a filter, not proof. Use large samples and out-of-sample tests, and report how many configurations were tried.
8. Win rate means nothing without the payout. Judge by expectancy, break-even rate and drawdown.
9. Rules are written before trading. Changes follow a process (hypothesis, test, version), never right after a loss.
10. No data, no claim.

## Install

Requires Python 3.10+.

```bash
cd orstac-agent
pip install -e ".[mcp]"        # CLI + MCP server
pip install -e ".[dev]"        # + tests
```

## Command line

```bash
# Audit one bot
orstac-agent audit "../champions/safe profit pro.xml"

# Audit a whole folder and get the aggregate picture
orstac-agent audit-repo ../Bots_XML --top 10

# Live price of a contract and its break-even win rate (no purchase)
orstac-agent quote R_100 --type CALL --duration 5
orstac-agent quote R_100 --type DIGITDIFF --duration 1 --barrier 5

# What a martingale really commits, and its ruin probability over a session
orstac-agent ruin --balance 1000 --stake 1 --multiplier 2 --win-rate 0.5 --payout 0.95 --contracts 500

# Are there patterns in recent ticks? (last digit, streaks, momentum)
orstac-agent analyze R_100 --count 3000

# ORSTAC Lab: price, simulate and rank every bot in a folder
orstac-agent lab Bots_XML --out knowledge/lab_ranking.json
```

Example outputs, measured on 2026-11-09:

| Question | Result |
|---|---|
| Break-even win rate of a 5-tick CALL on R_100 (stake 10, payout 19.54) | 51.2% |
| Break-even of DIGITDIFF on R_100 (stake 10, payout 10.96) vs. the true probability of 90% | 91.2%: the expectancy is negative by design |
| Ruin probability of a 2.071x martingale, balance 1,000, base stake 1, 500 contracts | 39% (3,000 seeded simulations). The median session ends in profit, but the mean ends below the starting balance. |
| 3,000 R_100 ticks: last-digit, runs and autocorrelation tests | No detectable pattern (p = 0.74, 0.44, 0.96) |

## MCP server (for AI assistants)

```bash
orstac-mcp        # stdio transport
```

Claude Desktop / Claude Code configuration:

```json
{
  "mcpServers": {
    "orstac": { "command": "orstac-mcp" }
  }
}
```

In n8n, add an **MCP Client Tool** node to an AI Agent and point it at the same command (or run it behind an MCP gateway).

| Tool | What it does |
|---|---|
| `orstac_premises` | The rules every answer must follow |
| `audit_bot_xml` | Audit a bot from its XML text |
| `audit_repository_bot` | Audit a bot by its path inside this repository (paths outside the repository are refused) |
| `risk_break_even` | Break-even win rate for a payout |
| `risk_position_size` | Stake under the 1% rule (capped at 2%) |
| `risk_progression` | Cost, survivable losing streak and simulated ruin probability of a stake progression |
| `market_symbols` | Active Deriv symbols by market |
| `market_quote` | Live contract price and break-even win rate (no purchase) |
| `market_tick_analysis` | Statistical tests for exploitable patterns in recent ticks |

## Repository audit (November 2026)

`orstac-agent audit-repo Bots_XML` over the community repository (3,310 parsable bots):

| Finding | Value |
|---|---|
| Bots with a martingale-style progression (stake multiplied by 1.5x or more after a loss, including step tables) | 1,995 (60%) |
| Bots with a session loss limit (the bot stops by itself on losses) | 50% |
| Grade A: no progression and a session loss limit | 357 (11%) |
| Grade D: martingale and no session loss limit | 792 (24%) |
| Most traded symbol | R_100 (1,985 bots) |
| Most common contract types | Rise/Fall 1,136, Over/Under 710, Matches/Differs 457 |

A common pattern to watch for is `stake += |last loss| × 1.071`. It looks like a small factor, but the next stake becomes about **2.07 times** the previous one. That is a full martingale, not a "soft" recovery.

How the audit works: it parses the Blockly XML statically and never runs the bot. A progression is a stake variable that is multiplied after a result, increased by a multiple of the loss, picked from a growing step table (for example `0.35,0.72,1.5,3.1`), or increased by the last profit (Soros). The audit looks inside `after_purchase` and the functions it calls. A session loss limit is a comparison on the session result (`total_profit` or a session variable) against a loss value. A cap on the last contract only does not count. The audit is heuristic and was validated against hand-checked samples, but read the bot before trusting any grade.

## ORSTAC Lab (November 2026)

Volatility indices (`R_*`, `1HZ*V`) come from a random number generator, so indicators cannot change the probability of a contract. A bot's long-run result then depends only on four things: the contract's true win probability, the payout Deriv quotes for it, the stake progression and the limits the bot enforces. The Lab measures exactly that for every bot in the repository. The full output is in [`knowledge/lab_ranking_2026-11.json`](knowledge/lab_ranking_2026-11.json).

**Protocol** (the same for every bot, so the ranking compares strategies, not settings):

- Bankroll of 100 units, base stake of 1 unit (the 1% rule), sessions of up to 1,000 contracts, 2,000 seeded sessions per distinct strategy.
- If the bot has a session loss limit, the session stops at -20 units. If it has a profit target, it stops at +10 units.
- Ruin means the balance cannot pay the next stake the bot asks for.
- The true probability is exact for digit contracts (each last digit is 1 in 10). For rise/fall the Lab uses 0.5, which is slightly generous because a tie loses.
- Payouts are real quotes from the public Deriv API (stake 10 USD, 254 contracts priced on 2026-11-09).
- **ORSTAC Score** (0-100) = 50 × (1 - ruin probability) + 20 for a stop-loss + 15 × progression (none 1, Soros 0.6, soft 0.4, martingale 0) + 15 × (1 - house edge / 10%).
- **Admitted** only with ruin below 1%, a session stop-loss, no martingale and a contract house edge of 5% or less.

**Results:**

| Finding | Value |
|---|---|
| Bots modeled exactly (RNG indices, digit and rise/fall contracts) | 2,244 of 3,310 |
| Admitted by the protocol | 305 |
| Expected loss per 100 contracts, flat stake (median) | 2.3 units |
| Expected loss per 100 contracts, martingale (median) | 8.9 units, almost 4 times more |
| Martingale bots with more than 50% ruin in one 1,000-contract session | 284 |
| Cheapest contracts (house edge) | DIGITDIFF, Over 0, Under 9: 1.4% |
| Rise/Fall, Even/Odd | 2.3% to 2.4% |
| Most expensive contracts | DIGITMATCH, Over 8, Under 1: 10.7% |

Every contract has a negative expectation, so no bot is "profitable" here. The Score ranks how safely a bot loses its edge to the house: flat stakes, a stop-loss and cheap contracts come first. Not modeled yet: contracts that depend on a barrier (Higher/Lower, Touch), digit predictions chosen at runtime for Over/Under, and non-RNG markets such as forex.

## Library

```python
from orstac_agent import risk
from orstac_agent.xml_audit import audit_file
from orstac_agent.deriv_api import DerivPublicClient, run

risk.break_even_win_rate(0.95)                    # 0.5128
risk.prob_losing_streak(9, 1000, 0.5)             # exact probability of 9 losses in a row within 1,000 contracts
audit_file("champions/safe profit pro.xml").risk_grade

async def quote():
    async with DerivPublicClient() as api:
        return await api.proposal("R_100", "CALL", 5, "t", 10)
run(quote())
```

## Tests

```bash
pytest -q                     # offline tests
ORSTAC_LIVE=1 pytest -q       # also calls the public Deriv API
```

The test suite checks the exact streak probabilities against brute-force simulation, the simulations against analytical expectancy, the audit on synthetic and real bots, the refusal of trading calls, and MCP path-traversal protection.

## Deriv API notes

- Public endpoint: `wss://api.derivws.com/trading/v1/options/ws/public` (no authentication). The old `wss://ws.derivws.com/websockets/v3?app_id=...` endpoint returned HTTP 520 when tested in November 2026.
- `proposal` requires `underlying_symbol`. The legacy `symbol` field is rejected.
- Documentation: <https://developers.deriv.com/>. Rate limits: <https://developers.deriv.com/docs/limits/>.

## Experimental: n8n + pgvector stack

`docker-compose.yml`, `init-db.sql` and `n8n_workflows/` contain an earlier experiment: an n8n chat agent with a pgvector knowledge base. **It is not functional as published.** The workflow exports have these known problems:

- They use node types that do not exist in current n8n (for example `n8n-nodes-base.agent` instead of `@n8n/n8n-nodes-langchain.agent`).
- The nodes have no connections between them.
- They reference the retired `gemini-1.5-*` models.
- The ingestion workflow lists files with a Windows `dir` command inside a Linux container and never computes embeddings.

To use n8n, build a new AI Agent workflow in the n8n UI and connect it to the ORSTAC MCP server above. The `knowledge/` folder can still serve as RAG source material.

## License

MIT, like the rest of the repository.
