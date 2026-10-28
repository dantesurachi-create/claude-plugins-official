#!/usr/bin/env bash
# Abre Placa SPY CEDEAR. Agregá --real para habilitar plata real, por ejemplo: ./iniciar.sh --real --max-ars 20000
cd "$(dirname "$0")"
[ -x .venv/bin/python ] || { echo "Primero corré ./instalar.sh"; exit 1; }
exec .venv/bin/python -m finrl_byma.app --source iol "$@"
