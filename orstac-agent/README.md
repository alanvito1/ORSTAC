# 🧠 ORSTAC AI Cognitive Agent Stack

Este diretório contém a pilha de infraestrutura isolada do **Agente Cognitivo Autônomo da ORSTAC**. Ele foi construído para servir como o cérebro assistente do repositório, capaz de recuperar estratégias de negociação semânticas, analisar a lógica de blocos XML e aprender constantemente por meio de feedback operacional de execuções.

---

## 🛠️ Arquitetura e Pilha de Tecnologia

A infraestrutura do agente baseia-se nos seguintes pilares:
1. **n8n (AI-Native Runner):** Motor de fluxos que orquestra a lógica de decisão, ferramentas de RAG (Retrieval-Augmented Generation) e memória conversacional.
2. **PostgreSQL + `pgvector`:** Banco de dados otimizado para RAG. Ele armazena vetores de embeddings gerados pelos robôs e artigos, histórico de chat e logs de aprendizado contínuo.
3. **LLM Primário (Gemini):** Utilizado para inferência de raciocínio lógico e geração de respostas através de chaves de API.
4. **LLM Fallback (DeepSeek):** Utilizado como contingência caso ocorram limites de cota ou falha na API primária.

---

## 📂 Estrutura de Pastas e Componentes

```
orstac-agent/
├── README.md                  # Este arquivo de instruções
├── docker-compose.yml         # Orquestração do n8n e Postgres (pgvector)
├── .env.example               # Template de variáveis de ambiente e credenciais
├── init-db.sql                # Inicializador de tabelas e indexador vetorial HNSW
├── n8n_workflows/             # Fluxos exportados em JSON para o n8n
│   ├── 01_ingest_resources.json  # Fluxo de ingestão e vetorização de bots/textos
│   ├── 02_cognitive_brain.json   # Fluxo de chat interativo e RAG
│   └── 03_learning_loop.json     # Loop de aprendizado constante por Webhook
└── knowledge/                 # Base de conhecimento de RAG em Markdown e JSON
    ├── blog_insights.md       # Insights extraídos do Blog ORSTAC
    ├── deriv_api_reference.md # Referência da API WebSocket da Deriv e Blockly XML
    ├── bot_mapping.md         # Mapeamento estatístico e arquétipos dos 3.360 bots
    ├── bot_catalog_raw.json   # Dados estruturados de todos os bots para busca
    └── bot_analysis_summary.json # Estatísticas consolidadas do catálogo
```

---

## 🚀 Como Executar a Pilha do Agente

### Requisitos Prévios
- Docker e Docker Compose instalados na máquina.
- Chave de API do **Google Gemini** (e opcionalmente do **DeepSeek** para fallback).

### Passo 1: Configuração do Ambiente
1. Duplique o arquivo `.env.example` e renomeie-o para `.env`:
   ```bash
   cp .env.example .env
   ```
2. Abra o arquivo `.env` e insira suas credenciais:
   - Defina usuário e senha do Postgres.
   - Insira sua chave Gemini no campo correspondente.
   - Insira sua chave DeepSeek (ou URL local do Ollama) se desejar ativar a redundância.

### Passo 2: Subir a Infraestrutura
No terminal, dentro desta pasta (`orstac-agent/`), execute o Docker Compose:
```bash
docker compose up -d
```
Isso iniciará:
- Um container Postgres na porta `5432` com suporte a indexação vetorial.
- Um container n8n acessível na porta `5678`.

### Passo 3: Importar e Ativar os Workflows no n8n
1. Acesse o n8n no seu navegador: `http://localhost:5678`.
2. Crie sua conta de administrador local.
3. Importe os três arquivos JSON de fluxos contidos em `n8n_workflows/`:
   - Vá em **Workflows** -> **Add Workflow** -> **Import from file...**
4. Ative os fluxos clicando no interruptor **Active** no canto superior direito de cada fluxo.

### Passo 4: Executar a Ingestão Inicial (RAG)
Abra o fluxo `01_ingest_resources.json` e clique em **Listen for test event** ou execute-o manualmente. Esse fluxo irá ler os arquivos Markdown de conhecimento, os 3.360 robôs XML da pasta `Bots_XML`, gerar seus respectivos vetores de embedding e salvá-los na tabela `knowledge_base` do PostgreSQL.

---

## 🧠 Como o Agente Aprende (Episodic Learning Loop)

O fluxo `03_learning_loop.json` expõe uma URL de Webhook no n8n.
Toda vez que uma operação de trading é concluída por um robô (ou em simulações de backtesting), o status (sucesso, falha, payout, sequência de perdas) pode ser enviado para esta URL.

O Agente analisa os dados operacionais:
1. Registra os parâmetros de entrada e resultado em `learning_logs`.
2. Em caso de anomalias (ex: sequência longa de reds no Martingale), o agente aciona o LLM para deduzir o que causou o problema com base na volatilidade do mercado.
3. O insight gerado é salvo na memória histórica, permitindo ao agente sugerir ajustes dinâmicos de stakes ou filtros de volatilidade no futuro.
