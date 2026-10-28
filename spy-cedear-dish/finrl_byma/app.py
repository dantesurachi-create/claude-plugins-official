"""Start the SPY CEDEAR Dish as a desktop app: runs the server and opens it in its own window.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.app --source iol

Takes the same options as finrl_byma.server. Close the terminal (or Ctrl+C) to quit.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import threading
import webbrowser

from .server import add_args, build_server

BROWSERS = ["google-chrome", "chrome", "chromium", "chromium-browser", "microsoft-edge", "msedge",
            r"C:\Program Files\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"]


def open_window(url: str) -> None:
    # Chrome and Edge can open a page as a standalone app window, without tabs or an address bar.
    for b in BROWSERS:
        exe = shutil.which(b) or (b if "/" in b or "\\" in b else None)
        if exe:
            try:
                subprocess.Popen([exe, f"--app={url}", "--window-size=1280,900"],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                return
            except OSError:
                continue
    webbrowser.open(url)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    add_args(ap)
    a = ap.parse_args()
    server = build_server(a.source, a.data, a.live, a.port)
    threading.Timer(0.5, open_window, [f"http://localhost:{a.port}/"]).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Stopped.")


if __name__ == "__main__":
    main()
