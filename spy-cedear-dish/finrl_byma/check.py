"""Check your IOL connection without trading: login, SPY and SPYC quotes, history and portfolio.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.check

Read-only. It never places an order.
"""
from __future__ import annotations

from datetime import date, timedelta

from .iol_api import IOLClient


def step(name, fn):
    try:
        result = fn()
        print(f"  OK    {name}: {result}")
        return True
    except Exception as e:
        print(f"  FAIL  {name}: {e}")
        return False


def main() -> None:
    print("Checking IOL (read-only)…")
    try:
        c = IOLClient()
        c._auth()
        print("  OK    login")
    except Exception as e:
        print(f"  FAIL  login: {e}")
        return

    def quote(sym):
        q = c.quote(sym)
        if not q:
            raise RuntimeError("no price (not listed, or no trades yet)")
        return f"{q['price']:,.2f} at {q['time']}  (fields: {', '.join(sorted(q['raw'])[:12])}…)"

    def history():
        df = c.history("SPY", date.today() - timedelta(days=30))
        if df.empty:
            raise RuntimeError("no rows")
        return f"{len(df)} days, last {df.date.iloc[-1]} close {df.close.iloc[-1]:,.2f}"

    def ccl():
        spy, usd = c.quote("SPY"), c.quote("SPYC") or c.quote("SPYD")
        return f"{spy['price'] / usd['price']:,.2f} ARS per USD (SPY ÷ {usd['symbol']})"

    results = [step("SPY quote", lambda: quote("SPY")),
               step("SPYC quote", lambda: quote("SPYC")),
               step("SPY history, last 30 days", history),
               step("implied CCL", ccl),
               step("SPY in your portfolio", lambda: f"{c.portfolio_qty('SPY')} units")]
    print("\nAll good. You can run the app." if all(results) else
          "\nSome checks failed. Paste this output (it contains no password) so the client can be adjusted.")


if __name__ == "__main__":
    main()
