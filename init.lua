-- Hammerspoon bootstrap entrypoint (refactored architecture)

local Logger = require('core.logger')
local Events = require('core.events')
local Config = require('core.config')
local Lifecycle = require('core.lifecycle')
local Hotkeys = require('infra.hotkey-registry')
local CommandRunner = require('infra.command-runner')

local InputMethod = require('features.automation.auto-switch')
local PreviewPdf = require('features.interaction.pdf-fullscreen')

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
  desc = '重新加载配置',
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
  enabled = config.features.inputMethod,
})

Lifecycle.register({
  id = 'feature.hyperkey',
  module = require('features.shortcuts.controller'),
  enabled = config.features.hyperkey,
})

Lifecycle.register({
  id = 'feature.previewPdf',
  module = PreviewPdf,
  enabled = config.features.previewPdf,
})


local startupOk = Lifecycle.startAll()
if not startupOk then
  hs.alert.show('Hammerspoon startup failed. Check logs.', 3)
  local failed = Lifecycle.failedModules()
  log.error('Startup aborted due to module failure', {failed = failed})
  return
end

hs.alert.show('Hammerspoon config loaded', 1)

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
