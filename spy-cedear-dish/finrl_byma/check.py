"""Check your IOL connection without trading: login, SPY and SPYC quotes, history and portfolio.

    IOL_USERNAME=... IOL_PASSWORD=... python -m finrl_byma.check

Read-only. It never places an order.
"""
from __future__ import annotations

from datetime import date, timedelta

from .app import ask_iol_login
from .iol_api import IOLClient


def step(name, fn):
    try:
        result = fn()
        print(f"  OK    {name}: {result}")
        return True
    except Exception as e:
        print(f"  FALLA {name}: {e}")
        return False


def main() -> None:
    if not ask_iol_login():
        return
    print("Revisando IOL (solo lectura)…")
    try:
        c = IOLClient()
        c._auth()
        print("  OK    ingreso")
    except Exception as e:
        print(f"  FALLA ingreso: {e}")
        return

    def quote(sym):
        q = c.quote(sym)
        if not q:
            raise RuntimeError("sin precio (no cotiza o todavía no operó)")
        return f"{q['price']:,.2f} a las {q['time']}  (campos: {', '.join(sorted(q['raw'])[:12])}…)"

    def history():
        df = c.history("SPY", date.today() - timedelta(days=30))
        if df.empty:
            raise RuntimeError("sin datos")
        return f"{len(df)} días, último {df.date.iloc[-1]} cierre {df.close.iloc[-1]:,.2f}"

    def ccl():
        spy, usd = c.quote("SPY"), c.quote("SPYC") or c.quote("SPYD")
        return f"{spy['price'] / usd['price']:,.2f} pesos por dólar (SPY ÷ {usd['symbol']})"

    results = [step("precio de SPY", lambda: quote("SPY")),
               step("precio de SPYC", lambda: quote("SPYC")),
               step("historial de SPY, últimos 30 días", history),
               step("CCL implícito", ccl),
               step("SPY en tu cartera", lambda: f"{c.portfolio_qty('SPY')} unidades")]
    print("\nTodo bien. Ya podés abrir la app." if all(results) else
          "\nAlgunas pruebas fallaron. Copiá este resultado (no incluye tu contraseña) para ajustar la conexión.")


if __name__ == "__main__":
    main()
