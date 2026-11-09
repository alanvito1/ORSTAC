# ORSTAC Champions

A curated selection of community bots for Deriv Bot (DBot). Each one is described with its logic and its audited risk profile.

> **Audit update (November 2026).** All champions were re-checked with the open-source [ORSTAC Agent](../orstac-agent/) static auditor and by reading their blocks by hand. Earlier descriptions called one bot a "conservative bankroll manager" and described another as fixed-stake. **Both descriptions were wrong:** all three champions change the stake after a result. The descriptions below are corrected. None of the three reaches grade A (no progression plus a session stop). The selection will be reviewed.

| Bot | Contract | Stake after a result | Session stop-loss | Profit target | Risk grade |
|---|---|---|---|---|---|
| `Candlestick v2.xml` | Rise/Fall, R_10 | adds the last profit after a win (Soros), back to base otherwise | yes | yes | **B** |
| `safe profit pro.xml` | Rise/Fall, R_100 | step table after losses, about 2.2x per step for up to 8 steps (capped martingale) | yes | yes | **C** |
| `Rise-Fall - Consistent - Trends.xml` | Rise/Fall, R_50 | about 2.07x after each loss, uncapped (martingale) | **no** | yes | **D: high risk** |

Grades:
- **A:** no stake progression and a session loss limit.
- **B:** soft or positive (Soros) progression.
- **C:** martingale, or no loss limit.
- **D:** martingale and no loss limit.

Reproduce the audit with `orstac-agent audit "champions/<file>.xml"`.

## 1. Price action: `Candlestick v2.xml`
- **Logic:** reads OHLC candles to detect patterns (hammer, shooting star, engulfing), with EMA and RSI filters.
- **Risk profile:** after a win, the bot adds that win's profit to the next stake (positive progression, Soros). In other cases the stake goes back to the base value. The bot has a session stop-loss and a profit target, both set as a percentage.
- **Watch:** a run of wins compounds the stake, so a single loss after the run gives back that run's gains. Validate the patterns on demo with a large sample.

## 2. Indicator confluence: `safe profit pro.xml`
- **Logic:** enters when the EMA, RSI and MACD agree on direction.
- **Risk profile:** at start you choose one of four stake-factor tables, for example `0.35, 0.72, 1.5, 3.1, 6.43, 13.3, 27.54, 57`. Each consecutive loss moves one step up the table, and a win resets it. This is a **capped martingale**: the last step is up to about 160 times the first. The bot also has a session stop-loss and a profit target.
- **Watch:** check that the session stop-loss is smaller than the total of the table you choose. Otherwise one losing streak can exceed your limit before the stop triggers.

## 3. High risk: `Rise-Fall - Consistent - Trends.xml`
- **What it actually does:** after each loss it runs `stake += |last loss| × 1.071`. The next stake is therefore about **2.07 times** the previous one, which is an uncapped martingale. A loss larger than "Max Loss Amount" only resets the stake. The bot stops only when it reaches the expected profit, and it has **no session stop-loss**.
- **What that means:** with a 1,000 balance and a base stake of 1, nine consecutive losses commit about 65% of the balance. In 500 contracts at a 95.4% payout and a 50% win rate, the simulated ruin probability is about 39%. You can reproduce this with `orstac-agent ruin --balance 1000 --stake 1 --multiplier 2.071 --payout 0.954 --contracts 500`.
- **If you study or run it:** add a session stop-loss, cap the progression steps, and test it on a demo account only.

---
**Safety note:** no bot here is safe by default. Test on a **demo** account first, read the logic before running anything, and never risk money you cannot afford to lose.
