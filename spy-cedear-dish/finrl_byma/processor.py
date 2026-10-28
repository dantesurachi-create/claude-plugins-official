"""FinRL data processor for BYMA CEDEARs, with the same methods as finrl.meta.data_processors.*.

download_data reads history from TradingView exports in a folder (one CSV per ticker: SPY, and SPYC for
the CCL) or from your IOL account.
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
from stockstats import StockDataFrame as Sdf

from .tradingview import load_tradingview_csv, ticker_from_filename

# A subset of finrl.config.INDICATORS, plus the CCL's daily change.
INDICATORS = ["macd", "rsi_30", "boll_ub", "boll_lb", "close_30_sma"]


class BymaProcessor:
    def __init__(self, data_dir: str | Path = "data", source: str = "tradingview"):
        self.data_dir = Path(data_dir)
        self.source = source
        self._iol = None

    def iol(self):
        if self._iol is None:
            from .iol_api import IOLClient
            self._iol = IOLClient()
        return self._iol

    def available(self, tic: str) -> bool:
        if self.source == "iol":
            return True
        return self.csv_for(tic) is not None

    def csv_for(self, tic: str) -> Path | None:
        return next((p for p in sorted(self.data_dir.glob("*.csv")) if ticker_from_filename(p) == tic.upper()), None)

    def download_data(self, ticker_list, start_date=None, end_date=None, time_interval="1D") -> pd.DataFrame:
        frames = []
        for tic in ticker_list:
            if self.source == "iol":
                df = self.iol().history(tic, start_date or "2020-01-01", end_date)
                if df.empty and tic == ticker_list[0]:
                    raise RuntimeError(f"IOL returned no history for {tic}")
                frames.append(df)
                continue
            path = self.csv_for(tic)
            if path is None:
                raise FileNotFoundError(f"No TradingView export for {tic} in {self.data_dir}/ (e.g. 'BCBA_{tic}, 1D.csv')")
            frames.append(load_tradingview_csv(path, tic))
        df = pd.concat(frames, ignore_index=True)
        if start_date:
            df = df[df.date >= str(start_date)]
        if end_date:
            df = df[df.date <= str(end_date)]
        return df.reset_index(drop=True)

    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.dropna(subset=["close"]).copy()
        df = df[df.close > 0]
        return df.sort_values(["date", "tic"]).reset_index(drop=True)

    def add_technical_indicator(self, df: pd.DataFrame, tech_indicator_list=INDICATORS) -> pd.DataFrame:
        # Same approach as finrl.meta.preprocessor.preprocessors.FeatureEngineer: stockstats per ticker.
        out = []
        for tic, g in df.groupby("tic"):
            g = g.sort_values("date").copy()
            stock = Sdf.retype(g.copy())
            for ind in tech_indicator_list:
                g[ind] = stock[ind].to_numpy()
            out.append(g)
        df = pd.concat(out).sort_values(["date", "tic"])
        return df.replace([np.inf, -np.inf], np.nan).bfill().ffill().fillna(0)

    def add_ccl(self, df: pd.DataFrame, ars: str = "SPY", usd: str = "SPYC") -> pd.DataFrame:
        """Keep the peso rows and add the implied CCL: the same CEDEAR in pesos ÷ in cable dollars."""
        a = df[df.tic == ars].copy()
        u = df[df.tic == usd][["date", "close"]].rename(columns={"close": "usd_close"})
        a = a.merge(u, on="date", how="left")
        a["ccl"] = (a.close / a.usd_close).ffill().bfill()
        a["ccl_chg"] = np.log(a.ccl).diff().fillna(0) if a.ccl.notna().any() else 0.0
        a["ccl"] = a.ccl.fillna(0)
        return a.drop(columns="usd_close").reset_index(drop=True)

    @staticmethod
    def to_env_df(df: pd.DataFrame) -> pd.DataFrame:
        """FinRL's StockTradingEnv indexes rows by trading-day number."""
        df = df.sort_values(["date", "tic"]).reset_index(drop=True)
        df.index = df.date.factorize()[0]
        return df

    def load(self, ars="SPY", usd="SPYC", start_date=None, end_date=None, tech_indicator_list=INDICATORS) -> pd.DataFrame:
        tickers = [ars] + ([usd] if self.available(usd) else [])
        df = self.clean_data(self.download_data(tickers, start_date, end_date))
        df = self.add_technical_indicator(df, tech_indicator_list)
        return self.add_ccl(df, ars, usd)
