# 🧠 ORSTAC AI Cognitive Agent Stack

This directory contains the isolated infrastructure stack for the **ORSTAC AI Cognitive Agent**. It is designed to act as the repository's assistant brain, capable of retrieving semantic trading strategies, analyzing Blockly XML logic, and learning continuously from live operational feedback.

---

## 🛠️ Architecture & Technology Stack

The agent's infrastructure relies on the following components:
1. **n8n (AI-Native Runner):** The workflow engine that orchestrates decision logic, RAG (Retrieval-Augmented Generation) tools, and conversational memory.
2. **PostgreSQL + `pgvector`:** Database optimized for RAG. It stores vector embeddings generated from robots and blog articles, chat history, and episodic learning logs.
3. **Primary LLM (Gemini):** Used for logical reasoning, prompt inference, and response generation via API keys.
4. **Fallback LLM (DeepSeek):** Used as redundancy in case of API rate limits or primary endpoint downtime.

---

## 📂 Folders & Components Structure

```
orstac-agent/
├── README.md                  # This instruction file
├── docker-compose.yml         # Container orchestration for n8n & Postgres (pgvector)
├── .env.example               # Environment variables and credentials template
├── init-db.sql                # Database initialization and HNSW vector index setup
├── n8n_workflows/             # Exported JSON blueprints for n8n
│   ├── 01_ingest_resources.json  # Ingestion and vectorization workflow
│   ├── 02_cognitive_brain.json   # Interactive agent chat and RAG workflow
│   └── 03_learning_loop.json     # Continuous feedback learning loop webhook
└── knowledge/                 # RAG semantic knowledge documents & JSON stats
    ├── blog_insights.md       # Extracted strategies from the ORSTAC Blog
    ├── deriv_api_reference.md # WebSocket API reference & Blockly XML specifications
    ├── bot_mapping.md         # Statistical distribution and archetypes of the 3,360 bots
    ├── bot_catalog_raw.json   # Parsed JSON metadata of all 3,360 bots
    └── bot_analysis_summary.json # Aggregated catalog statistics
```

---

## 🚀 How to Run the Agent Stack

### Prerequisites
- Docker and Docker Compose installed.
- **Google Gemini API Key** (and optionally **DeepSeek API Key** for fallback).

### Step 1: Environment Configuration
1. Duplicate `.env.example` and rename it to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and fill in your credentials:
   - Configure PostgreSQL user and password.
   - Insert your Gemini API key.
   - Insert your DeepSeek API key (or local Ollama URL) if redundancy is desired.

### Step 2: Spin Up the Containers
In your terminal, inside the `orstac-agent/` directory, run:
```bash
docker compose up -d
```
This launches:
- A PostgreSQL container on port `5432` with pgvector capabilities.
- An n8n container accessible at `http://localhost:5678`.

### Step 3: Import and Activate Workflows in n8n
1. Open n8n in your browser: `http://localhost:5678`.
2. Create your administrator account.
3. Import the three JSON files from `n8n_workflows/`:
   - Navigate to **Workflows** -> **Add Workflow** -> **Import from file...**
4. Activate each workflow by clicking the **Active** toggle in the top-right corner.

### Step 4: Run Initial RAG Ingestion
Open `01_ingest_resources.json` in n8n and click **Execute Workflow** or listen to the trigger. This scans all markdown files inside `knowledge/` and the 3,360 XML bots in `Bots_XML`, generates their embeddings, and saves them to the Postgres `knowledge_base` table.

---

## 🧠 Continuous Feedback & Learning Loop

The `03_learning_loop.json` workflow exposes a webhook endpoint in n8n.
Every time a trade execution finishes (either in live trading or simulation/backtesting), status telemetries (payout, losses, martingale steps, market volatility) can be sent to this webhook.

The Agent processes the data:
1. Logs entry variables and results into `learning_logs`.
2. On anomalies (e.g. high loss sequences), it calls the LLM to deduce what went wrong under current market conditions.
3. The generated insight is saved as long-term episodic memory, enabling the agent to suggest dynamic stake changes or volatility filters in future chats.
