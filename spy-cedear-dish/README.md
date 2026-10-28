# Placa SPY CEDEAR

Un cultivo simulado de 48 neuronas aprende a operar el CEDEAR de SPY en BYMA. La idea viene del experimento DishBrain:

- **Error:** una ráfaga de ruido impredecible. La placa se llena de estímulos al azar, y el camino que llevó a esa decisión se debilita.
- **Acierto:** un pulso tranquilo y regular. El camino que se activó se refuerza (Hebb) y baja la exploración.

Es un juego para aprender, no una recomendación de inversión.

## Instalación

### 1. Instalá Python (una sola vez)

Descargá Python 3.10 o más nuevo de <https://www.python.org/downloads/>.
En Windows, al instalarlo **marcá la casilla "Add python.exe to PATH"**.

### 2. Descargá la app

En la página del repositorio en GitHub, elegí la rama `ccr-b20afccb-s1dq3i`, tocá **Code → Download ZIP** y descomprimilo. Entrá a la carpeta `spy-cedear-dish`.

O con git:

```bash
git clone -b ccr-b20afccb-s1dq3i https://github.com/dantesurachi-create/claude-plugins-official
cd claude-plugins-official/spy-cedear-dish
```

### 3. Instalá

- **Windows:** doble clic en `instalar.bat`.
- **Mac / Linux:** en una terminal, dentro de la carpeta, `./instalar.sh`.

Tarda menos de un minuto.

### 4. Probá la conexión con IOL (opcional, recomendado)

- **Windows:** doble clic en `probar-conexion.bat`.
- **Mac / Linux:** `./probar-conexion.sh`.

Te pide tu usuario y contraseña de InvertirOnline y revisa, **sin operar**, el ingreso, los precios de SPY y SPYC, el historial y tu cartera. Si algo dice `FALLA`, copiá el resultado (no incluye tu contraseña).

### 5. Abrí la app

- **Windows:** doble clic en `iniciar.bat`.
- **Mac / Linux:** `./iniciar.sh`.

Te pide usuario y contraseña de IOL. No se guardan en ningún archivo; si apretás Enter sin escribir nada, la app arranca sin IOL. Se abre en su propia ventana (con Chrome o Edge; si no, en tu navegador). Para cerrarla, cerrá también la ventana negra de la terminal.

En Chrome o Edge también podés instalarla como app: con la app abierta en `http://localhost:8000`, elegí **Instalar app** en la barra de direcciones. Igual necesita que `iniciar` esté corriendo para tener precios.

## En el celular (Android)

La app corre en tu computadora y la abrís desde el celular por el Wi-Fi de tu casa. La computadora tiene que quedar prendida con la app abierta mientras opera.

1. Abrí la app con **`iniciar-con-celular.bat`** (Windows) o `./iniciar.sh --celular` (Mac/Linux).
   En Windows, si aparece el aviso del firewall, permití el acceso en **redes privadas**.
2. Conectá el celular **al mismo Wi-Fi** que la computadora.
3. Escaneá con la cámara del celular el código QR. Aparece en la terminal y en la app, en **Abrir en el celular**. Se abre en Chrome y el celular queda emparejado.
4. En Chrome tocá **⋮ → Agregar a la pantalla principal** para tenerla como una app más.

Seguridad:

- Solo entran los dispositivos que escanearon el código; cualquier otro equipo de la red ve un aviso.
- El código cambia cada vez que abrís la app, así que después de reiniciar hay que volver a escanear.
- No compartas el código QR.
- Tu usuario y contraseña de IOL quedan solo en la computadora.
- La conexión por Wi-Fi no está cifrada. Usala solo en la red de tu casa, no en Wi-Fi públicas.

Cada pantalla (la computadora y el celular) corre su propia placa. Con plata real, **opera solo la pantalla que la activó**: si la activás desde el celular, dejalo con la app abierta. La app evita que la pantalla se apague mientras opera en vivo.

## Modos

