"""Real-money trading for the dish through IOL, with guard rails.

Off unless the server starts with DISH_REAL_TRADING=1. Every order needs the arming code the
server prints in the terminal. Limits (environment variables, defaults in brackets):
  DISH_MAX_ARS            largest buy, in pesos [100000]
  DISH_MIN_INTERVAL       seconds between orders [60]
  DISH_MAX_ORDERS_PER_DAY [20]
  DISH_PLAZO              settlement: t0, t1 or t2 [t1]
The dish only sells units it bought itself (tracked in dish_positions.json), never other SPY you hold.
"""
from __future__ import annotations

import hmac
import json
import math
import os
import secrets
import time
from datetime import datetime
from pathlib import Path
from typing import Any
from zoneinfo import ZoneInfo

SYMBOL = "SPY"
TZ = ZoneInfo("America/Argentina/Buenos_Aires")
SLIPPAGE = 0.005  # limit price this far through the last trade, so the order can fill


def byma_open(now: datetime | None = None) -> bool:
    t = now or datetime.now(TZ)
    return t.weekday() < 5 and 11 <= t.hour < 17


class RealTrader:
    def __init__(self, iol, state_path: str | Path = "dish_positions.json"):
        self.iol = iol
        self.max_ars = float(os.environ.get("DISH_MAX_ARS", 100_000))
        self.min_interval = float(os.environ.get("DISH_MIN_INTERVAL", 60))
        self.max_orders = int(os.environ.get("DISH_MAX_ORDERS_PER_DAY", 20))
        self.plazo = os.environ.get("DISH_PLAZO", "t1")
        self.code = secrets.token_hex(3).upper()  # shown only in the terminal
        self.armed = False
        self.path = Path(state_path)
        self.state = {"owned": 0, "day": "", "count": 0, "last_ts": 0.0, "orders": []}
        if self.path.exists():
            self.state.update(json.loads(self.path.read_text()))

    def _save(self) -> None:
        self.state["orders"] = self.state["orders"][-200:]
        self.path.write_text(json.dumps(self.state, indent=2))

    def check_code(self, code: str | None) -> bool:
        return bool(code) and hmac.compare_digest(code.strip().upper(), self.code)

    def status(self) -> dict[str, Any]:
        return {"available": True, "armed": self.armed, "owned": self.state["owned"], "maxArs": self.max_ars,
                "minInterval": self.min_interval, "ordersToday": self._count_today(), "maxOrders": self.max_orders,
                "marketOpen": byma_open(), "orders": self.state["orders"][-20:]}

    def _count_today(self) -> int:
        return self.state["count"] if self.state["day"] == datetime.now(TZ).strftime("%Y-%m-%d") else 0

    def act(self, side: str, max_ars: float | None = None) -> dict[str, Any]:
        """Bring the dish's real position in line with its call: buy on UP, sell on DOWN."""
        if not self.armed:
            raise PermissionError("Real trading isn't armed.")
        if side not in ("buy", "sell"):
            raise ValueError("side must be buy or sell")
        if not byma_open():
            return {"skipped": "BYMA is closed"}
        now = time.time()
        if now - self.state["last_ts"] < self.min_interval:
            return {"skipped": f"less than {self.min_interval:.0f}s since the last order"}
        if self._count_today() >= self.max_orders:
            self.armed = False
            return {"skipped": f"daily limit of {self.max_orders} orders reached; real trading disarmed"}

        held = self.iol.portfolio_qty(SYMBOL)
        owned = min(self.state["owned"], held)  # a buy that never filled doesn't count
        q = self.iol.quote(SYMBOL)
        if not q or not q["price"]:
            raise RuntimeError("IOL returned no SPY price")
        last = q["price"]

        if side == "buy":
            if owned > 0:
                self.state["owned"] = owned
                return {"skipped": f"already holding {owned} SPY bought by the dish"}
            budget = min(self.max_ars, float(max_ars or self.max_ars))
            price = last * (1 + SLIPPAGE)
            qty = math.floor(budget / price)
            if qty < 1:
                return {"skipped": f"ARS {budget:,.0f} doesn't buy one SPY at {price:,.2f}"}
        else:
            if owned < 1:
                self.state["owned"] = 0
                return {"skipped": "the dish holds no SPY to sell"}
            price, qty = last * (1 - SLIPPAGE), owned

        res = self.iol.order(side, SYMBOL, qty, price, self.plazo)
        today = datetime.now(TZ).strftime("%Y-%m-%d")
        self.state.update(day=today, count=self._count_today() + 1, last_ts=now,
                          owned=owned + qty if side == "buy" else owned - qty)
        rec = {"time": datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S"), "side": side, "qty": qty,
               "price": round(price, 2), "operation": res.get("numeroOperacion") if isinstance(res, dict) else None}
        self.state["orders"].append(rec)
        self._save()
        return {"order": rec}
