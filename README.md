<div align="center">

# jvl_reparto

![Version](https://img.shields.io/badge/version-1.0.0-0ea5e9?style=for-the-badge)
![FiveM](https://img.shields.io/badge/FiveM-ESX%20%7C%20QBCore%20%7C%20Qbox%20%7C%20ND-F40552?style=flat-square&logo=fivem&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-22c55e?style=flat-square)

**Trabajo de repartidor multi-framework para FiveM.**
Es el proyecto final (capítulo 28) del libro **Lua para FiveM** de JVL MediaCode.

</div>

---

## Qué hace

1. El jugador va al **centro de reparto** (puerto de Los Santos) y toma un paquete.
2. El servidor elige un **destino al azar** y lo marca con ruta en el GPS.
3. Al llegar, **entrega** el paquete con una barra de progreso.
4. El servidor **valida** distancia, tiempo, trabajo y cooldown, y **paga** en efectivo.

Funciona en **ESX, QBCore, Qbox, ND y standalone** (detección automática). Probado en Qbox.

## Requisitos

- [ox_lib](https://github.com/overextended/ox_lib) (obligatorio)
- [ox_inventory](https://github.com/overextended/ox_inventory) (solo en modo standalone, para pagar)

### Opcionales (gratis)

Si están arrancados, el script los usa solo; si no, usa los de ox_lib:

- [jvl_textui](https://github.com/JVLCustoms/jvl_textui): avisos de interacción ("[E] Tomar paquete").
- [jvl_progressbar](https://github.com/JVLCustoms/jvl_progressbar): barra de progreso de la entrega.

## Instalación

1. Copia la carpeta `jvl_reparto` a `resources/`.
2. Añade `ensure jvl_reparto` a tu `server.cfg`, **después** de `ox_lib` y de tu framework.
3. Al arrancar, la consola debe decir `[jvl_reparto] Framework detectado: <tu framework>`.

## Configuración

Todo está en `config.lua`:

| Opción | Para qué sirve |
| --- | --- |
| `Config.Framework` | `'auto'` o fuerza uno: `'esx'`, `'qbcore'`, `'qbox'`, `'nd'`, `'standalone'` |
| `Config.Trabajo` | Trabajo requerido (ej. `'repartidor'`) o `false` para que sea abierto a todos |
| `Config.Centro` | Dónde se toman los paquetes |
| `Config.Destinos` | Lista de puntos de entrega |
| `Config.Pago` | Pago mínimo y máximo por entrega |
| `Config.DistanciaEntrega` | Metros máximos al destino para cobrar (lo mide el servidor) |
| `Config.TiempoMinimo` | Segundos mínimos entre tomar y entregar |
| `Config.Debug` | Mensajes de depuración en la consola del servidor |

En standalone, el "trabajo" es el permiso ACE `reparto.trabajar`.

## Anti-trampas

- El cliente no decide nada: el destino lo elige y lo recuerda el servidor.
- Entregar lejos del destino o antes de `Config.TiempoMinimo` no paga y deja un aviso `[SOSPECHOSO]` en la consola.
- El paquete se cierra **antes** de pagar: no se puede cobrar dos veces.

## Licencia

MIT. Hecho por [JVL MediaCode](https://jvlmediacode.com) · [Discord](https://discord.gg/m2spgxkPfj)
