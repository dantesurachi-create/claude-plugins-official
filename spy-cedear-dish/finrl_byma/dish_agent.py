"""The DishBrain-style agent, ported from the browser game (index.html).

48 culture neurons get 12 sensory inputs (six market features as on/off pairs). Two motor
regions vote UP or DOWN. A miss brings unpredictable noise into the culture and weakens the
pathway that made the call; a hit brings a calm beat and strengthens it (Hebbian).
"""
from __future__ import annotations

import math

import numpy as np

NS, NH = 12, 48


class DishAgent:
    def __init__(self, seed: int | None = None):
        self.rng = np.random.default_rng(seed)
        r = self.rng
        self.w_in = np.where(r.random((NH, NS)) < 0.5, r.normal(0, 1.1, (NH, NS)), 0.0)
        self.w_rec = np.where(r.random((NH, NH)) < 0.1, r.normal(0, 0.35, (NH, NH)), 0.0)
        self.w_out = r.normal(0, 0.05, (2, NH))
        self.bias = r.normal(0, 0.2, NH)
        self.h = np.zeros(NH)
        self.temp, self.noise = 0.6, 0.0
        self.prices: list[float] = []
        self.ccls: list[float] = []
        self._last = None  # (h, up) waiting for its outcome

    def observe(self, price: float, ccl: float | None = None) -> None:
        self.prices.append(float(price))
        self.ccls.append(float(ccl) if ccl else 0.0)

    def features(self) -> np.ndarray:
        p = np.array(self.prices[-21:])
        n = len(p) - 1
        ret = lambda k: math.log(p[n] / p[max(0, n - k)])
        ma = p[-20:].mean()
        rets = np.diff(np.log(p))[-20:]
        sd = math.sqrt((rets ** 2).mean()) if len(rets) else 0.01
        c = self.ccls
        cc = math.log(c[-1] / c[-2]) if len(c) > 1 and c[-1] > 0 and c[-2] > 0 else 0.0
        f = np.tanh([ret(1) / 0.012, ret(5) / 0.03, ret(20) / 0.06, math.log(p[n] / ma) / 0.03, (sd - 0.012) / 0.006, cc / 0.008])
        return np.ravel(np.column_stack([np.maximum(0, f), np.maximum(0, -f)]))  # on/off electrode pairs

    def act(self) -> bool:
        """Call the next move: True = UP (hold CEDEARs), False = DOWN (stay in pesos)."""
        x = self.features()
        s = self.bias + self.w_in @ x + self.w_rec @ self.h + self.noise * 0.6 * self.rng.normal(size=NH)
        self.h = 0.3 * self.h + 0.7 * np.tanh(s)
        motor = self.w_out @ self.h
        up = bool(motor[0] - motor[1] + self.temp * 0.25 * self.rng.normal() > 0)
        self._last = (self.h.copy(), up)
        return up

    def feedback(self, hit: bool) -> None:
        h, up = self._last
        c, o, eta = (0, 1, 0.04) if up else (1, 0, 0.04)
        if hit:  # calm beat: consolidate the pathway that worked
            self.w_out[c] += eta * h
            self.w_out[o] -= eta * h
            self.temp = max(0.05, self.temp * 0.93)
            self.noise *= 0.4
        else:    # noise: weaken and jitter the pathway, raise exploration
            self.w_out[c] -= eta * h
            self.w_out[o] += eta * h
            self.w_out[c] += 0.01 * self.rng.normal(size=NH)
            self.temp = min(1.0, self.temp + 0.04)
            self.noise = min(1.0, self.noise + 0.55)
        norms = np.linalg.norm(self.w_out, axis=1, keepdims=True)
        self.w_out *= np.minimum(1.0, 3.0 / np.maximum(norms, 1e-9))
        self.noise = max(0.0, self.noise - 0.05)
