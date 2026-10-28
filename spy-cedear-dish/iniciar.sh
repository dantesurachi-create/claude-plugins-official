#!/usr/bin/env bash
# Abre Placa SPY CEDEAR. Opciones: --celular (abrirla desde el celular en el mismo Wi-Fi), --real --max-ars 20000 (plata real).
cd "$(dirname "$0")"
[ -x .venv/bin/python ] || { echo "Primero corré ./instalar.sh"; exit 1; }
exec .venv/bin/python -m finrl_byma.app --source iol "$@"
