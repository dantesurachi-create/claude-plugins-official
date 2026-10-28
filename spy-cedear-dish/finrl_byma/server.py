"""Serve the dish app with real data: history and live quotes from IOL or BYMA, and optional real trading.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.server --source iol
    BYMA_CLIENT_ID=... BYMA_CLIENT_SECRET=... python -m finrl_byma.server --data data
    open http://localhost:8000

Real-money trading also needs DISH_REAL_TRADING=1 and the arming code printed at startup (see trader.py).
Credentials stay on this server; the page only sees prices. By default it listens only on this computer.
With --celular it also listens on the home network, and a phone must first pair by scanning a QR code.
"""
from __future__ import annotations

import argparse
import hmac
import io
import json
import os
import secrets
import socket
import time
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from .processor import BymaProcessor

GAME_DIR = Path(__file__).resolve().parent.parent
STATIC = {"/": "index.html", "/index.html": "index.html", "/manifest.webmanifest": "manifest.webmanifest",
          "/sw.js": "sw.js", "/icon.svg": "icon.svg"}
COOKIE = "placa_sesion"
UNPAIRED = """<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Placa SPY CEDEAR</title><body style="font:16px system-ui;margin:0;padding:24px;background:#0e1312;color:#e7eeec">
<h1 style="font-size:22px">Falta emparejar este teléfono</h1>
<p>En la computadora, abrí la app y escaneá con este teléfono el código QR de <b>Abrir en el celular</b>.</p></body></html>"""


def lan_ip() -> str | None:
    """This computer's address on the home network (no traffic is sent)."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("10.255.255.255", 1))
            ip = s.getsockname()[0]
        return None if ip.startswith("127.") else ip
    except OSError:
        return None


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
    phone_ip: str | None = None  # set with --celular
    pair_code = secrets.token_urlsafe(9)
    sessions: set[str] = set()

    def _local(self) -> bool:
        # This computer, with a Host that is this computer, so other websites can't reach the API (DNS rebinding).
        return (self.client_address[0] in ("127.0.0.1", "::1")
                and self.headers.get("Host", "") in (f"localhost:{self.port}", f"127.0.0.1:{self.port}"))

    def _phone(self) -> bool:
        """A paired device on the home network."""
        if not self.phone_ip or self.headers.get("Host", "") != f"{self.phone_ip}:{self.port}":
            return False
        token = next((c.split("=", 1)[1] for c in self.headers.get("Cookie", "").split("; ") if c.startswith(COOKIE + "=")), "")
        return any(hmac.compare_digest(token, t) for t in self.sessions)

    @classmethod
    def pair_url(cls) -> str | None:
        return f"http://{cls.phone_ip}:{cls.port}/emparejar?codigo={cls.pair_code}" if cls.phone_ip else None

    def _pair(self):
        """Scanning the QR code lands here: a valid code gives this device a session cookie."""
        q = dict(p.split("=", 1) for p in self.path.partition("?")[2].split("&") if "=" in p)
        if not (self.phone_ip and self.headers.get("Host", "") == f"{self.phone_ip}:{self.port}"
                and hmac.compare_digest(q.get("codigo", ""), self.pair_code)):
            return self._html(UNPAIRED, 403)
        token = secrets.token_urlsafe(24)
        self.sessions.add(token)
        print(f"Teléfono emparejado ({self.client_address[0]})")
        self.send_response(303)
        self.send_header("Location", "/")
        self.send_header("Set-Cookie", f"{COOKIE}={token}; HttpOnly; SameSite=Lax; Path=/; Max-Age=31536000")
        self.end_headers()

    def _html(self, html: str, code: int = 200):
        data = html.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _qr(self):
        import qrcode
        import qrcode.image.svg
        buf = io.BytesIO()
        qrcode.make(self.pair_url(), image_factory=qrcode.image.svg.SvgPathFillImage, border=2).save(buf)
        data = buf.getvalue()
        self.send_response(200)
        self.send_header("Content-Type", "image/svg+xml")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/emparejar":
            return self._pair()
        local = self._local()
        if not (local or self._phone()):
            return self._html(UNPAIRED, 403) if path in ("/", "/index.html") and self.phone_ip else self.send_error(403)
        if path == "/api/celular-qr.svg":  # only the computer may show the pairing code
            return self._qr() if local and self.phone_ip else self.send_error(404)
        routes = {"/api/history": self.history, "/api/quote": self.quote, "/api/config": lambda: self.config(local)}
        if path in routes:
            return self._json(routes[path])
        if path not in STATIC:  # serve only the app's own files, never the data or source folders
            return self.send_error(404)
        self.path = "/" + STATIC[path]
        return super().do_GET()

    def do_POST(self):
        if not (self._local() or self._phone()) or self.headers.get("Content-Type", "").split(";")[0] != "application/json":
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

    def config(self, local: bool):
        return {"live": self.live[0] if self.live else None, "liveError": self.live_error,
                "phone": {"enabled": bool(self.phone_ip), "url": self.pair_url() if local else None},
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
        t.owner = str(body.get("client") or "")  # only the screen that armed it may trade
        print("Plata real ACTIVADA")
        return t.status()

    def disarm(self, body):
        t = self._trader(body, need_code=False)  # stopping never needs the code
        t.armed = False
        print("Plata real desactivada")
        return t.status()

    def order(self, body):
        t = self._trader(body)
        if t.owner and body.get("client") != t.owner:
            raise PermissionError("Otra pantalla activó la plata real; solo esa puede operar.")
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


def build_server(source="tradingview", data="data", live="auto", port=8000, phone=False) -> ThreadingHTTPServer:
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
    host = "127.0.0.1"
    if phone:
        Handler.phone_ip = lan_ip()
        if Handler.phone_ip:
            host = "0.0.0.0"
            print_phone_qr(Handler.pair_url())
        else:
            print("No encontré la red Wi-Fi de esta computadora; el celular no va a poder conectarse.")
    return ThreadingHTTPServer((host, port), partial(Handler, directory=str(GAME_DIR)))


def print_phone_qr(url: str) -> None:
    print("\n  CELULAR: conectalo al mismo Wi-Fi y escaneá este código con la cámara.")
    try:
        import qrcode
        q = qrcode.QRCode(border=1)
        q.add_data(url)
        q.print_ascii(invert=True)
    except Exception:
        pass
    print(f"  O abrí en el celular: {url}\n  No compartas este código: da acceso a la app.\n")


def add_args(ap: argparse.ArgumentParser) -> None:
    ap.add_argument("--source", choices=["tradingview", "iol"], default="tradingview", help="de dónde sale el historial")
    ap.add_argument("--data", default="data", help="carpeta con exportaciones de TradingView (SPY y opcionalmente SPYC)")
    ap.add_argument("--live", choices=["auto", "iol", "byma", "off"], default="auto",
                    help="precios en vivo: auto usa IOL si hay usuario de IOL, si no BYMA si hay credenciales de BYMA")
    ap.add_argument("--port", type=int, default=8000)
    ap.add_argument("--real", action="store_true", help="habilita operar con plata real (igual hay que activarla en la app)")
    ap.add_argument("--max-ars", type=float, help="máximo en pesos por compra con plata real (por defecto 100000)")
    ap.add_argument("--celular", action="store_true", help="permite abrir la app desde un celular en el mismo Wi-Fi")


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
    build_server(a.source, a.data, a.live, a.port, a.celular).serve_forever()


if __name__ == "__main__":
    main()
