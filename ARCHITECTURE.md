# Architecture (Refactored)

## Overview

The system is split into four layers:

1. `core`: cross-cutting runtime primitives (config/events/logging/lifecycle)
2. `infra`: adapters for OS interactions (hotkeys, commands, app discovery)
3. `shared`: stateless utility helpers
4. `features`: end-user functionality modules

No compatibility shims are kept for the previous `modules/*` architecture.

## Core

### `core/config.lua`

- Loads `config.lua`
- Merges with defaults
- Validates strictly against schema
- Rejects unknown keys
- Exposes immutable config snapshot

Primary APIs:

- `Config.reload() -> ok, errors`
- `Config.get() -> table`
- `Config.defaults() -> table`

### `core/events.lua`

Event bus for feature decoupling.

Primary APIs:

- `Events.on(name, callback, options)`
- `Events.once(name, callback, options)`
- `Events.off(name, callback?)`
- `Events.emit(name, payload)`

Event name constants are in `Events.NAMES`.

### `core/logger.lua`

Scoped logger with level filtering and optional notifications.

Primary APIs:

- `Logger.configure(config)`
- `Logger.setLevel(level)`
- `Logger.scope(name)`
- `Logger.getStats()`

### `core/lifecycle.lua`

Dependency-aware module orchestrator.

Primary APIs:

- `Lifecycle.setContext(ctx)`
- `Lifecycle.register({id, module, deps?, enabled?})`
- `Lifecycle.startAll()`
- `Lifecycle.stopAll()`
- `Lifecycle.disposeAll()`
- `Lifecycle.status()`

## Infra

### `infra/hotkey-registry.lua`

Centralized bind/unbind with group semantics.

- `bind({id, mods, key, action, desc?, group?})`
- `unbind(id)`
- `unbindGroup(group)`
- `list()`

### `infra/command-runner.lua`

Single shell execution surface.

- `run({cmd, args?, cwd?, raw?}) -> {ok, code, stdout, stderr, command}`
- `shellQuote(value)`

### `infra/app-discovery.lua`

Application discovery/open helpers.

- `existsApp(path)`
- `firstExisting(paths)`
- `openFirstAvailable(paths)`
- `openApp(path, args?)`
- `hasCLI(binary)`

## Shared

- `shared/timing.lua`: `debounce`, `throttle`
- `shared/finder.lua`: Finder current path and shell quoting
- `shared/animation.lua`: easing helper

## Features

### Input Method

`features/input-method/auto-switch.lua`

- Watches app activation
- Maps app to target input source
- Emits will-change/changed events

### Window Management

- `features/window/operations.lua`: geometry actions
- `features/window/manager.lua`: modal UI and key mapping

### App Switcher

`features/switcher/app-switcher.lua`

- Chooser-based app switching
- Hotkeys via registry

### Finder Integration

`features/integration/finder-actions.lua`

- Reusable actions only (no direct hotkey binding)
- Open Finder path in terminal/editor

### Hyper Shortcuts

`features/hyper/shortcuts.lua`

- Single hotkey entrypoint for Hyper shortcuts
- Depends on `finder-actions`

### PDF Fullscreen

`features/integration/pdf-fullscreen.lua`

- Monitors Preview windows
- Fullscreens PDF windows with debounce

### Paste Helper

`features/clipboard/paste-helper.lua`

- Synthetic keystroke paste (`Cmd+Shift+V`)

## Bootstrap Flow (`init.lua`)

1. Load config and configure logger
2. Register global reload hotkey
3. Build runtime context
4. Register feature modules and dependencies
5. Start all modules through lifecycle
6. Emit config/screen events

## Testing Strategy

- Reload smoke test (`hs.reload()`)
- Hotkey collision check (`Hotkeys.list()`)
- Feature-path manual checks:
  - Hyper shortcuts
  - Window mode
  - Input method switch
  - App switcher
  - Finder open actions
  - Preview PDF fullscreen
