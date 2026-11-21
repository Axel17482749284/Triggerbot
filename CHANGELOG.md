<!-- CHANGELOG.md -->
# Changelog — SimplyGodd Scripts

## v1.3 — 2026-11-21

### Nuevo
- Rebind dinámico desde la pestaña Binds de la GUI
- Cualquier tecla del teclado acepta como bind (Q, R, T, X, F5, Insert, etc.)
- Escape cancela un rebind en progreso sin aplicar nada
- Config persistente: `simplygodd_config.json` guarda binds, delay, multiplier y estados
- loadConfig() al inicio restaura la sesión anterior automáticamente
- Tab bar en GUI: Main (toggles) y Binds (rebind + delay + reset)
- Reset a defaults con un botón en la pestaña Binds
- Los keylabels del tab Main se actualizan en tiempo real al rebindear

### Anticheat
- humanDelay(): jitter ±20ms sobre el delay base elimina timing perfecto
- humanClick(): mouse1press + hold 40-90ms + mouse1release replica input humano
- getTarget() con noise ±2px en raycast rompe firma de "siempre centrado exacto"
- canFire(): burst limiter de 8 CPS, ventana deslizante de 1 segundo
- lockBoxToClient(): SetNetworkOwner(nil) en cada hitbox box

### Fix
- RaycastParams moderno reemplaza FindPartOnRayWithIgnoreList (deprecated Roblox 2024)
- clearHitboxes() desconecta RenderStepped connections antes de Destroy — sin memory leak
- doClick() con triple fallback: mouse1press/release → mouse1click → VirtualInputManager

## v1.2 — anterior
- GUI draggable con pill toggles animados
- Hitbox Expander con WeldConstraint
- Triggerbot hold-key básico
- Banner de output en consola del executor
- Keybinds globales hardcoded F1/F2/F3/RCtrl
