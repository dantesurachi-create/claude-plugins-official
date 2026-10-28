# SPY CEDEAR Dish

A simulated culture of 48 neurons learns to trade the SPY CEDEAR (BYMA, ratio 20:1). The idea comes from the DishBrain experiment:

- **Miss:** an unpredictable noise burst. The dish is flooded with random stimulation, and the pathway that made the call is weakened and jittered.
- **Hit:** a calm, regular beat. The active pathway is strengthened (Hebbian) and exploration drops.

There are two ways to run it:

| | Browser game (`index.html`) | FinRL (`finrl_byma/`) |
|---|---|---|
| What it does | Animated dish, sound, you vs the dish, equity chart | Backtest in FinRL's `StockTradingEnv` with trading costs, against buy & hold and FinRL's PPO agent |
| History | TradingView CSV export | TradingView CSV export |
| Live quotes | BYMA Market Data API, through `finrl_byma.server` | — |

This is a learning toy, not investment advice.

## 1. Get the history from TradingView

TradingView has no public data API, and scraping it breaks its terms of use. Use the chart's own export instead. Exporting needs a TradingView plan that includes it.

1. Open [BCBA:SPY](https://www.tradingview.com/symbols/BCBA-SPY/) on a daily (1D) chart and scroll back as far as you want to train.
2. Choose **Export chart data…** and save the CSV.
3. Do the same for **BCBA:SPYC** (the SPY CEDEAR in cable dollars). It's optional. With it, the CCL is implied as SPY ÷ SPYC.
4. Put both files in `spy-cedear-dish/data/`. Keep TradingView's file names (`BCBA_SPY, 1D_….csv`), which say which ticker each file holds.

In the browser game you can also click **Load TradingView CSV** and pick the files directly.

## 2. Live quotes from the BYMA Market Data API

BYMA's Market Data API needs a client ID and secret. Request them from BYMA at marketdata@byma.com.ar ([BYMA APIs](https://www.byma.com.ar/en/byma-apis)). The feeds are `snapshot` (real time), `delay20` (20-minute delay) and `eod` (end of day), and your credentials must include the one you use.

```bash
cd spy-cedear-dish
pip install -r requirements.txt
export BYMA_CLIENT_ID=...        # from BYMA
export BYMA_CLIENT_SECRET=...
export BYMA_FEED=snapshot        # or delay20 / eod
python -m finrl_byma.server --data data
# open http://localhost:8000
```

The game replays the TradingView history first. Then, while BYMA is open (11:00–17:00 Buenos Aires time), it asks the server for a live SPY quote every 30 seconds and trades each new price. The credentials stay on the server; the page only receives prices. Without credentials the server still serves the history, and the page says live quotes are off.

The API calls follow the community wrapper [bymadata-api-wrapper](https://github.com/matiasgleser/bymadata-api-wrapper). BYMA's documentation isn't public, so the field names for symbol and last price in `byma_api.py` are best guesses. Check them against a real response the first time.

## 3. Backtest with FinRL

```bash
python -m finrl_byma.run --data data          # dish vs buy & hold
python -m finrl_byma.run --data data --ppo    # also train FinRL's PPO agent
```

- `processor.py` — `BymaProcessor`, a FinRL data processor (`download_data`, `clean_data`, `add_technical_indicator`) that reads the TradingView exports and adds the implied CCL.
- `dish_agent.py` — the dish, ported from the browser game.
- `run.py` — runs the dish in FinRL's `StockTradingEnv` with 0.6% costs per side. PPO trains on the first 70% of days. All strategies are scored on the remaining 30%. Writes `results/summary.json` and `results/equity.csv`.

The dish flips position often, so trading costs matter here. The browser game ignores them.
