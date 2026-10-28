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
    trader_error = "La plata real está apagada. Abrí la app con la opción --real y tu usuario de IOL para habilitarla."

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
            raise RuntimeError(self.live_error or "no hay fuente de precios en vivo configurada")
        name, quote = self.live
        px, usd = quote()
        if not px:
            raise RuntimeError(f"{name} no devolvió precio de SPY")
        return {"source": name, "px": px, "ccl": px / usd if usd else None, "ts": int(time.time())}

    def config(self):
        return {"live": self.live[0] if self.live else None, "liveError": self.live_error,
                "real": self.trader.status() if self.trader else {"available": False, "reason": self.trader_error}}

    def _trader(self, body, need_code=True):
        if not self.trader:
            raise PermissionError(self.trader_error)
        if need_code and not self.trader.check_code(body.get("code")):
            raise PermissionError("Código de activación incorrecto. Usá el código que muestra la terminal.")
        return self.trader

    def arm(self, body):
        t = self._trader(body)
        t.armed = True
        print("Plata real ACTIVADA")
        return t.status()

    def disarm(self, body):
        t = self._trader(body, need_code=False)  # stopping never needs the code
        t.armed = False
        print("Plata real desactivada")
        return t.status()

    def order(self, body):
        t = self._trader(body)
        result = t.act(body.get("side"), body.get("maxArs"))
        print("Plata real:", result)
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
        Handler.live_error = "precios en vivo apagados: abrí la app con tu usuario de IOL (o credenciales de BYMA)"
    else:
        try:
            if live == "iol":
                from .iol_api import IOLClient
                iol = IOLClient()
                Handler.live = quote_fn(iol, "iol")
            else:
                from .byma_api import BymaMarketData
                Handler.live = quote_fn(BymaMarketData(), "byma")
            print(f"Precios en vivo de {Handler.live[0]}")
        except Exception as e:
            Handler.live_error = str(e)
    if Handler.live_error:
        print(Handler.live_error)

    if os.environ.get("DISH_REAL_TRADING") == "1":
        if iol is None:
            Handler.trader_error = "Para operar con plata real hacen falta los precios en vivo de IOL (usuario y contraseña de IOL)."
            print(Handler.trader_error)
        else:
            from .trader import RealTrader
            Handler.trader = RealTrader(iol, GAME_DIR / "dish_positions.json")
            t = Handler.trader
            print(f"\n  PLATA REAL DISPONIBLE. Código de activación: {t.code}\n"
                  f"  Límites: ${t.max_ars:,.0f} por compra, {t.min_interval:.0f} s entre órdenes, "
                  f"{t.max_orders} órdenes por día.\n")
    print(f"App disponible en http://localhost:{port}")
    return ThreadingHTTPServer(("127.0.0.1", port), partial(Handler, directory=str(GAME_DIR)))


def add_args(ap: argparse.ArgumentParser) -> None:
    ap.add_argument("--source", choices=["tradingview", "iol"], default="tradingview", help="de dónde sale el historial")
    ap.add_argument("--data", default="data", help="carpeta con exportaciones de TradingView (SPY y opcionalmente SPYC)")
    ap.add_argument("--live", choices=["auto", "iol", "byma", "off"], default="auto",
                    help="precios en vivo: auto usa IOL si hay usuario de IOL, si no BYMA si hay credenciales de BYMA")
    ap.add_argument("--port", type=int, default=8000)
    ap.add_argument("--real", action="store_true", help="habilita operar con plata real (igual hay que activarla en la app)")
    ap.add_argument("--max-ars", type=float, help="máximo en pesos por compra con plata real (por defecto 100000)")


def apply_args(a: argparse.Namespace) -> None:
    """Turn the command-line options for real trading into the settings trader.py reads."""
    if a.real:
        os.environ["DISH_REAL_TRADING"] = "1"
    if a.max_ars:
        os.environ["DISH_MAX_ARS"] = str(a.max_ars)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_args(ap)
    a = ap.parse_args()
    apply_args(a)
    build_server(a.source, a.data, a.live, a.port).serve_forever()


if __name__ == "__main__":
    main()
