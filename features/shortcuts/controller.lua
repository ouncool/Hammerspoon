-- Unified Hyperkey controller (cmd+alt+ctrl+shift combinations)
local AppLauncher = require('features.shortcuts.app-launcher')
local Clipboard = require('features.interaction.clipboard')
local FinderActions = require('features.interaction.finder-actions')
local WindowOps = require('features.window.operations')
local HelpDisplay = require('features.shortcuts.help-display')

local M = {}

local ctx = nil
local log = nil
local windowOps = nil

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('HyperkeyController')
  windowOps = WindowOps.new(ctx)
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
  local ok, err = FinderActions.openInTerminal()
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
  local ok, err = FinderActions.openInEditor()
  if not ok then
    hs.alert.show(err or 'Failed to open editor')
    log.warn('Open editor failed', {error = err})
    return
  end
  log.info('Opened VSCode in Finder path')
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
  if not appPath or appPath == '' then
    hs.alert.show('WeChat not configured')
    log.warn('WeChat not configured')
    return
  end

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
  if not appPath or appPath == '' then
    hs.alert.show('WeWork not configured')
    log.warn('WeWork not configured')
    return
  end

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

  -- Hyperkey + L: Lock screen
  ctx.hotkeys.bind({
    id = 'hyperkey.lock',
    group = 'hyperkey',
    mods = mods,
    key = 'L',
    desc = 'Lock screen',
    action = lockScreen,
  })

  -- Hyperkey + V: Force paste
  ctx.hotkeys.bind({
    id = 'hyperkey.paste',
    group = 'hyperkey',
    mods = mods,
    key = 'V',
    desc = 'Force paste clipboard text',
    action = Clipboard.forcePaste,
  })

  -- Hyperkey + T: Open terminal in Finder path
  ctx.hotkeys.bind({
    id = 'hyperkey.terminal',
    group = 'hyperkey',
    mods = mods,
    key = 'T',
    desc = 'Open terminal in Finder path',
    action = openTerminal,
  })

  -- Hyperkey + C: Open VSCode in Finder path
  ctx.hotkeys.bind({
    id = 'hyperkey.editor',
    group = 'hyperkey',
    mods = mods,
    key = 'C',
    desc = 'Open VSCode in Finder path',
    action = openVSCode,
  })

  -- Hyperkey + B: Open browser
  ctx.hotkeys.bind({
    id = 'hyperkey.browser',
    group = 'hyperkey',
    mods = mods,
    key = 'B',
    desc = 'Open default browser',
    action = openBrowser,
  })

  -- Hyperkey + W: Open WeChat
  ctx.hotkeys.bind({
    id = 'hyperkey.wechat',
    group = 'hyperkey',
    mods = mods,
    key = 'W',
    desc = 'Open WeChat',
    action = openWeChat,
  })

  -- Hyperkey + Q: Open WeWork
  ctx.hotkeys.bind({
    id = 'hyperkey.weworkMac',
    group = 'hyperkey',
    mods = mods,
    key = 'Q',
    desc = 'Open WeWork',
    action = openWeWork,
  })

  -- Hyperkey + Left: Window left half
  ctx.hotkeys.bind({
    id = 'hyperkey.window.left',
    group = 'hyperkey',
    mods = mods,
    key = 'left',
    desc = 'Resize window to left half',
    action = windowLeft,
  })

  -- Hyperkey + Right: Window right half
  ctx.hotkeys.bind({
    id = 'hyperkey.window.right',
    group = 'hyperkey',
    mods = mods,
    key = 'right',
    desc = 'Resize window to right half',
    action = windowRight,
  })

  -- Hyperkey + Up: Window upper half
  ctx.hotkeys.bind({
    id = 'hyperkey.window.up',
    group = 'hyperkey',
    mods = mods,
    key = 'up',
    desc = 'Resize window to upper half',
    action = windowUp,
  })

  -- Hyperkey + Down: Window lower half
  ctx.hotkeys.bind({
    id = 'hyperkey.window.down',
    group = 'hyperkey',
    mods = mods,
    key = 'down',
    desc = 'Resize window to lower half',
    action = windowDown,
  })

  -- Hyperkey + Return: Maximize window
  ctx.hotkeys.bind({
    id = 'hyperkey.window.maximize',
    group = 'hyperkey',
    mods = mods,
    key = 'Return',
    desc = 'Maximize current window',
    action = windowMaximize,
  })

  -- Hyperkey + H: Show help panel
  ctx.hotkeys.bind({
    id = 'hyperkey.help',
    group = 'hyperkey',
    mods = mods,
    key = 'H',
    desc = 'Show help panel with all hotkeys',
    action = showHelp,
  })

  log.info('Hyperkey controller started with 13 hotkeys bound')
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
end

return M
