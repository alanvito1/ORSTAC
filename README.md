# ORSTAC: Open-Source Deriv Trading Bots, Risk Audits and Community

ORSTAC (Open Source Robots and Technical Analyses Community) is a free, open-source collection of about 3,350 Deriv Bot (DBot) XML strategies, a short list of audited "champion" bots, and a read-only toolkit that audits bot risk. Website: [orstac.com](https://orstac.com) · Community: [Telegram](https://t.me/superbinarybots)

[![Open a free Deriv account](https://img.shields.io/badge/Open%20a%20free%20Deriv%20account-demo%20available-red?style=for-the-badge)](https://t.deriv.link?t=HBNVQ55CN68H) [![Run bots in your browser](https://img.shields.io/badge/ORSTAC%20Runner-run%20bots%20in%20your%20browser-6f42c1?style=for-the-badge)](https://bot.orstac.com)

## Quick start

1. [Open a free Deriv account](https://t.deriv.link?t=HBNVQ55CN68H). A demo account with virtual funds is available, and an account is needed to run the bots in Deriv Bot.
2. Download a bot from [`Bots_XML/`](Bots_XML/), the [curated champions](champions/README.md), or the [full index](docs/ROBOTS_INDEX.md).
3. Load the XML file in [Deriv Bot](https://t.deriv.link?t=HBNVQ55CN68H) and run it on a **demo account first**. Study its behavior before risking real money.

Prefer not to install anything? Run Lab-tested strategies, or your own bot, straight from the browser with **[ORSTAC Runner](https://bot.orstac.com)**.

## ORSTAC Runner: run bots in your browser

[ORSTAC Runner](https://bot.orstac.com) is a free web platform that runs bots on your own Deriv account, with safety limits that stay on.

- **Log in with Deriv.** You type your password on Deriv's own page. ORSTAC never sees it and never holds your funds. Your first contracts always run on a demo account.
- **Lab catalog.** 49 strategies that passed the ORSTAC Lab (no martingale, a session stop-loss, a low house edge), each with its Lab Score and the live house edge before you start.
- **My bots.** Build a bot, or import the XML you use in Deriv Bot, with any money management: flat stake, martingale, soft martingale, d'Alembert, Fibonacci or Soros. Each one is explained step by step, with a table of how the stake grows.
- **Instant Lab check.** 2,000 simulated sessions with your balance, the live payout and your settings: how often a session ends at the stop-loss, the expected cost per 100 contracts and the worst drawdown.
- **Export.** Download any bot as a Deriv Bot XML or as an ORSTAC file.

No strategy beats the house edge on synthetic indices; the Runner shows that cost instead of hiding it. Payouts on the platform include a 1% fee that supports ORSTAC.

[Open ORSTAC Runner](https://bot.orstac.com) · No Deriv account yet? [Create one free](https://t.deriv.link?t=HBNVQ55CN68H) (demo included).

> **Risk warning.** Trading involves risk and you can lose your entire stake. Synthetic indices and other derivatives are not suitable for everyone. Nothing here is financial advice or a promise of profit. Test every bot on a demo account first and never trade money you cannot afford to lose. Trading services are provided by Deriv, not by ORSTAC. ORSTAC may earn a commission if you sign up through its links, at no extra cost to you.

---

## What is in this repository

| Folder | Contents |
|---|---|
| [`Bots_XML/`](Bots_XML/) | Community Deriv Bot strategies in Blockly XML, grouped by first letter of the file name |
| [`champions/`](champions/) | Three curated bots with strategy guides and audited risk grades |
| [`docs/`](docs/) | [Robot index](docs/ROBOTS_INDEX.md), PDFs and spreadsheets for study |
| [`orstac-agent/`](orstac-agent/) | Open-source, read-only Python toolkit and MCP server: XML auditor, risk math, public Deriv API client. It never trades |

Why use it:
- **Transparent:** every strategy is readable Blockly logic that you can inspect before running it.
- **Risk-aware:** the [ORSTAC Agent](orstac-agent/) grades bots from A to D by stake progression (such as martingale) and by the presence of a session stop-loss.
- **Community:** contributions and discussion are welcome.

## How to use the bots

1. **Register** a [Deriv account](https://t.deriv.link?t=HBNVQ55CN68H) (demo is free).
2. **Explore** the [full index of robots](docs/ROBOTS_INDEX.md) and the [champions](champions/README.md).
3. **Download** the XML file from `Bots_XML/`.
4. **Load** it in Deriv Bot using the import option.
5. **Test** on a **demo account**. Check the stake after losses and whether the bot stops by itself.
6. **Adjust** parameters such as stake, stop loss and take profit, and measure results over a large sample.

## Audit a bot before you run it

The [ORSTAC Agent](orstac-agent/) reports a bot's market, contract type, how the stake changes after a loss, whether it has a session loss limit, and a risk grade (A to D). It also computes break-even win rate, position size and the probability of losing streaks. See [`orstac-agent/README.md`](orstac-agent/README.md) for installation and usage.

## Contributing

Contributions are welcome: fixes, documentation and new bots.

- [Contributing guidelines](CONTRIBUTING.md): how to document a bot (timeframe, market, variables, strategy, best configuration).
- [AI contributing guide](AI_CONTRIBUTING.md): guidance for using AI assistants on this repository.

## Principles

Choose with care. Study the logic, plan your risk management, apply with discipline, measure the results, and repeat. Studying is worth more than any single bot.

---

## Ready to try a bot?

[Open a free Deriv account](https://t.deriv.link?t=HBNVQ55CN68H) and test on the demo first, in Deriv Bot or directly in [ORSTAC Runner](https://bot.orstac.com). See also [orstac.com](https://orstac.com).

## Links

- [Full robot index](docs/ROBOTS_INDEX.md)
- [orstac.com](https://orstac.com)
- [Telegram community](https://t.me/superbinarybots)
- [ORSTAC Runner](https://bot.orstac.com): run bots in your browser
- [Open a Deriv account](https://t.deriv.link?t=HBNVQ55CN68H) (affiliate link)
- [License](LICENSE)

*Risk warning: trading involves risk. Never trade with money you cannot afford to lose. Always use a demo account first. Services are offered by Deriv.*
