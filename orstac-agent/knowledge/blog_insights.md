# ORSTAC Blog Quantitative Insights & Trading Rules

This document consolidates key quantitative strategies, mathematical frameworks, risk parameters, and AI prompting models extracted from the ORSTAC blog articles. This data serves as a core knowledge base for the ORSTAC AI Agent's RAG system.

---

## 1. Dynamic Profit & Risk Management

### Ornstein-Uhlenbeck (OU) Trailing Stop-Loss
- **Concept:** Uses mean-reverting stochastic models to set adaptive trailing stop levels instead of fixed percentages.
- **Equation:** $dX_t = \theta(\mu - X_t)dt + \sigma dW_t$
  - $\theta$: Mean-reversion speed.
  - $\mu$: Long-term mean.
  - $\sigma$: Volatility.
  - $dW_t$: Wiener process.
- **Rule:** Estimate parameters on a rolling 60-minute window. If the price deviates $> 2\sigma$ from the long-term mean $\mu$, tighten the trailing stop (e.g., from 1.5% down to 0.5%) to guarantee profit-lock before a flash crash or regime reversal.

### Fractal Profit Targets (MMAR)
- **Concept:** Leverages Benoit Mandelbrot's Multifractal Model of Asset Returns to capture gains proportionate to fractal scaling laws.
- **Rule:** Calculate the Hurst Exponent ($H$) over a rolling 100-tick window:
  - **Trending ($H > 0.5$):** Set target aggressively at $2.5 \times ATR$.
  - **Noise/Mean-Reverting ($H \le 0.5$):** Set target conservatively at $1.2 \times ATR$ to lock profits quickly before a reversal.

---

## 2. Advanced Position Sizing & Capital Allocation

### Dynamic Kelly & Volatility Scaling
- **Concept:** The traditional Kelly Criterion is adjusted for non-stationary markets using rolling win rates and GARCH(1,1) volatility scaling.
- **Rule:** Scale down the position sizing using:
  - **Streak Penalty:** $P_{loss}(k) = (1-p)^k$ (probability of $k$ consecutive losses given win rate $p$). Shrink Kelly size proportionally as consecutive losses grow.
  - **Volatility Scaler:** $1 / (1 + \sigma_{garch})$, reducing exposure right before predicted volatility spikes.

### Martingale Warning
- **Concept:** Double-down Martingale systems lead to eventual ruin in real-world finite-capital environments.
- **Rule:** Strict loss limits are mandatory. Martingale-like increments should only be used inside a highly constrained, short-term risk budget on assets with statistically verified positive expectancy.

---

## 3. Market Regime Differentiation

- **Secular vs. Cyclical:** Do not apply mean-reversion to assets in structural decline (legacy assets). In structural decay, the "mean" itself degrades and shifts downward continuously.
- **Strategy Matching:**
  - **Innovative/Growth Sectors:** Use momentum strategies, tracking venture capital flows, patent filings, and positive sentiment loops.
  - **Decaying Legacy Sectors:** Use trend-following with a negative bias or short-selling rules.

---

## 4. AI-Driven Sentiment & Execution

### Sentiment Analysis Prompting
- **Concept:** Use prompt-engineered LLM agents to convert unstructured feeds (news, social media, earnings transcripts) into numeric sentiment scores from -1.00 (extremely bearish) to +1.00 (extremely bullish).
- **Automation Pipeline:** Integrate news RSS APIs with n8n/Node-RED to call LLMs every 5 seconds. Parse the returned JSON object containing entities, sentiment, and confidence indicators, then route signals directly to CCXT or Deriv APIs.
