#!/usr/bin/env bash
# Instala Placa SPY CEDEAR en Mac o Linux.
set -e
cd "$(dirname "$0")"
if ! command -v python3 >/dev/null; then
  echo "Falta Python 3. Descargalo de https://www.python.org/downloads/"
  exit 1
fi
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
echo
echo "Listo. Para abrir la app: ./iniciar.sh"
