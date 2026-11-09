# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**This repository is public**, and its entire root is published to GitHub Pages. Never add credentials, tokens, server addresses, local machine paths, or data from other projects. Keep private notes outside the repo.

## What this repo is

ORSTAC is a content repository, not an application: ~3,360 open-source Deriv DBot trading bots (Blockly XML), trading PDFs/spreadsheets, a static landing page, and a self-hosted AI agent stack. There is no build, lint, or test tooling and no package manager.

## Layout and how the pieces connect

- `Bots_XML/<first char>/`: bot files bucketed by the first character of the filename (`0-9`, `A`–`Z`, plus a few single-file Unicode folders). Many filenames contain Vietnamese/Portuguese/Cyrillic characters, `$`, spaces and parentheses, so always quote paths. New bots go in the folder matching their first character. `CONTRIBUTING.md` lists the documentation each bot needs: timeframe, market, configurable variables, strategy, and best config.
- `champions/`: the 3 curated "elite" bots. Each has a `strategy_*.txt` guide and is described in `champions/README.md`.
- `docs/ROBOTS_INDEX.md`: a generated index linking every bot with URL-encoded relative links. The generator script is **not** in the repo, so when bots are added or renamed the index has to be updated by hand or by a new script. Non-ASCII names in it currently show mojibake (UTF-8 read as Latin-1).
- `docs/PDF/`: binary reference material (PDF, xlsx/xlsm, mp4). Don't edit.
- `index.html`: static landing page; it links to `docs/ROBOTS_INDEX.md`.
- `ai-catalog.json` and `.well-known/ai-catalog.json`: identical AI-discovery catalogs. Keep both in sync. `robots.txt` and `.nojekyll` support the Pages site.

## Deployment

`.github/workflows/static.yml` deploys the **entire repo root** to GitHub Pages on every push to `master`, with no build step. Anything committed gets published.

## orstac-agent/ (Python toolkit + MCP server)

Read-only risk and validation toolkit: Deriv Bot XML auditor, risk math, public Deriv API client, MCP server. It never trades.

```bash
cd orstac-agent
pip install -e ".[dev]"          # Python 3.10+
pytest -q                        # offline tests
ORSTAC_LIVE=1 pytest -q          # + live calls to the public Deriv API
pytest -q tests/test_risk.py::test_max_consecutive_losses_doubling   # single test
orstac-agent audit-repo ../Bots_XML    # aggregate audit (regenerate knowledge/repo_audit_*.{csv,json} after changing the auditor)
orstac-mcp                       # MCP server over stdio
```

- `src/orstac_agent/`: `risk.py` (break-even, position size, exact losing-streak probability, seeded Monte Carlo), `xml_audit.py` (heuristic static audit: progression = stake multiplied / increased by a multiple of the loss / step tables / Soros, inside `after_purchase` and procedures; session loss limit = comparison on `total_profit` or a session variable, not on the last contract), `stats.py` (digit chi-square, runs test, autocorrelation), `deriv_api.py` (public endpoint `wss://api.derivws.com/trading/v1/options/ws/public`; `proposal` needs `underlying_symbol`; trading/auth calls are refused), `mcp_server.py` (MCP SDK 2.x `MCPServer`; repository paths are confined to the repo root), `premises.py`.
- Auditor changes must be checked against hand-inspected bots: the champions' tests in `tests/test_xml_audit.py` encode verified results (Candlestick v2 = Soros/B, safe profit pro = capped martingale/C, Rise-Fall = martingale without stop/D).
- `docker-compose.yml`, `init-db.sql`, `n8n_workflows/` are an earlier, non-functional n8n experiment (wrong node types, no connections, retired models); see the README before touching them.
- `knowledge/`: RAG material plus the generated audit (`repo_audit_2026-11.csv`, `repo_audit_summary_2026-11.json`). `bot_catalog_raw.json` comes from an older parser that under-counts martingale.

## Conventions

- Docs are in English. Bot filenames and contents keep their original language.
- Trading content must keep the demo-account and risk warnings already present in the READMEs.
- Some third-party bot XMLs embed their authors' own Telegram bot tokens (in notify blocks). Don't copy them into new docs or bots.
