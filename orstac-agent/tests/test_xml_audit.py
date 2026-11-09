from pathlib import Path

import pytest

from orstac_agent.xml_audit import audit_file, audit_xml

REPO = Path(__file__).resolve().parents[2]
CHAMPIONS = REPO / "champions"


def _bot(after_purchase: str, extra: str = "") -> str:
    """Minimal DBot XML with a trade block and a custom after_purchase stack."""
    return f"""<xml xmlns="http://www.w3.org/1999/xhtml">
  <variables><variable id="a">Initial Amount</variable><variable id="b">Stop Loss</variable></variables>
  <block type="trade" id="t">
    <field name="MARKET_LIST">synthetic_index</field>
    <field name="SYMBOL_LIST">R_100</field>
    <field name="TRADETYPECAT_LIST">callput</field>
    <field name="TRADETYPE_LIST">risefall</field>
    <statement name="SUBMARKET">
      <block type="tradeOptions" id="o">
        <field name="DURATIONTYPE_LIST">t</field>
        <value name="DURATION"><block type="math_number"><field name="NUM">5</field></block></value>
        <value name="AMOUNT"><block type="variables_get"><field name="VAR" id="a">Initial Amount</field></block></value>
      </block>
    </statement>
  </block>
  <block type="after_purchase" id="ap"><statement name="AFTERPURCHASE_STACK">{after_purchase}</statement></block>
  {extra}
</xml>"""


DOUBLE_ON_LOSS = """
<block type="variables_set"><field name="VAR" id="a">Initial Amount</field>
  <value name="VALUE"><block type="math_arithmetic"><field name="OP">MULTIPLY</field>
    <value name="A"><block type="variables_get"><field name="VAR" id="a">Initial Amount</field></block></value>
    <value name="B"><block type="math_number"><field name="NUM">2</field></block></value>
  </block></value>
</block>"""

ADD_LOSS_TIMES_1071 = """
<block type="math_change"><field name="VAR" id="a">Initial Amount</field>
  <value name="DELTA"><block type="math_arithmetic"><field name="OP">MULTIPLY</field>
    <value name="A"><block type="math_single"><field name="OP">ABS</field>
      <value name="NUM"><block type="read_details"><field name="DETAIL_INDEX">4</field></block></value></block></value>
    <value name="B"><block type="math_number"><field name="NUM">1.071</field></block></value>
  </block></value>
</block>"""

SESSION_STOP_LOSS = """
<block type="logic_compare"><field name="OP">LTE</field>
  <value name="A"><block type="total_profit"></block></value>
  <value name="B"><block type="math_single"><field name="OP">NEG</field>
    <value name="NUM"><block type="variables_get"><field name="VAR" id="b">Stop Loss</field></block></value></block></value>
</block>"""

LAST_CONTRACT_ONLY = """
<block type="logic_compare"><field name="OP">GTE</field>
  <value name="A"><block type="math_single"><field name="OP">ABS</field>
    <value name="NUM"><block type="read_details"><field name="DETAIL_INDEX">4</field></block></value></block></value>
  <value name="B"><block type="variables_get"><field name="VAR" id="c">Max Loss Amount</field></block></value>
</block>"""


def test_flat_stake_with_session_stop_is_grade_a():
    a = audit_xml(_bot(SESSION_STOP_LOSS + """
<block type="logic_compare"><field name="OP">GTE</field>
  <value name="A"><block type="total_profit"></block></value>
  <value name="B"><block type="math_number"><field name="NUM">10</field></block></value>
</block>"""))
    assert a.parsed
    assert (a.symbol, a.trade_type, a.duration, a.duration_unit) == ("R_100", "risefall", 5.0, "t")
    assert a.progression == "none"
    assert a.has_loss_limit and a.has_profit_target
    assert a.risk_grade == "A"


def test_doubling_without_stop_is_grade_d():
    a = audit_xml(_bot(DOUBLE_ON_LOSS))
    assert a.progression == "martingale" and a.progression_multiplier == 2.0
    assert not a.has_loss_limit
    assert a.risk_grade == "D"


def test_stake_plus_loss_times_factor_is_recognised_as_martingale():
    # stake += |last loss| x 1.071  ->  next stake ~ 2.071 x previous stake
    a = audit_xml(_bot(ADD_LOSS_TIMES_1071))
    assert a.progression == "martingale"
    assert a.progression_multiplier == pytest.approx(2.071)


def test_per_contract_cap_is_not_a_session_stop():
    a = audit_xml(_bot(LAST_CONTRACT_ONLY))
    assert not a.has_loss_limit


def test_rejects_non_bot_and_broken_xml():
    assert not audit_xml("<xml><block type='text'></block></xml>").parsed
    broken = audit_xml("<xml><block")
    assert not broken.parsed and "parse error" in broken.error


@pytest.mark.skipif(not CHAMPIONS.exists(), reason="repository champions not available")
def test_champions_are_audited_as_expected():
    rise_fall = audit_file(CHAMPIONS / "Rise-Fall - Consistent - Trends.xml")
    assert rise_fall.progression == "martingale"
    assert rise_fall.progression_multiplier == pytest.approx(2.071)
    assert not rise_fall.has_loss_limit
    assert rise_fall.risk_grade == "D"
    # step table "0.35,0.39,0.80,1.62,..." chosen by loss count: a capped martingale, with a session stop
    safe = audit_file(CHAMPIONS / "safe profit pro.xml")
    assert safe.progression == "martingale" and safe.has_loss_limit and safe.risk_grade == "C"
    # stake = stake + profit after a win: positive progression (Soros), with a session stop
    candle = audit_file(CHAMPIONS / "Candlestick v2.xml")
    assert candle.progression == "soros" and candle.has_loss_limit and candle.risk_grade == "B"


def test_stake_factor_list_is_a_progression():
    extra = """<block type="variables_set"><field name="VAR" id="l">stakeList</field>
  <value name="VALUE"><block type="lists_split"><field name="MODE">SPLIT</field>
    <value name="INPUT"><block type="text"><field name="TEXT">1,2,4,8,16</field></block></value>
  </block></value></block>"""
    a = audit_xml(_bot(SESSION_STOP_LOSS, extra))
    assert a.progression == "martingale" and a.progression_multiplier == pytest.approx(2.0)


def test_reinvesting_profit_is_soros():
    soros = """<block type="variables_set"><field name="VAR" id="a">Initial Amount</field>
  <value name="VALUE"><block type="math_arithmetic"><field name="OP">ADD</field>
    <value name="A"><block type="variables_get"><field name="VAR" id="a">Initial Amount</field></block></value>
    <value name="B"><block type="variables_get"><field name="VAR" id="p">Lucro</field></block></value>
  </block></value></block>"""
    a = audit_xml(_bot(soros + SESSION_STOP_LOSS))
    assert a.progression == "soros" and a.risk_grade == "B"
