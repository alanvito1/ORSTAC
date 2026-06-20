# Deriv API & DBot XML Knowledge Base for ORSTAC AI

This document serves as the core semantic knowledge base for the ORSTAC AI Agent, providing reference data on how the Deriv API operates and how DBot (Blockly XML) strategies are structured.

---

## 1. Deriv WebSocket API Reference

Deriv uses a high-performance WebSocket API for real-time market data streaming and trading.

### WebSocket Connection
- **Endpoint:** `wss://ws.derivws.com/websockets/v3?app_id={app_id}`
- Replace `{app_id}` with the registered application ID.
- Connection requires a secure WebSocket interface.

### Key Message Types & Operations

#### 1. Authorization
Before performing any trading action, authorize the connection:
```json
{
  "authorize": "YOUR_API_TOKEN_HERE"
}
```

#### 2. Market Data Subscription (Ticks)
Subscribe to real-time price updates for a symbol (e.g. `R_100` for Volatility 100 Index):
```json
{
  "ticks": "R_100",
  "subscribe": 1
}
```
*To stop receiving updates, send:*
```json
{
  "forget": "SUBSCRIPTION_ID_FROM_TICK_RESPONSE"
}
```

#### 3. Contract Proposals
Request a price proposal for a contract before buying (e.g. Rise/Fall, Digits, etc.):
```json
{
  "proposal": 1,
  "amount": 10,
  "basis": "stake",
  "currency": "USD",
  "duration": 5,
  "duration_unit": "t",
  "symbol": "R_100",
  "barrier": "+0.5",
  "contract_type": "CALL"
}
```

#### 4. Buying a Contract
Purchase a contract using the `proposal_id` received from the proposal response:
```json
{
  "buy": "PROPOSAL_ID",
  "price": 10.00
}
```

---

## 2. Deriv DBot XML Structure (Google Blockly)

Deriv DBot is a visual trading bot platform. The strategies are saved and loaded in an XML format serialized from Google Blockly.

### Core XML Framework
Every DBot strategy XML file must follow this structural hierarchy:

```xml
<xml xmlns="http://www.w3.org/1999/xhtml" is_dbot="true" collection="false">
  <!-- 1. Variables Definition -->
  <variables>
    <variable type="" id="unique_var_id">var_name</variable>
  </variables>
  
  <!-- 2. Logic Block Structure -->
  <block type="trade_definition" id="trade_def_root" x="100" y="100">
    <statement name="SUBMARKET">
      <block type="market" id="market_id">
        <!-- Market parameters: market type, submarket, symbol -->
      </block>
    </statement>
    <statement name="INITIALIZATION">
      <block type="variables_set" id="init_var_id">
        <!-- Initial Stake, Take Profit, Stop Loss -->
      </block>
    </statement>
    <statement name="SUBMISSION">
      <block type="trade_definition_buy" id="buy_id">
        <!-- Call or Put execution trigger -->
      </block>
    </statement>
  </block>
</xml>
```

### Critical Rules for XML Generation and Modification
1. **Case-Sensitivity:** In Google Blockly v10+ updates, variable names are strictly case-sensitive. If a variable is defined as `<variable id="...">stake</variable>`, using it elsewhere as `<field name="VAR">Stake</field>` will break the loading process and cause errors on the Deriv platform.
2. **Nesting Rules:** XML blocks are strictly hierarchical. Value blocks use `<value name="...">` and statement blocks use `<statement name="...">`. The order of blocks must match the Blockly canvas logic.
3. **Block Types (`type`):**
   - `trade_definition`: Root block defining market, symbol, contract type, and parameters.
   - `trade_definition_buy`: Executes the purchase based on indicators.
   - `before_purchase`: Strategy analysis block.
   - `after_purchase`: Handles outcome logic (e.g. Martingale multiplier on loss).
   - `logic_compare`, `logic_operation`, `math_number`, `math_arithmetic`: Control and math operations.
