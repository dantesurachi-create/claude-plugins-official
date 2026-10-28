"""Serve the browser game with real data: history and live quotes from IOL or BYMA.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.server --source iol
    BYMA_CLIENT_ID=... BYMA_CLIENT_SECRET=... python -m finrl_byma.server --data data
    open http://localhost:8000

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


def iol_live():
    from .iol_api import IOLClient
    c = IOLClient()

    def quote():
        spy = c.quote("SPY")
        usd = c.quote("SPYC") or c.quote("SPYD")
        return spy and spy["price"], usd and usd["price"]
    return "IOL", quote


def byma_live():
    from .byma_api import BymaMarketData
    c = BymaMarketData()

    def quote():
        spy, usd = c.quote("SPY", "ARS"), c.quote("SPYC", "EXT")
        return spy and spy["price"], usd and usd["price"]
    return f"BYMA Market Data ({c.feed})", quote


class Handler(SimpleHTTPRequestHandler):
    processor: BymaProcessor
    live = None  # (name, quote function) or None
    live_error: str | None = None

    def do_GET(self):
        if self.path.startswith("/api/history"):
            return self._json(self.history)
        if self.path.startswith("/api/quote"):
            return self._json(self.quote)
        return super().do_GET()

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

    def _json(self, fn):
        try:
            body, code = fn(), 200
        except Exception as e:  # report the reason to the page instead of a bare 500
            body, code = {"error": str(e)}, 503
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", choices=["tradingview", "iol"], default="tradingview", help="where the history comes from")
    ap.add_argument("--data", default="data", help="folder with TradingView exports (SPY, optional SPYC)")
    ap.add_argument("--live", choices=["auto", "iol", "byma", "off"], default="auto",
                    help="live quotes: auto uses IOL if IOL_USERNAME is set, else BYMA if BYMA_CLIENT_ID is set")
    ap.add_argument("--port", type=int, default=8000)
    a = ap.parse_args()
    Handler.processor = BymaProcessor(a.data, a.source)
    live = a.live
    if live == "auto":
        live = "iol" if os.environ.get("IOL_USERNAME") else "byma" if os.environ.get("BYMA_CLIENT_ID") else "off"
    if live == "off":
        Handler.live_error = "live quotes are off: set IOL_USERNAME and IOL_PASSWORD (or BYMA credentials) and restart the server"
    else:
        try:
            Handler.live = (iol_live if live == "iol" else byma_live)()
            print(f"Live quotes from {Handler.live[0]}")
        except Exception as e:
            Handler.live_error = str(e)
    if Handler.live_error:
        print(Handler.live_error)
    print(f"Serving {GAME_DIR} on http://localhost:{a.port}")
    ThreadingHTTPServer(("127.0.0.1", a.port), partial(Handler, directory=str(GAME_DIR))).serve_forever()


if __name__ == "__main__":
    main()
