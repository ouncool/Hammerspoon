-- Hammerspoon bootstrap entrypoint (refactored architecture)

local Logger = require('core.logger')
local Events = require('core.events')
local Config = require('core.config')
local Lifecycle = require('core.lifecycle')
local Hotkeys = require('infra.hotkey-registry')
local CommandRunner = require('infra.command-runner')

local InputMethod = require('features.input-method.auto-switch')
local WindowManager = require('features.window.manager')
local AppSwitcher = require('features.switcher.app-switcher')
local PasteHelper = require('features.clipboard.paste-helper')
local FinderActions = require('features.integration.finder-actions')
local HyperShortcuts = require('features.hyper.shortcuts')
local PreviewPdf = require('features.integration.pdf-fullscreen')

local ok, errors = Config.reload()
if not ok then
  print('[Config] invalid config, using defaults')
  for _, err in ipairs(errors or {}) do
    print('  - ' .. tostring(err))
  end
end

local config = Config.get()
Logger.configure(config.logging)

local log = Logger.scope('Init')

-- Keep F18 available as a no-op key for Hyper mapping tools.
hs.hotkey.bind({}, 'F18', function()
end)

-- Global reload hotkey.
Hotkeys.bind({
  id = 'global.reload',
  group = 'global',
  mods = config.hotkeys.reload.mods,
  key = config.hotkeys.reload.key,
  desc = 'Reload Hammerspoon config',
  action = function()
    hs.reload()
  end,
})

local context = {
  config = config,
  logger = Logger,
  events = Events,
  hotkeys = Hotkeys,
  command = CommandRunner,
}

Lifecycle.setContext(context)

Lifecycle.register({
  id = 'feature.inputMethod',
  module = InputMethod,
})

Lifecycle.register({
  id = 'feature.windowManager',
  module = WindowManager,
})

Lifecycle.register({
  id = 'feature.appSwitcher',
  module = AppSwitcher,
})

Lifecycle.register({
  id = 'feature.pasteHelper',
  module = PasteHelper,
})

Lifecycle.register({
  id = 'feature.finderActions',
  module = FinderActions,
})

Lifecycle.register({
  id = 'feature.hyperShortcuts',
  module = HyperShortcuts,
  deps = {'feature.finderActions'},
})

Lifecycle.register({
  id = 'feature.previewPdf',
  module = PreviewPdf,
})

local startupOk = Lifecycle.startAll()
if not startupOk then
  hs.alert.show('Hammerspoon startup failed. Check logs.', 3)
else
  hs.alert.show('Hammerspoon config loaded', 1)
end

Events.emit(Events.NAMES.CONFIG_RELOADED, {
  timestamp = hs.timer.absoluteTime(),
})

local screenWatcher = hs.screen.watcher.new(function()
  Events.emit(Events.NAMES.SCREEN_CHANGED, {
    timestamp = hs.timer.absoluteTime(),
    screens = hs.screen.allScreens(),
  })
end)
screenWatcher:start()

local started = Lifecycle.startedModules()
log.info('Started modules', {count = #started, modules = started})

local failed = Lifecycle.failedModules()
if #failed > 0 then
  log.error('Failed modules', {failed = failed})
end

local function printHotkeys()
  local list = Hotkeys.list()
  if #list == 0 then
    return
  end

  print('Active hotkeys:')
  for _, item in ipairs(list) do
    local mods = table.concat(item.mods, '+')
    print(string.format('  %s: %s+%s (%s)', item.id, mods, item.key, item.group or 'none'))
  end
end

printHotkeys()
