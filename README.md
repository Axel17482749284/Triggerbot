<!-- README.md -->
# SimplyGodd Scripts

**Executor:** Xeno | **Bootstrap:** Voidstrap | **Platform:** PC  
**Discord:** [discord.gg/8xav7hPyF](https://discord.gg/8xav7hPyF)

---

## Triggerbot v1.3

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Axel17482749284/Triggerbot/main/triggerbot.lua"))()
```

---

## Features

- **Triggerbot** — dispara automático cuando el cursor está sobre un enemigo (hold key configurable)
- **Hitbox Expander ×3** — expande las hitboxes de todos los enemigos en cliente
- **HB Visual** — muestra las hitboxes expandidas en rojo transparente
- **Rebind dinámico** — cualquier tecla, desde la GUI, en la pestaña Binds
- **Config persistente** — guarda binds, delay y estados en `simplygodd_config.json`
- **AC humanization** — jitter de timing, click press/release, noise en raycast, burst limiter
- **GUI draggable** con tabs Main / Binds y pill toggles animados

---

## Cómo cambiar keybinds

1. Ejecuta el script
2. Abre la GUI (RCtrl por defecto)
3. Ve a la pestaña **Binds**
4. Haz click en el botón de la keybind que quieres cambiar (aparece `[ ... ]`)
5. Presiona la tecla que quieres asignar (cualquier tecla: R, T, X, F5, etc.)
6. Se guarda automáticamente para la próxima sesión
7. Escape cancela el rebind

---

## Keybinds por defecto

| Acción           | Tecla por defecto |
|------------------|-------------------|
| Triggerbot hold  | Q                 |
| Toggle TBot      | F1                |
| Toggle Hitbox    | F2                |
| Toggle HB Visual | F3                |
| Toggle GUI       | RCtrl             |

---

## Compatibilidad

| Executor   | Estado |
|------------|--------|
| Xeno       | ✅     |
| Voidstrap  | ✅     |
| Fluxus     | ✅     |
| Delta      | ✅     |
| Synapse X  | ✅     |

---

## Games compatibles

- Rivals
- Arsenal
- Duels
- Universal (cualquier shooter con HumanoidRootPart)

---

## Changelog

### v1.3
- Rebind dinámico desde GUI: cualquier tecla, guardado persistente en JSON
- Config save/load completo (binds + delay + estados on/off)
- RaycastParams moderno (FindPartOnRayWithIgnoreList deprecated)
- AC humanization: jitter de timing, humanClick press/release, noise en raycast, burst CPS limiter
- WeldConstraint + RenderStepped tracking — hitboxes no se desfasan
- clearHitboxes() desconecta connections, cero memory leak
- Tab Binds con scroll, delay editable, reset a defaults

### v1.2
- GUI draggable con pill toggles (TweenService)
- Hitbox Expander inicial
- Triggerbot básico con ray deprecated
- Banner de consola