| Modo | Precios | Plata |
|---|---|---|
| Mercado simulado | Inventados | Ficticia |
| Práctica | Reales: historial de IOL y después precios en vivo | Ficticia ($1.000.000 virtuales) |
| Plata real | Reales | Tu cuenta de IOL, mientras esté activada |

- **Intervalo de operación:** cada cuánto decide la placa con precios en vivo: 15 s, 30 s, 1, 5, 15 o 30 min, 1 h, o una vez por día (con el primer precio después de que abre BYMA). Opera solo de 11 a 17, hora de Buenos Aires.
- **Costo por operación:** se descuenta del capital virtual cada vez que la placa pasa de CEDEARs a pesos o al revés.

## Plata real

Viene apagada. Para habilitarla:

- **Windows:** doble clic en `iniciar-plata-real.bat`. Te pregunta el máximo en pesos por compra y si querés abrirla también desde el celular.
- **Mac / Linux:** `./iniciar.sh --real --max-ars 20000` (sumá `--celular` para el teléfono).

La terminal muestra un **código de activación**. En la app elegí **Plata real**, escribí el código, marcá la casilla de confirmación y tocá **Activar plata real**. Desde ahí la placa:

- con **SUBE**, compra SPY hasta el máximo por compra, si no tiene ya;
- con **BAJA**, vende los SPY que compró ella. **Nunca vende los SPY que vos ya tenías.** Lleva la cuenta en `dish_positions.json`, limitada por lo que muestra tu cartera de IOL.

Protecciones:

- Hace falta el código de la terminal; reiniciar la app siempre la deja apagada y con un código nuevo.
- Como mucho 1 orden por minuto y 20 por día. Al llegar al límite diario se desactiva sola. Se puede cambiar con `DISH_MIN_INTERVAL` y `DISH_MAX_ORDERS_PER_DAY`.
- Solo manda órdenes con BYMA abierto.
- **Detener plata real** la apaga al instante.
- La app solo acepta pedidos de tu computadora y de los celulares emparejados.

Las órdenes son a precio límite, 0,5% del otro lado del último precio, válidas hasta el final del día, con liquidación a 24 h (`DISH_PLAZO=t1`).

Antes de activarla:

- La placa es un juguete. En las pruebas acertó apenas más de la mitad de las veces, y los costos se pueden comer esa ventaja. **Podés perder plata.**
- Una orden límite puede no ejecutarse; la placa puede creer que tiene SPY que no tiene hasta la próxima consulta de cartera.
- Las órdenes pendientes no se cancelan solas. Revisá tu cuenta de IOL.
- Las llamadas de órdenes siguen la librería iol-api y todavía no se probaron con una cuenta real. Empezá con un máximo chico.

## Otras fuentes de datos

- **TradingView:** abrí BCBA:SPY en gráfico diario y elegí **Exportar datos del gráfico**. Cargá el CSV con **Cargar CSV de TradingView**. Si sumás BCBA:SPYC, el CCL se calcula como SPY ÷ SPYC. También funciona en la versión web, sin instalar nada.
- **API de Market Data de BYMA** (con licencia, pedila a marketdata@byma.com.ar): `BYMA_CLIENT_ID`, `BYMA_CLIENT_SECRET` y `BYMA_FEED` (`snapshot`, `delay20` o `eod`), y abrí la app con `python -m finrl_byma.app --live byma`.

## Pruebas con FinRL (opcional)

Para comparar la placa con comprar y mantener y con el agente PPO de FinRL, usando el `StockTradingEnv` de FinRL con costos de 0,6% por operación:

```bash
.venv/bin/python -m pip install -r requirements-finrl.txt   # descarga grande (incluye PyTorch)
.venv/bin/python -m finrl_byma.run --source iol --ppo
```

En Windows, usá `.venv\Scripts\python` en lugar de `.venv/bin/python`.

Archivos de `finrl_byma/`: `processor.py` (procesador de datos al estilo FinRL), `dish_agent.py` (la placa), `run.py` (prueba), `iol_api.py` y `byma_api.py` (conexiones), `trader.py` (plata real), `server.py` y `app.py` (la app), `check.py` (prueba de conexión).
