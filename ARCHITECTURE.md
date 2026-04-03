# Architecture (Refactored)

## Overview

The system is split into four layers:

1. `core`: cross-cutting runtime primitives (config/events/logging/lifecycle)
2. `infra`: adapters for OS interactions (hotkeys, commands, app discovery)
3. `shared`: stateless utility helpers
4. `features`: end-user functionality modules

No compatibility shims are kept for the previous `modules/*` architecture, except a temporary config-key migration for removed legacy keys.

## Core

### `core/config.lua`

- Loads `config.lua`
- Merges with defaults
- Validates strictly against schema
- Rejects unknown keys
- Exposes immutable config snapshot
- Sanitizes a small set of legacy keys before validation

Primary APIs:

- `Config.reload() -> ok, errors`
- `Config.get() -> table`
- `Config.defaults() -> table`

Config change checklist:

1. Update user-facing sample values in `config.lua`
2. Update defaults and schema in `core/schema.lua`
3. Update legacy sanitization in `core/config.lua` if removing or renaming keys
4. Update runtime consumers under `init.lua` / `features/*`
5. Update the config matrix in `README.md`

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
## Features

### Input Method

`features/automation/auto-switch.lua`

- Watches app activation
- Maps app to target input source
- Emits will-change/changed events

### Window Management

- `features/window/operations.lua`: geometry actions

### Finder Integration

`features/interaction/finder-actions.lua`

- Reusable actions only (no direct hotkey binding)
- Open Finder path in terminal/editor/Finder

### Hyper Shortcuts

`features/shortcuts/controller.lua`

- Single hotkey entrypoint for Hyper shortcuts
- Depends on `finder-actions`

### PDF Fullscreen

`features/interaction/pdf-fullscreen.lua`

- Monitors Preview windows
- Fullscreens PDF windows with debounce

### Paste Helper

`features/interaction/clipboard.lua`

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
  - Window geometry actions
  - Input method switch
  - Finder open actions
  - Preview PDF fullscreen
- Config drift check:
  - every key in `config.lua` must exist in `core/schema.lua`
  - every documented key in `README.md` must have a runtime consumer or be explicitly marked as reserved
