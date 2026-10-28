"""Client for the InvertirOnline (IOL) API: live quotes and daily history for BYMA instruments.

Log in with your IOL username and password, set as IOL_USERNAME and IOL_PASSWORD. The API must be
enabled for your account (ask IOL). Endpoints follow the iol-api and node-iol-v2 client libraries.
"""
from __future__ import annotations

import os
import time
from datetime import date
from typing import Any

import pandas as pd
import requests

TOKEN_URL = "https://api.invertironline.com/token"
API_URL = "https://api.invertironline.com/api/v2/"
MARKET = "bCBA"  # BYMA


class IOLClient:
    def __init__(self, username: str | None = None, password: str | None = None):
        self.username = username or os.environ.get("IOL_USERNAME")
        self.password = password or os.environ.get("IOL_PASSWORD")
        if not (self.username and self.password):
            raise RuntimeError("Set IOL_USERNAME and IOL_PASSWORD to use the IOL API.")
        self.session = requests.Session()
        self._token: dict[str, Any] | None = None
        self._expires = 0.0

    def _auth(self) -> None:
        if self._token and self._expires - time.time() > 60:
            return
        if self._token and self._token.get("refresh_token"):
            data = {"grant_type": "refresh_token", "refresh_token": self._token["refresh_token"]}
        else:
            data = {"grant_type": "password", "username": self.username, "password": self.password}
        r = requests.post(TOKEN_URL, data=data, timeout=15)
        if r.status_code in (400, 401) and data["grant_type"] == "refresh_token":
            self._token = None
            return self._auth()
        if r.status_code in (400, 401):
            raise PermissionError("IOL rejected the login. Check IOL_USERNAME, IOL_PASSWORD, and that API access is enabled for your account.")
        r.raise_for_status()
        self._token = r.json()
        self._expires = time.time() + float(self._token.get("expires_in", 900))
        self.session.headers["Authorization"] = f"Bearer {self._token['access_token']}"

    def _get(self, path: str) -> Any:
        self._auth()
        r = self.session.get(API_URL + path, timeout=15)
        if r.status_code == 404:
            return None
        r.raise_for_status()
        return r.json()

    def quote(self, symbol: str, market: str = MARKET) -> dict[str, Any] | None:
        """Last trade of one instrument, e.g. quote("SPY") in pesos or quote("SPYC") in cable dollars."""
        q = self._get(f"{market}/Titulos/{symbol}/Cotizacion")
        price = _num(q.get("ultimoPrecio")) if isinstance(q, dict) else None
        return {"symbol": symbol, "price": price, "time": q.get("fechaHora"), "raw": q} if price else None

    def history(self, symbol: str, start: str | date = "2020-01-01", end: str | date | None = None,
                adjusted: bool = False, market: str = MARKET) -> pd.DataFrame:
        """Daily OHLCV in FinRL's long format: date, tic, open, high, low, close, volume."""
        end = end or date.today()
        rows = self._get(f"{market}/Titulos/{symbol}/Cotizacion/seriehistorica/{start}/{end}/"
                         f"{'ajustada' if adjusted else 'sinAjustar'}") or []
        df = pd.DataFrame([{
            "date": str(r.get("fechaHora", ""))[:10],
            "tic": symbol,
            "open": _num(r.get("apertura")),
            "high": _num(r.get("maximo")),
            "low": _num(r.get("minimo")),
            "close": _num(r.get("ultimoPrecio") or r.get("cierre")),
            "volume": r.get("volumenNominal") or r.get("volumen") or 0,
        } for r in rows])
        if df.empty:
            return df
        df = df.dropna(subset=["close"])
        for col in ("open", "high", "low"):
            df[col] = df[col].fillna(df.close)
        # IOL can list several entries per day; keep the last one.
        return df.sort_values("date").drop_duplicates("date", keep="last").reset_index(drop=True)


def _num(v: Any) -> float | None:
    try:
        f = float(v)
        return f if f > 0 else None
    except (TypeError, ValueError):
        return None
