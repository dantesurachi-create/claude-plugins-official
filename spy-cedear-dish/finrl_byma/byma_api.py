"""Client for the BYMA Market Data API (api-mgr.byma.com.ar).

Access needs a client ID and secret from BYMA (marketdata@byma.com.ar). Set them as
BYMA_CLIENT_ID and BYMA_CLIENT_SECRET. Feeds: "snapshot" (real time), "delay20" and "eod".
Endpoints follow the community wrapper github.com/matiasgleser/bymadata-api-wrapper.
"""
from __future__ import annotations

import os
import re
import time
from typing import Any

import requests

AUTH_URL = "https://oauth-api-mgr.byma.com.ar/token"
API_BASE_URL = "https://api-mgr.byma.com.ar/"
FEEDS = ("snapshot", "delay20", "eod")
# The response schema isn't public; these are the names tried, in order, for each field.
SYMBOL_KEYS = ("symbol", "security_id", "securityId", "ticker", "simbolo")
PRICE_KEYS = ("trade", "last_price", "lastPrice", "last", "trade_price", "tradePrice", "close_price", "closingPrice", "price")


class BymaMarketData:
    def __init__(self, client_id: str | None = None, client_secret: str | None = None, feed: str | None = None):
        self.client_id = client_id or os.environ.get("BYMA_CLIENT_ID")
        self.client_secret = client_secret or os.environ.get("BYMA_CLIENT_SECRET")
        self.feed = feed or os.environ.get("BYMA_FEED", "snapshot")
        if not (self.client_id and self.client_secret):
            raise RuntimeError("Set BYMA_CLIENT_ID and BYMA_CLIENT_SECRET to use the BYMA Market Data API.")
        if self.feed not in FEEDS:
            raise ValueError(f"BYMA_FEED must be one of {FEEDS}")
        self.session = requests.Session()
        self._token: str | None = None
        self._expires = 0.0

    def _auth(self) -> None:
        if self._token and self._expires - time.time() > 60:
            return
        r = requests.post(AUTH_URL, timeout=15, data={
            "grant_type": "client_credentials", "client_id": self.client_id, "client_secret": self.client_secret})
        r.raise_for_status()
        body = r.json()
        self._token = body["access_token"]
        self._expires = time.time() + float(body.get("expires_in", 300))
        scopes = body.get("scope", "")
        if scopes and self.feed not in scopes:
            raise PermissionError(f"These BYMA credentials don't grant the '{self.feed}' feed (scopes: {scopes}).")

    def equity(self, group: str = "CEDEARS", currency: str = "ARS", settle_period: str = "0003") -> list[dict[str, Any]]:
        self._auth()
        r = self.session.get(f"{API_BASE_URL}{self.feed}/equity", timeout=15,
                             headers={"Authorization": f"Bearer {self._token}"},
                             params={"group": group, "settlPeriod": settle_period, "operativeForm": "CONTADO", "currency": currency})
        r.raise_for_status()
        body = r.json()
        return body.get("result", body) if isinstance(body, dict) else body

    def quote(self, symbol: str, currency: str = "ARS") -> dict[str, Any] | None:
        """Last price of one CEDEAR, e.g. quote("SPY") in pesos or quote("SPYC", "EXT") in cable dollars."""
        for row in self.equity(currency=currency):
            sym = next((str(row[k]) for k in SYMBOL_KEYS if k in row), "")
            if re.split(r"[\s\-_]", sym.upper())[0] != symbol.upper():
                continue
            price = next((float(row[k]) for k in PRICE_KEYS if isinstance(row.get(k), (int, float, str)) and _num(row[k])), None)
            return {"symbol": symbol, "price": price, "raw": row}
        return None


def _num(v: Any) -> bool:
    try:
        return float(v) > 0
    except (TypeError, ValueError):
        return False

