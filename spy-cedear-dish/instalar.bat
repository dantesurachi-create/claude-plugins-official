@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Instalando Placa SPY CEDEAR...
where py >nul 2>nul
if errorlevel 1 (
  echo.
  echo Falta Python. Descargalo de https://www.python.org/downloads/ y, al instalarlo,
  echo marca la casilla "Add python.exe to PATH". Despues volve a abrir este archivo.
  pause
  exit /b 1
)
py -3 -m venv .venv || goto error
.venv\Scripts\python -m pip install --upgrade pip
.venv\Scripts\python -m pip install -r requirements.txt || goto error
echo.
echo Listo. Para abrir la app, hace doble clic en iniciar.bat
pause
exit /b 0
:error
echo.
echo Algo fallo durante la instalacion. Copia el mensaje de arriba para revisarlo.
pause
exit /b 1
