# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Hammerspoon configuration for macOS personal automation: hotkeys, window management, input method switching, and Finder/app integration. Hammerspoon executes Lua and provides `hs.*` APIs to control macOS.

## Development Commands

```bash
# Reload config (primary dev loop)
# In Hammerspoon console or via hotkey: Cmd+Alt+Ctrl+R

# Open Hammerspoon console (for logs and REPL)
# Hammerspoon menubar icon → Console

# Check all active hotkey bindings
Hotkeys.list()   -- run in hs console

# View event bus stats
Events.stats()   -- run in hs console

# View logger stats
Logger.getStats()  -- run in hs console
```

There are no build steps, linting tools, or automated tests. The test workflow is:
1. Edit a `.lua` file
2. Press `Cmd+Alt+Ctrl+R` to reload (or `hs.reload()` in console)
3. Check the Hammerspoon console for errors and log output
4. Manually verify the changed behavior

## Architecture

4-layer architecture with strict dependency direction (no upward imports):

```
features/ → shared/ + infra/ → core/
```

**`core/`** — Runtime primitives (no Hammerspoon hs.* dependencies except logger)
- `config.lua`: Loads `config.lua`, deep-merges with schema defaults, strict validation (unknown keys rejected)
- `schema.lua`: All valid config keys, types, defaults, and constraints
- `events.lua`: Pub/sub event bus; constants in `Events.NAMES`
- `logger.lua`: Scoped logger; `Logger.scope('Name')` returns `{debug,info,warn,error,fatal}`
- `lifecycle.lua`: Module orchestrator with topological dependency sort

**`infra/`** — OS adapters
- `hotkey-registry.lua`: Bind/unbind with group semantics (group = bulk unbind on reload/stop)
- `command-runner.lua`: Shell execution with `shellQuote()` for safety
- `app-discovery.lua`: App detection helpers

**`shared/`** — Stateless utilities
- `timing.lua`: `debounce(fn, delay)` and `throttle(fn, delay)`, both cancellable
- `finder.lua`: AppleScript-based Finder path retrieval + shell quoting

**`features/`** — End-user functionality; each feature is a module

## Module Pattern

Every feature module exports exactly this shape:

```lua
return {
  setup = function(context) ... end,  -- receive context, store refs, return bool
  start = function() ... end,          -- bind hotkeys, start watchers, return bool
  stop  = function() ... end,          -- unbind hotkeys, stop watchers, return bool
  dispose = function() ... end,        -- nil out references
}
```

The runtime `context` injected in `setup()` contains: `config`, `logger`, `events`, `hotkeys`, `commands`.

Modules declare dependencies in `init.lua`:
```lua
Lifecycle.register('feature.myFeature', MyModule, {'feature.otherFeature'})
```

## Configuration

User config lives in `config.lua` (root). All valid keys and their defaults are in `core/schema.lua`. Unknown keys cause a hard validation error on reload. Arrays are replaced entirely on merge; tables are deep-merged.

When adding a new config key: add it to `core/schema.lua` first (with type, default, constraints), then consume it in the feature.

## Adding a Feature

1. Create `features/<category>/<name>.lua` implementing the module pattern
2. Register in `init.lua` with `Lifecycle.register()`
3. Add any new config keys to `core/schema.lua`
4. Bind hotkeys via `context.hotkeys.bind({id, mods, key, action, desc, group})`
5. Use `context.events.emit()` / `context.events.on()` for cross-module communication

## Key Hotkeys (Hyperkey = Cmd+Alt+Ctrl+Shift)

| Key | Action |
|-----|--------|
| Hyperkey+H | Show help panel |
| Hyperkey+L | Lock screen |
| Hyperkey+V | Force paste |
| Hyperkey+T | Open terminal at Finder path |
| Hyperkey+C | Open editor at Finder path |
| Hyperkey+F | Open Finder Downloads |
| Hyperkey+B | Open browser |
| Hyperkey+Arrows | Snap window to half |
| Hyperkey+Return | Maximize window |
| Cmd+Alt+Ctrl+R | Reload config |
