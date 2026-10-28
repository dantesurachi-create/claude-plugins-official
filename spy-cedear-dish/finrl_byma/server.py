"""Serve the browser game with real data: TradingView history and live BYMA quotes.

    BYMA_CLIENT_ID=... BYMA_CLIENT_SECRET=... python -m finrl_byma.server --data data
    open http://localhost:8000

The BYMA credentials stay on this server; the page only sees prices.
"""
from __future__ import annotations

import argparse
import json
import time
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from .processor import BymaProcessor

GAME_DIR = Path(__file__).resolve().parent.parent


class Handler(SimpleHTTPRequestHandler):
    processor: BymaProcessor
    byma = None
    byma_error: str | None = None

    def do_GET(self):
        if self.path.startswith("/api/history"):
            return self._json(self.history)
        if self.path.startswith("/api/quote"):
            return self._json(self.quote)
        return super().do_GET()

    def history(self):
        df = self.processor.load()
        return {"source": "TradingView export", "bars": [
            {"label": r.date, "px": float(r.close), "ccl": float(r.ccl) or None} for r in df.itertuples()]}

    def quote(self):
        if self.byma is None:
            raise RuntimeError(self.byma_error or "BYMA API not configured")
        spy = self.byma.quote("SPY", "ARS")
        spyc = self.byma.quote("SPYC", "EXT")
        if not spy or not spy["price"]:
            raise RuntimeError("SPY was not found in the BYMA CEDEAR feed")
        ccl = spy["price"] / spyc["price"] if spyc and spyc["price"] else None
        return {"source": f"BYMA Market Data ({self.byma.feed})", "px": spy["price"], "ccl": ccl, "ts": int(time.time())}

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
    ap.add_argument("--data", default="data", help="folder with TradingView exports (SPY, optional SPYC)")
    ap.add_argument("--port", type=int, default=8000)
    a = ap.parse_args()
    Handler.processor = BymaProcessor(a.data)
    try:
        from .byma_api import BymaMarketData
        Handler.byma = BymaMarketData()
    except Exception as e:
        Handler.byma_error = str(e)
        print(f"Live quotes off: {e}")
    print(f"Serving {GAME_DIR} on http://localhost:{a.port}")
    ThreadingHTTPServer(("127.0.0.1", a.port), partial(Handler, directory=str(GAME_DIR))).serve_forever()


if __name__ == "__main__":
    main()
