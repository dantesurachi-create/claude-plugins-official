"""Load TradingView chart exports (Export chart data… → CSV) into FinRL's long format.

TradingView has no public data API, so the supported route is the chart's own CSV export.
On TradingView the SPY CEDEAR is BCBA:SPY (pesos) and BCBA:SPYC (cable dollars).
"""
from __future__ import annotations

import re
from pathlib import Path

import pandas as pd

COLUMNS = ["date", "tic", "open", "high", "low", "close", "volume"]


def ticker_from_filename(path: str | Path) -> str | None:
    """'BCBA_SPYC, 1D_8f2a1.csv' -> 'SPYC'; 'SPY.csv' -> 'SPY'."""
    m = re.match(r"^(?:[A-Z]+_)?([A-Z0-9.]+)", Path(path).name.upper())
    return m.group(1) if m else None


def load_tradingview_csv(path: str | Path, tic: str | None = None) -> pd.DataFrame:
    raw = pd.read_csv(path)
    raw.columns = [c.strip().lower() for c in raw.columns]
    if "time" not in raw.columns or "close" not in raw.columns:
        raise ValueError(f"{path}: expected TradingView columns time, open, high, low, close")
    t = raw["time"]
    # TradingView exports time either as UNIX seconds or as ISO 8601, depending on the export setting.
    if pd.api.types.is_numeric_dtype(t):
        stamps = pd.to_datetime(t, unit="ms" if t.max() > 1e11 else "s", utc=True)
    else:
        stamps = pd.to_datetime(t, utc=True)
    df = pd.DataFrame({
        "date": stamps.dt.tz_convert("America/Argentina/Buenos_Aires").dt.strftime("%Y-%m-%d"),
        "tic": tic or ticker_from_filename(path) or "SPY",
        "open": raw.get("open", raw["close"]),
        "high": raw.get("high", raw["close"]),
        "low": raw.get("low", raw["close"]),
        "close": raw["close"],
        "volume": raw.get("volume", 0),
    })
    df = df.dropna(subset=["close"]).drop_duplicates("date", keep="last")
    return df[COLUMNS].sort_values("date").reset_index(drop=True)
