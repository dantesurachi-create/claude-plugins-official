"""Train and test the dish in FinRL's StockTradingEnv on the SPY CEDEAR.

    python -m finrl_byma.run --source iol            # history from your IOL account
    python -m finrl_byma.run --data data            # history from TradingView exports
    python -m finrl_byma.run --data data --ppo      # also train FinRL's PPO baseline
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd
from finrl.meta.env_stock_trading.env_stocktrading import StockTradingEnv

from .dish_agent import DishAgent
from .processor import INDICATORS, BymaProcessor

TECH = INDICATORS + ["ccl_chg"]
COST = 0.006  # broker commission plus BYMA fees, per side (approximate)


def make_env(df: pd.DataFrame, initial: float) -> StockTradingEnv:
    return StockTradingEnv(
        df=BymaProcessor.to_env_df(df), stock_dim=1, hmax=int(initial / df.close.min()) + 1,
        initial_amount=initial, num_stock_shares=[0], buy_cost_pct=[COST], sell_cost_pct=[COST],
        reward_scaling=1e-4, state_space=1 + 2 + len(TECH), action_space=1, tech_indicator_list=TECH,
        print_verbosity=10**9)


def run_dish(df: pd.DataFrame, initial: float, seed: int | None, signal: str = "pnl") -> tuple[list[float], list[int]]:
    env, agent = make_env(df, initial), DishAgent(seed)
    env.reset()
    outcomes, done = [], False
    while not done:
        price, ccl = env.state[1], float(env.data.ccl)
        agent.observe(price, ccl)
        up = agent.act()
        before = env.asset_memory[-1]
        _, _, done, _, _ = env.step(np.array([1.0 if up else -1.0]))
        if done:
            break
        # The step's real result in the FinRL account, trading costs included.
        pnl = env.asset_memory[-1] / before - 1
        outcome, strength = agent.outcome_from(pnl, up, env.state[1] / price - 1, signal)
        agent.feedback(outcome, strength)
        outcomes.append(outcome)
    return list(env.asset_memory), outcomes


def win_rate(outcomes: list[int]) -> float | None:
    scored = [o for o in outcomes if o != 0]
    return round(sum(o > 0 for o in scored) / len(scored), 4) if scored else None


def run_ppo(train: pd.DataFrame, test: pd.DataFrame, initial: float, steps: int) -> list[float]:
    from stable_baselines3 import PPO
    model = PPO("MlpPolicy", make_env(train, initial).get_sb_env()[0], verbose=0, seed=0)
    model.learn(total_timesteps=steps)
    env = make_env(test, initial)
    obs, _ = env.reset()
    done = False
    while not done:
        action, _ = model.predict(np.array(obs), deterministic=True)
        obs, _, done, _, _ = env.step(action)
    return list(env.asset_memory)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", choices=["tradingview", "iol"], default="tradingview", help="where the history comes from")
    ap.add_argument("--data", default="data", help="folder with TradingView exports (SPY, optional SPYC)")
    ap.add_argument("--start"), ap.add_argument("--end")
    ap.add_argument("--initial", type=float, default=1_000_000)
    ap.add_argument("--split", type=float, default=0.7, help="share of days used to train PPO")
    ap.add_argument("--ppo", action="store_true", help="also train FinRL's PPO agent as a baseline")
    ap.add_argument("--ppo-steps", type=int, default=20_000)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--signal", choices=["pnl", "direction"], default="pnl",
                    help="pnl: noise on a losing step, calm beat on a winning one (default); direction: score the call")
    ap.add_argument("--out", default="results")
    a = ap.parse_args()

    df = BymaProcessor(a.data, a.source).load(start_date=a.start, end_date=a.end)
    dates = sorted(df.date.unique())
    cut = dates[int(len(dates) * a.split)]
    test = df[df.date >= cut]
    print(f"{len(dates)} trading days of SPY CEDEAR, {dates[0]} to {dates[-1]}; test period starts {cut}")

    # The dish learns online, so it trades the whole history; it is scored on the same test period as PPO.
    eq_all, hits = run_dish(df, a.initial, a.seed, a.signal)
    k = dates.index(cut)
    dish = [v * a.initial / eq_all[k] for v in eq_all[k:]]
    hold = list(a.initial * test.close.to_numpy() / test.close.iloc[0])
    curves = {"dish": dish, "buy_hold": hold}
    if a.ppo:
        curves["ppo"] = run_ppo(df[df.date < cut], test, a.initial, a.ppo_steps)

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)
    n = min(len(c) for c in curves.values())
    pd.DataFrame({"date": test.date.to_numpy()[:n], **{k: v[:n] for k, v in curves.items()}}).to_csv(out / "equity.csv", index=False)
    summary = {
        "days": len(dates), "test_start": cut, "test_end": dates[-1],
        "signal": a.signal,
        "dish_win_rate_all": win_rate(hits),
        "dish_win_rate_test": win_rate(hits[k:]),
        "dish_steps_in_pesos_without_signal": round(hits.count(0) / max(1, len(hits)), 4),
        **{f"{name}_return_test": round(c[n - 1] / c[0] - 1, 4) for name, c in curves.items()},
    }
    (out / "summary.json").write_text(json.dumps(summary, indent=2))
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
