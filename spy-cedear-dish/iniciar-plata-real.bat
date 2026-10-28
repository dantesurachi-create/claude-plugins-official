@echo off
chcp 65001 >nul
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe (
  echo Primero hace doble clic en instalar.bat
  pause
  exit /b 1
)
set /p MAXARS="Maximo en pesos por compra (por ejemplo 20000): "
if "%MAXARS%"=="" set MAXARS=20000
.venv\Scripts\python -m finrl_byma.app --source iol --real --max-ars %MAXARS%
pause
