@echo off
chcp 65001 >nul
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (
  echo Primero hace doble clic en instalar.bat
  pause
  exit /b 1
)
echo Si Windows pregunta por el firewall, permiti el acceso en redes PRIVADAS.
.venv\Scripts\python -m finrl_byma.app --source iol --celular %*
pause
