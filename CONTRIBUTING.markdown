# Contributing to ORSTAC

Thank you for your interest in contributing to the Open Source Robots and Technical Analyses Community (ORSTAC)! We welcome contributions from traders, developers, and enthusiasts to enhance our collection of trading bot scripts and foster collaboration. This guide outlines how you can contribute to the repository.

## How to Contribute

### 1. Submitting a New Bot Script
- **What to Submit**: XML scripts for Deriv DBot or Binary platforms, including trading strategies (ex.: moving averages, RSI-based).
- **Steps**:
  1. Fork the repository: [alanvito1/ORSTAC](https://github.com/alanvito1/ORSTAC).
  2. Create a branch: `git checkout -b feature/new-bot-script`.
  3. Add your XML script to the appropriate folder (ex.: `/scripts/strategies/`).
  4. Include a README or comment in the script explaining:
     - Strategy (ex.: "Uses 50-day SMA crossover").
     - Parameters (ex.: stop-loss, trade size).
     - Recommended markets (ex.: forex, crypto).
  5. Commit changes: `git commit -m "Add new SMA crossover bot script"`.
  6. Push to your fork: `git push origin feature/new-bot-script`.
  7. Submit a pull request (PR) with a clear description of your script.
- **Tips**:
  - Test your script in a Deriv demo account before submitting.
  - Ensure the script is well-documented for community use.

### 2. Improving Existing Scripts
- **What to Improve**: Bug fixes, performance optimizations, or new parameters for existing XML scripts.
- **Steps**:
  1. Fork and create a branch as above.
  2. Modify the script, documenting changes in the script or PR description.
  3. Submit a PR explaining the improvement (ex.: "Fixed stop-loss bug in RSI bot").
- **Tips**: Reference the original script and test changes in a demo account.

### 3. Reporting Bugs
- **How to Report**:
  - Open an issue on [GitHub Issues](https://github.com/alanvito1/ORSTAC/issues).
  - Describe the bug, including:
    - Script name (ex.: "SMA_Crossover.xml").
    - Steps to reproduce (ex.: "Set stop-loss to 2%, run on EUR/USD").
    - Expected vs. actual behavior.
    - Environment (ex.: Deriv DBot, demo account).
- **Tip**: Check existing issues to avoid duplicates.

### 4. Suggesting Ideas
- **How to Suggest**:
  - Start a discussion on [GitHub Discussions](https://github.com/alanvito1/ORSTAC/discussions) or [Telegram](https://t.me/superbinarybots).
  - Propose new strategies, features, or community initiatives (ex.: "Add Bollinger Bands bot").
- **Tip**: Be specific about the idea’s purpose and potential impact.

## Guidelines
- **Code Quality**:
  - Ensure scripts are functional and tested in a Deriv demo account.
  - Use clear, descriptive names for scripts (ex.: "RSI_Divergence.xml").
  - Document parameters and strategy in the script or README.
- **Commit Messages**:
  - Use clear messages (ex.: "Add MACD-based trading bot").
  - Reference issues if applicable (ex.: "Fix #123: Stop-loss bug").
- **Pull Requests**:
  - Include a detailed description of changes.
  - Link to relevant issues or discussions.
  - Ensure PRs are focused (one feature/bug per PR).
- **Community**:
  - Be respectful and collaborative, per our [Code of Conduct](CODE_OF_CONDUCT.md).
  - Engage in discussions to refine your contribution.

## Getting Started
1. Read the [README](README.md) to understand ORSTAC’s mission and setup.
2. Join our [Telegram group](https://t.me/superbinarybots) for community support.
3. Check [GitHub Discussions](https://github.com/alanvito1/ORSTAC/discussions) for ongoing ideas.
4. Review existing scripts in `/scripts/` to identify contribution opportunities.

## Contact
- **Maintainer**: Alan Victor ([GitHub](https://github.com/alanvito1))
- **Community**: [Telegram](https://t.me/superbinarybots) | [GitHub Discussions](https://github.com/alanvito1/ORSTAC/discussions)
- **Issues**: Report bugs or violations at [GitHub Issues](https://github.com/alanvito1/ORSTAC/issues)

We’re excited to have you in the ORSTAC community! Your contributions help traders worldwide automate and succeed.