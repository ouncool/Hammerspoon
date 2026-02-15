-- **************************************************
-- Hammerspoon Main Configuration Entry
-- **************************************************

-- Load core systems first
local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')
local Lifecycle = require('modules.core.lifecycle')
local Validator = require('modules.core.validator')

-- Configure logger
Logger.setLevel('INFO')
Logger.setDestination('console', true)
Logger.setDestination('notification', true)

local log = Logger.new('Init')

-- ==================================================
-- Hyper Key Setup: Caps Lock → Cmd + Opt + Ctrl + Shift
-- ==================================================
-- Disable Caps Lock functionality and remap to Hyper key
hs.hotkey.bind({}, 'F18', function()
  -- Empty function - Caps Lock acts as a modifier now
end)

-- Configure Caps Lock as Hyper Key modifier
-- Note: Use Karabiner-Elements or native macOS settings to map:
-- Caps Lock (key code 0) → Hyper Key (Cmd + Opt + Ctrl + Shift)
-- 
-- In Karabiner-Elements:
-- Add rule: caps_lock → left_command + left_option + left_control + left_shift

-- Hotkey to reload configuration: Cmd+Opt+Ctrl+R (still available)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

-- Load and validate configuration
local config = require('modules.utils.config')
local validConfig = Validator.mergeWithDefaults(config)

if not Validator.validateAndReport(validConfig) then
  log.warn('Configuration validation failed, using defaults')
end

-- Apply logging configuration from config
if validConfig.logging then
  if validConfig.logging.level then
    Logger.setLevel(validConfig.logging.level)
  end
  if validConfig.logging.file ~= nil then
    Logger.setDestination('file', validConfig.logging.file)
  end
  if validConfig.logging.console ~= nil then
    Logger.setDestination('console', validConfig.logging.console)
  end
  if validConfig.logging.notification ~= nil then
    Logger.setDestination('notification', validConfig.logging.notification)
  end
end

-- Helper function: Safely load module with lifecycle management
local function loadModule(name, options)
  options = options or {}
  
  if not name or type(name) ~= 'string' then
    log.error('Invalid module name: ' .. tostring(name))
    return nil
  end
  
  local ok, result = pcall(require, name)
  
  if not ok then
    log.error('Failed to load module: ' .. name, { error = result })
    hs.notify.new({
      title = "Hammerspoon",
      informativeText = "Failed to load module: " .. name .. "\n" .. tostring(result)
    }):send()
    return nil
  end
  
  -- Register with lifecycle manager
  Lifecycle.register(name, result, options.dependencies)
  
  -- Initialize module
  if options.autoInit ~= false then
    if not Lifecycle.init(name) then
      log.warn('Module initialization failed: ' .. name)
      return result
    end
  end
  
  -- Start module
  if options.autoStart ~= false then
    if not Lifecycle.start(name) then
      log.warn('Module start failed: ' .. name)
      return result
    end
  end
  
  return result
end

-- ==================================================
-- Core System Events
-- ==================================================

-- Emit config reloaded event
EventBus.emit(EventBus.EVENTS.CONFIG_RELOADED, {
  config = validConfig,
  timestamp = hs.timer.absoluteTime()
})

-- Watch for screen changes
hs.screen.watcher.new(function()
  EventBus.emit(EventBus.EVENTS.SCREEN_CHANGED, {
    screens = hs.screen.allScreens(),
    timestamp = hs.timer.absoluteTime()
  })
end):start()

-- ==================================================
-- Module Loading
-- ==================================================

-- --------------------------------------------------
-- Input Method Related
-- --------------------------------------------------
loadModule('modules.input-method.auto-switch', {
  dependencies = {},
  autoStart = true
})
-- loadModule('modules.input-method.indicator', {
--   dependencies = {'modules.input-method.auto-switch'},
--   autoStart = false  -- Disabled by default
-- })

-- --------------------------------------------------
-- Window Management
-- --------------------------------------------------
loadModule('modules.window.manager', {
  dependencies = {},
  autoStart = true
})

loadModule('modules.window.app-switcher', {
  dependencies = {},
  autoStart = true
})

-- --------------------------------------------------
-- Keyboard Enhancement
-- --------------------------------------------------
loadModule('modules.keyboard.paste-helper', {
  dependencies = {},
  autoStart = true
})

-- --------------------------------------------------
-- Application Integration
-- --------------------------------------------------
loadModule('modules.integration.hyper-key', {
  dependencies = {},
  autoStart = true
})

loadModule('modules.integration.finder-terminal', {
  dependencies = {},
  autoStart = true
})

loadModule('modules.integration.preview-pdf-fullscreen', {
  dependencies = {},
  autoStart = true
})

-- ==================================================
-- System Ready
-- ==================================================

-- 简洁的启动信息（只在有错误时显示详细统计）
Lifecycle.printStatus()
Lifecycle.printHotkeys()

-- 只在有错误时显示统计信息
local stats = Logger.getStats()
if stats.error > 0 or stats.fatal > 0 then
  EventBus.printStats()
  Logger.printStats()
end

-- Configuration loaded
hs.alert.show("✅ Hammerspoon 配置已加载")
