-- Hammerspoon bootstrap entrypoint (refactored architecture)

local Logger = require('core.logger')
local Events = require('core.events')
local Config = require('core.config')
local Lifecycle = require('core.lifecycle')
local Hotkeys = require('infra.hotkey-registry')
local CommandRunner = require('infra.command-runner')

local InputMethod = require('features.automation.auto-switch')
local WindowManager = require('features.window.manager')
local FinderActions = require('features.interaction.finder-actions')
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
  id = 'feature.hyperkey',
  module = require('features.shortcuts.controller'),
  deps = {'feature.finderActions'},
})

Lifecycle.register({
  id = 'feature.windowManager',
  module = WindowManager,
})

Lifecycle.register({
  id = 'feature.finderActions',
  module = FinderActions,
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

local function modsToString(mods)
  if not mods then return '' end
  return table.concat(mods, '+')
end

local function formatHyperkey(key)
  -- Format as: Hyperkey + KEY
  return 'Hyperkey + ' .. key
end

local function printHelpPanel()
  print('================ 支持的技能与快捷键（简体中文） ================')
  
  print('- 锁屏: 按 ' .. formatHyperkey('L') .. ' 锁定屏幕。')
  print('- 强制粘贴: 按 ' .. formatHyperkey('V') .. ' 使用粘贴助手忽略剪贴板格式并粘贴。')
  print('- 终端: 按 ' .. formatHyperkey('T') .. ' 在当前 Finder 路径打开终端。')
  print('- 编辑器: 按 ' .. formatHyperkey('C') .. ' 在当前 Finder 路径打开 VSCode。')
  print('- 浏览器: 按 ' .. formatHyperkey('B') .. ' 打开默认浏览器。')
  print('- 微信: 按 ' .. formatHyperkey('W') .. ' 打开或切换到微信。')
  print('- 企业微信: 按 ' .. formatHyperkey('Q') .. ' 打开或切换到企业微信。')
  print('- 窗口管理:')
  print('  * 按 ' .. formatHyperkey('←') .. ' 调整窗口到屏幕左半边')
  print('  * 按 ' .. formatHyperkey('→') .. ' 调整窗口到屏幕右半边')
  print('  * 按 ' .. formatHyperkey('↑') .. ' 调整窗口到屏幕上半部分')
  print('  * 按 ' .. formatHyperkey('↓') .. ' 调整窗口到屏幕下半部分')
  print('  * 按 ' .. formatHyperkey('Return') .. ' 最大化窗口')
  print('===============================================================')
end

printHelpPanel()
