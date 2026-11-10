from types import SimpleNamespace

import pytest

from orstac_agent import lab
from orstac_agent.xml_audit import audit_xml


def bot(**kw):
    base = dict(contract_side="CALL", trade_type="risefall", symbol="R_100", duration=5, duration_unit="t",
                prediction=None, progression="none", progression_multiplier=None,
                has_loss_limit=True, has_profit_target=True)
    base.update(kw)
    return SimpleNamespace(**base)


@pytest.mark.parametrize("ct,pred,p", [
    ("DIGITDIFF", None, 0.9), ("DIGITMATCH", 3, 0.1), ("DIGITEVEN", None, 0.5), ("DIGITODD", None, 0.5),
    ("DIGITOVER", 1, 0.8), ("DIGITOVER", 5, 0.4), ("DIGITUNDER", 8, 0.8), ("DIGITUNDER", 0, None),
    ("DIGITOVER", 9, None), ("DIGITOVER", None, None), ("CALL", None, 0.5), ("ONETOUCH", None, None),
])
def test_exact_win_probability(ct, pred, p):
    got = lab.exact_win_probability(ct, pred)
    assert got == pytest.approx(p) if p is not None else got is None


def test_contract_key_models_and_skips():
    key, notes, reason = lab.contract_key(bot())
    assert reason is None and key.id() == "R_100:CALL:5t"
    key, notes, _ = lab.contract_key(bot(contract_side="DIGITDIFF", trade_type="matchesdiffers", duration=None))
    assert key.id() == "R_100:DIGITDIFF:1t:5" and len(notes) == 2
    assert lab.contract_key(bot(trade_type="higherlower"))[0] is None
    assert lab.contract_key(bot(symbol="frxEURUSD"))[0] is None
    assert lab.contract_key(bot(contract_side="DIGITOVER", trade_type="overunder", prediction=None))[0] is None


def cfg(**kw):
    base = dict(win_prob=0.5, net_ratio=0.95, progression="none", multiplier=1.0, stop_loss=True, take_profit=True)
    base.update(kw)
    return lab.StrategyConfig(**base)


def test_flat_stake_with_stop_never_ruins():
    m = lab.simulate(cfg(), simulations=300)
    assert m.ruin_probability == 0
    assert m.house_edge_pct == pytest.approx(2.5)
    assert m.expected_loss_per_100_contracts_units > 0  # negative edge shows up as a loss


def test_martingale_without_stop_ruins_often_and_is_rejected():
    c = cfg(progression="martingale", multiplier=2.0, stop_loss=False, take_profit=False)
    m = lab.simulate(c, simulations=300)
    assert m.ruin_probability > 0.5
    ok, why = lab.admitted(m, c)
    assert not ok and len(why) == 3


def test_score_prefers_the_safe_strategy():
    safe, risky = cfg(), cfg(progression="martingale", multiplier=2.0, stop_loss=False)
    s1 = lab.orstac_score(lab.simulate(safe, simulations=200), safe)
    s2 = lab.orstac_score(lab.simulate(risky, simulations=200), risky)
    assert s1 > 80 > s2
    assert lab.admitted(lab.simulate(safe, simulations=200), safe)[0]


def test_soros_reinvests_wins():
    m = lab.simulate(cfg(progression="soros", win_prob=0.9, net_ratio=0.1), simulations=200)
    assert m.ruin_probability == 0


def test_prediction_extraction():
    xml = """<xml xmlns="https://developers.google.com/blockly/xml"><block type="trade_definition">
      <field name="TRADETYPE_LIST">overunder</field><field name="PURCHASE_LIST">DIGITOVER</field>
      <block type="tradeOptions"><value name="DURATION"><shadow type="math_number"><field name="NUM">1</field></shadow></value>
      <value name="PREDICTION"><shadow type="math_number"><field name="NUM">2</field></shadow></value></block>
    </block></xml>"""
    a = audit_xml(xml)
    assert a.prediction == 2 and a.prediction_dynamic is False
    dyn = xml.replace('<shadow type="math_number"><field name="NUM">2</field></shadow>',
                      '<block type="variables_get"><field name="VAR">d</field></block>')
    a = audit_xml(dyn)
    assert a.prediction is None and a.prediction_dynamic is True
