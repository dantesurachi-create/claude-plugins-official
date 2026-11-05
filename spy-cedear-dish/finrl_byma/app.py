"""Start the SPY CEDEAR Dish as a desktop app: runs the server and opens it in its own window.

    python -m finrl_byma.app --source iol            # asks for your IOL user and password
    python -m finrl_byma.app --source iol --real     # also allows real-money trading

Takes the same options as finrl_byma.server. Close the window and the terminal (or Ctrl+C) to quit.
"""
from __future__ import annotations

import argparse
import getpass
import os
import shutil
import subprocess
import threading
import webbrowser

from .server import add_args, apply_args, build_server

BROWSERS = ["google-chrome", "chrome", "chromium", "chromium-browser", "microsoft-edge", "msedge",
            r"C:\Program Files\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
            r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"]


def open_window(url: str) -> None:
    # Chrome and Edge can open a page as a standalone app window, without tabs or an address bar.
    for b in BROWSERS:
        exe = shutil.which(b) or (b if os.path.isfile(b) else None)
        if exe:
            try:
                subprocess.Popen([exe, f"--app={url}", "--window-size=1280,900"],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                return
            except OSError:
                continue
    webbrowser.open(url)


def ask_iol_login() -> bool:
    """Ask for the IOL login in the terminal if it isn't set. Nothing is saved to disk."""
    if os.environ.get("IOL_USERNAME") and os.environ.get("IOL_PASSWORD"):
        return True
    print("Ingresá tu usuario de InvertirOnline (Enter sin escribir nada para seguir sin IOL).")
    user = input("  Usuario IOL: ").strip()
    if not user:
        return False
    os.environ["IOL_USERNAME"] = user
    os.environ["IOL_PASSWORD"] = getpass.getpass("  Contraseña IOL (no se ve al escribir): ")
    return True


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_args(ap)
    a = ap.parse_args()
    if (a.source == "iol" or a.live == "iol") and not ask_iol_login():
        print("Sin IOL: la app arranca con el mercado simulado o tus exportaciones de TradingView.")
        a.source, a.live = "tradingview", "off"
    apply_args(a)
    server = build_server(a.source, a.data, a.live, a.port, a.celular)
    threading.Timer(0.5, open_window, [f"http://localhost:{a.port}/"]).start()
    print("Para cerrar la app, cerrá esta ventana o apretá Ctrl+C.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Detenida.")


if __name__ == "__main__":
    main()
