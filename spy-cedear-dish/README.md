# SPY CEDEAR Dish

A browser game where a simulated culture of 48 neurons learns to trade the SPY CEDEAR (BYMA, ratio 20:1, priced in ARS via the CCL rate). The idea comes from the DishBrain experiment:

- **Miss:** an unpredictable noise burst. The dish is flooded with random stimulation and the pathway that made the call is weakened and jittered.
- **Hit:** a calm, regular beat. The active pathway is strengthened (Hebbian) and exploration drops.

You can play against the dish by holding CEDEARs or staying in pesos. A chart tracks equity over time for the dish, you, and buy & hold, plus the dish's rolling 20-day hit rate.

## Market data

The game loads real Argentine market data when the browser can reach it:

- **[data912](https://data912.com)** – daily SPY CEDEAR closes (`/historical/cedears/SPY`) to train the dish, then the live CEDEAR panel (`/live/arg_cedears`) polled once a minute while BYMA is open (11:00–17:00, Buenos Aires time). The quotes are free and delayed.
- **[DolarAPI](https://dolarapi.com)** – the dólar CCL (`/v1/dolares/contadoconliqui`). If it's down, the CCL is implied from the same CEDEAR in two currencies: SPY (pesos) ÷ SPYC (cable dollars).

If those hosts can't be reached, for example inside a sandboxed preview, the game falls back to a simulated market and says why.

The market feed is shaped like the Gym-style trading environments in [TradingGym](https://github.com/Yvictor/TradingGym) and [FinRL](https://github.com/AI4Finance-Foundation/FinRL), which hand an agent one bar at a time. Here, each bar is adapted for Argentina: CEDEAR price in pesos, CCL, and implied SPY in dollars.

Open `index.html` in a normal browser. This is a learning toy, not investment advice.
