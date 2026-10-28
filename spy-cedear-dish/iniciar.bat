@echo off
chcp 65001 >nul
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (
  echo Primero hace doble clic en instalar.bat
  pause
  exit /b 1
)
.venv\Scripts\python -m finrl_byma.app --source iol %*
pause
