# SimplyGodd Scripts

**Executor:** Xeno | **Bootstrap:** Voidstrap | **Platform:** PC

---

## Triggerbot v1.3

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Axel17482749284/Triggerbot/main/triggerbot.lua"))()
```

---

## Features

- Triggerbot (hold Q) — dispara automático cuando el cursor está sobre un enemigo
- Hitbox Expander ×3 — expande las hitboxes de todos los enemigos
- Hitbox Visual — muestra las hitboxes expandidas en rojo transparente
- GUI draggable con pill toggles animados

---

## Keybinds

| Tecla    | Función              |
|----------|----------------------|
| F1       | Toggle Triggerbot    |
| F2       | Toggle Hitbox        |
| F3       | Toggle HB Visual     |
| RCtrl    | Toggle GUI           |
| Q (hold) | Activar Triggerbot   |

---

## Compatibilidad

| Executor  | Estado |
|-----------|--------|
| Xeno      | ✅     |
| Voidstrap | ✅     |
| Fluxus    | ✅     |
| Delta     | ✅     |
| Synapse X | ✅     |

---

## Games compatibles

- Rivals
- Arsenal
- Duels
- Universal (cualquier shooter con HumanoidRootPart)

---

## Changelog

### v1.3
- Migración a `RaycastParams` (API moderna, `FindPartOnRayWithIgnoreList` deprecated)
- `doClick()` con triple fallback: `mouse1click` → `click` → `VirtualInputManager`
- Hitbox tracking via `WeldConstraint` + `RenderStepped` — boxes no se desfasan
- `clearHitboxes()` desconecta connections antes de destruir — sin memory leak
- Toggle HB Visual sin rebuild, respuesta inmediata

### v1.2
- GUI draggable con pill toggles
- Hitbox Expander inicial
- Triggerbot básico con ray deprecated
