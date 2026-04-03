-- Unified Hyperkey controller (cmd+alt+ctrl+shift combinations)
local AppDiscovery = require('infra.app-discovery')
local AppLauncher = require('features.shortcuts.app-launcher')
local Clipboard = require('features.interaction.clipboard')
local FinderActionsModule = require('features.interaction.finder-actions')
local WindowOps = require('features.window.operations')
local HelpDisplay = require('features.shortcuts.help-display')

local M = {}

local ctx = nil
local log = nil
local windowOps = nil
local finderActions = nil

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('HyperkeyController')
  windowOps = WindowOps.new(ctx)
  finderActions = FinderActionsModule.new(ctx)
  AppLauncher.setup(runtime)
  Clipboard.setup(runtime)
  HelpDisplay.setup(runtime)
  return true
end

-- Hyperkey + L: Lock screen
local function lockScreen()
  log.info('Locking screen')
  hs.caffeinate.lockScreen()
end


-- Hyperkey + T: Open terminal in Finder path
local function openTerminal()
  local ok, err = finderActions.openInTerminal()
  if ok then
    hs.alert.show('Terminal opened')
    log.info('Opened terminal in Finder path')
  else
    hs.alert.show(err or 'Failed to open terminal')
    log.warn('Open terminal failed', {error = err})
  end
end

-- Hyperkey + C: Open VSCode in Finder path
local function openVSCode()
  local ok, err = finderActions.openInEditor()
  if not ok then
    hs.alert.show(err or 'Failed to open editor')
    log.warn('Open editor failed', {error = err})
    return
  end
  log.info('Opened VSCode in Finder path')
end

-- Hyperkey + F: Open Finder at Downloads
local function openFinderDownloads()
  local home = os.getenv('HOME')
  if not home or home == '' then
    hs.alert.show('HOME not set')
    log.warn('HOME not set, cannot open Downloads')
    return
  end

  local targetPath = home .. '/Downloads'
  local ok, err = finderActions.openInFinder(targetPath)
  if not ok then
    hs.alert.show(err or 'Failed to open Finder')
    log.warn('Open Finder failed', {error = err, path = targetPath})
    return
  end
  log.info('Opened Finder Downloads', {path = targetPath})
end

-- Hyperkey + B: Open default browser
local function openBrowser()
  local ok, _ = AppLauncher.openFirstApp(ctx.config.apps.browsers)
  if not ok then
    hs.alert.show('No browser found')
    log.warn('No browser found')
    return
  end
  log.info('Opened browser')
end

-- Hyperkey + W: Open or switch to WeChat
local function openWeChat()
  local appPath = ctx.config.apps.wechat
  local ok, _ = AppLauncher.switchOrLaunch(appPath)
  if not ok then
    hs.alert.show('WeChat not found')
    log.warn('WeChat not available')
    return
  end
  log.info('Opened/switched to WeChat')
end

-- Hyperkey + Q: Open or switch to WeWork
local function openWeWork()
  local appPath = ctx.config.apps.weworkMac
  local ok, _ = AppLauncher.switchOrLaunch(appPath)
  if not ok then
    hs.alert.show('WeWork not found')
    log.warn('WeWork not available')
    return
  end
  log.info('Opened/switched to WeWork')
end

-- Hyperkey + Arrow keys: Window operations
local function windowLeft()
  windowOps.halfLeft()
end

local function windowRight()
  windowOps.halfRight()
end

local function windowUp()
  windowOps.halfTop()
end

local function windowDown()
  windowOps.halfBottom()
end

-- Hyperkey + Return: Maximize window
local function windowMaximize()
  windowOps.maximize()
end

-- Hyperkey + H: Show help panel
local function showHelp()
  log.info('Showing help panel')
  HelpDisplay.show()
end

function M.start()
  local mods = ctx.config.hotkeys.hyperMods

  ctx.hotkeys.bind({
    id = 'hyperkey.lock',
    group = 'hyperkey',
    mods = mods,
    key = 'L',
    desc = '锁屏',
    action = lockScreen,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.paste',
    group = 'hyperkey',
    mods = mods,
    key = 'V',
    desc = '强制粘贴',
    action = Clipboard.forcePaste,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.terminal',
    group = 'hyperkey',
    mods = mods,
    key = 'T',
    desc = '打开终端（Finder 路径）',
    action = openTerminal,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.editor',
    group = 'hyperkey',
    mods = mods,
    key = 'C',
    desc = '打开编辑器（Finder 路径）',
    action = openVSCode,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.finder',
    group = 'hyperkey',
    mods = mods,
    key = 'F',
    desc = '打开下载目录',
    action = openFinderDownloads,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.browser',
    group = 'hyperkey',
    mods = mods,
    key = 'B',
    desc = '打开浏览器',
    action = openBrowser,
  })

  if AppDiscovery.existsApp(ctx.config.apps.wechat) then
    ctx.hotkeys.bind({
      id = 'hyperkey.wechat',
      group = 'hyperkey',
      mods = mods,
      key = 'W',
      desc = '打开微信',
      action = openWeChat,
    })
  end

  if AppDiscovery.existsApp(ctx.config.apps.weworkMac) then
    ctx.hotkeys.bind({
      id = 'hyperkey.weworkMac',
      group = 'hyperkey',
      mods = mods,
      key = 'Q',
      desc = '打开企业微信',
      action = openWeWork,
    })
  end

  ctx.hotkeys.bind({
    id = 'hyperkey.window.left',
    group = 'hyperkey',
    mods = mods,
    key = 'left',
    desc = '窗口左半屏',
    action = windowLeft,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.window.right',
    group = 'hyperkey',
    mods = mods,
    key = 'right',
    desc = '窗口右半屏',
    action = windowRight,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.window.up',
    group = 'hyperkey',
    mods = mods,
    key = 'up',
    desc = '窗口上半屏',
    action = windowUp,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.window.down',
    group = 'hyperkey',
    mods = mods,
    key = 'down',
    desc = '窗口下半屏',
    action = windowDown,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.window.maximize',
    group = 'hyperkey',
    mods = mods,
    key = 'Return',
    desc = '窗口最大化',
    action = windowMaximize,
  })

  ctx.hotkeys.bind({
    id = 'hyperkey.help',
    group = 'hyperkey',
    mods = mods,
    key = 'H',
    desc = '显示帮助面板',
    action = showHelp,
  })

  log.info('Hyperkey controller started')
  return true
end

function M.stop()
  ctx.hotkeys.unbindGroup('hyperkey')
  return true
end

function M.dispose()
  ctx = nil
  log = nil
  windowOps = nil
  finderActions = nil
end

return M
