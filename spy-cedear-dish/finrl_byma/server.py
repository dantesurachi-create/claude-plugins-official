"""Serve the dish app with real data: history and live quotes from IOL or BYMA, and optional real trading.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.server --source iol
    BYMA_CLIENT_ID=... BYMA_CLIENT_SECRET=... python -m finrl_byma.server --data data
    open http://localhost:8000

Real-money trading also needs DISH_REAL_TRADING=1 and the arming code printed at startup (see trader.py).
Credentials stay on this server, which listens only on this computer; the page only sees prices.
"""
from __future__ import annotations

import argparse
import json
import os
import time
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from .processor import BymaProcessor

GAME_DIR = Path(__file__).resolve().parent.parent
STATIC = {"/": "index.html", "/index.html": "index.html", "/manifest.webmanifest": "manifest.webmanifest",
          "/sw.js": "sw.js", "/icon.svg": "icon.svg"}


def quote_fn(client, kind: str):
    if kind == "iol":
        def quote():
            spy = client.quote("SPY")
            usd = client.quote("SPYC") or client.quote("SPYD")
            return spy and spy["price"], usd and usd["price"]
        return "IOL", quote

    def quote():
        spy, usd = client.quote("SPY", "ARS"), client.quote("SPYC", "EXT")
        return spy and spy["price"], usd and usd["price"]
    return f"BYMA Market Data ({client.feed})", quote


class Handler(SimpleHTTPRequestHandler):
    processor: BymaProcessor
    port = 8000
    live = None  # (name, quote function) or None
    live_error: str | None = None
    trader = None  # RealTrader or None
    trader_error = "Real trading is off. Start the server with DISH_REAL_TRADING=1 and an IOL login to enable it."

    def _local(self) -> bool:
        # Refuse requests whose Host isn't this computer, so other websites can't reach the API (DNS rebinding).
        return self.headers.get("Host", "") in (f"localhost:{self.port}", f"127.0.0.1:{self.port}")

    def do_GET(self):
        if not self._local():
            return self.send_error(403)
        path = self.path.split("?")[0]
        routes = {"/api/history": self.history, "/api/quote": self.quote, "/api/config": self.config}
        if path in routes:
            return self._json(routes[path])
        if path not in STATIC:  # serve only the app's own files, never the data or source folders
            return self.send_error(404)
        self.path = "/" + STATIC[path]
        return super().do_GET()

    def do_POST(self):
        if not self._local() or self.headers.get("Content-Type", "").split(";")[0] != "application/json":
            return self.send_error(403)
        body = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0) or 0)) or b"{}")
        routes = {"/api/arm": self.arm, "/api/disarm": self.disarm, "/api/order": self.order}
        fn = routes.get(self.path.split("?")[0])
        return self._json(lambda: fn(body)) if fn else self.send_error(404)

    def history(self):
        df = self.processor.load()
        return {"source": "IOL" if self.processor.source == "iol" else "TradingView export", "bars": [
            {"label": r.date, "px": float(r.close), "ccl": float(r.ccl) or None} for r in df.itertuples()]}

    def quote(self):
        if self.live is None:
            raise RuntimeError(self.live_error or "no live quote source is configured")
        name, quote = self.live
        px, usd = quote()
        if not px:
            raise RuntimeError(f"{name} returned no SPY price")
        return {"source": name, "px": px, "ccl": px / usd if usd else None, "ts": int(time.time())}

    def config(self):
        return {"live": self.live[0] if self.live else None, "liveError": self.live_error,
                "real": self.trader.status() if self.trader else {"available": False, "reason": self.trader_error}}

    def _trader(self, body, need_code=True):
        if not self.trader:
            raise PermissionError(self.trader_error)
        if need_code and not self.trader.check_code(body.get("code")):
            raise PermissionError("Wrong arming code. Use the code shown in the server's terminal.")
        return self.trader

    def arm(self, body):
        t = self._trader(body)
        t.armed = True
        print("Real trading ARMED")
        return t.status()

    def disarm(self, body):
        t = self._trader(body, need_code=False)  # stopping never needs the code
        t.armed = False
        print("Real trading disarmed")
        return t.status()

    def order(self, body):
        t = self._trader(body)
        result = t.act(body.get("side"), body.get("maxArs"))
        print("Real trading:", result)
        return {**result, "status": t.status()}

    def _json(self, fn):
        try:
            body, code = fn(), 200
        except PermissionError as e:
            body, code = {"error": str(e)}, 403
        except Exception as e:  # report the reason to the page instead of a bare 500
            body, code = {"error": str(e)}, 503
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def build_server(source="tradingview", data="data", live="auto", port=8000) -> ThreadingHTTPServer:
    Handler.processor = BymaProcessor(data, source)
    Handler.port = port
    if live == "auto":
        live = "iol" if os.environ.get("IOL_USERNAME") else "byma" if os.environ.get("BYMA_CLIENT_ID") else "off"
    iol = None
    if live == "off":
        Handler.live_error = "live quotes are off: set IOL_USERNAME and IOL_PASSWORD (or BYMA credentials) and restart the server"
    else:
        try:
            if live == "iol":
                from .iol_api import IOLClient
                iol = IOLClient()
                Handler.live = quote_fn(iol, "iol")
            else:
                from .byma_api import BymaMarketData
                Handler.live = quote_fn(BymaMarketData(), "byma")
            print(f"Live quotes from {Handler.live[0]}")
        except Exception as e:
            Handler.live_error = str(e)
    if Handler.live_error:
        print(Handler.live_error)

    if os.environ.get("DISH_REAL_TRADING") == "1":
        if iol is None:
            Handler.trader_error = "Real trading needs live quotes from IOL (set IOL_USERNAME and IOL_PASSWORD)."
            print(Handler.trader_error)
        else:
            from .trader import RealTrader
            Handler.trader = RealTrader(iol, GAME_DIR / "dish_positions.json")
            t = Handler.trader
            print(f"\n  REAL TRADING AVAILABLE. Arming code: {t.code}\n"
                  f"  Limits: ARS {t.max_ars:,.0f} per buy, {t.min_interval:.0f}s between orders, "
                  f"{t.max_orders} orders a day.\n")
    print(f"Serving the app on http://localhost:{port}")
    return ThreadingHTTPServer(("127.0.0.1", port), partial(Handler, directory=str(GAME_DIR)))


def add_args(ap: argparse.ArgumentParser) -> None:
    ap.add_argument("--source", choices=["tradingview", "iol"], default="tradingview", help="where the history comes from")
    ap.add_argument("--data", default="data", help="folder with TradingView exports (SPY, optional SPYC)")
    ap.add_argument("--live", choices=["auto", "iol", "byma", "off"], default="auto",
                    help="live quotes: auto uses IOL if IOL_USERNAME is set, else BYMA if BYMA_CLIENT_ID is set")
    ap.add_argument("--port", type=int, default=8000)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_args(ap)
    a = ap.parse_args()
    build_server(a.source, a.data, a.live, a.port).serve_forever()


if __name__ == "__main__":
    main()
