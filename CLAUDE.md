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

## orstac-agent/ (AI agent stack)

Run from `orstac-agent/`:
```bash
cp .env.example .env      # fill Postgres creds, GEMINI_API_KEY, optional DEEPSEEK_API_KEY
docker compose up -d      # Postgres+pgvector on :5432, n8n on http://localhost:5678
```
Then import the three `n8n_workflows/*.json` files in the n8n UI and activate them.

- `docker-compose.yml` mounts the repo root (`../`) read-only into n8n at `/home/node/orstac_workspace`. `init-db.sql` only runs on the first Postgres start, when the volume is empty.
- DB schema (`init-db.sql`):
  - `knowledge_base`: RAG store. `embedding vector(768)` is sized for Gemini `text-embedding-004`; use 1536 for OpenAI embeddings.
  - `chat_conversations`: n8n Postgres chat memory.
  - `learning_logs`: telemetry and episodic insights.
- Workflows:
  - `01_ingest_resources`: schedule → list files → read → insert into `knowledge_base`.
  - `02_cognitive_brain`: chat trigger → agent with Gemini as primary LLM and an OpenAI-compatible DeepSeek fallback, Postgres memory, and a vector-store tool.
  - `03_learning_loop`: webhook `telemetry-receiver` → log to `learning_logs` → LLM insight.
- Known gaps in `01_ingest_resources.json`:
  - The Execute Command node uses the Windows command `dir /s /b C:\home\node\...`, but n8n runs in a Linux container.
  - It doesn't scan `orstac-agent/knowledge/`, although the README says it does.
  - The insert doesn't populate `embedding`.
- `knowledge/` holds the RAG source docs. `bot_catalog_raw.json` and `bot_analysis_summary.json` came from a parser that is not in the repo. Each `bot_catalog_raw.json` entry has the bot's path, symbol, market/trade category, trade type, indicators, martingale/soros flags, and variables. `bot_mapping.md` summarizes both files.

## Conventions

- Docs are in English. Bot filenames and contents keep their original language.
- Trading content must keep the demo-account and risk warnings already present in the READMEs.
- Some third-party bot XMLs embed their authors' own Telegram bot tokens (in notify blocks). Don't copy them into new docs or bots.
