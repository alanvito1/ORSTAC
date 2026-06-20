-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. Knowledge Base table (for RAG / Semantic Search)
-- Note: vector(768) is optimized for Google Gemini's text-embedding-004.
-- If you use OpenAI embeddings, change this to vector(1536).
CREATE TABLE IF NOT EXISTS knowledge_base (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100), -- e.g., 'deriv-api', 'xml-bot-logic', 'martingale-strategy', 'champions'
    source_path TEXT, -- Local path or URL
    embedding vector(768),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast vector similarity search (IVFFlat or HNSW)
CREATE INDEX IF NOT EXISTS knowledge_base_embedding_idx 
ON knowledge_base 
USING hnsw (embedding vector_cosine_ops);

-- 2. Chat History / Short-Term Memory
CREATE TABLE IF NOT EXISTS chat_conversations (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- 'user', 'assistant', 'system'
    message TEXT NOT NULL,
    tokens_used INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS chat_conversations_session_idx 
ON chat_conversations(session_id);

-- 3. Episodic Feedback & Learning logs (The Brain's learning loop)
CREATE TABLE IF NOT EXISTS learning_logs (
    id SERIAL PRIMARY KEY,
    log_type VARCHAR(100) NOT NULL, -- 'bot_execution', 'strategy_optimization', 'rag_refinement'
    input_state JSONB, -- The input parameters / market ticks
    action_taken JSONB, -- What the agent did / decided
    outcome JSONB, -- The result (e.g. payout, loss, error log)
    feedback_score NUMERIC(5,2) DEFAULT 0.00, -- Rating / Reward signal (e.g., -1.00 to 1.00)
    learned_insight TEXT, -- Deductions of what went right/wrong and how to adjust
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS learning_logs_type_idx 
ON learning_logs(log_type);
