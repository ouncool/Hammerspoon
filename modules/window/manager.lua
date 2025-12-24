-- **************************************************
-- Simple Vim-style window manager
-- Prefix key: Option + R to enter management mode
-- Mode key bindings:
--   h / l / j / k : Left/Right/Bottom/Top half screen
--   y / u / i / o : Top-left/Bottom-left/Top-right/Bottom-right quarter
--   f : Maximize
--   c : Close window
--   tab : Show help
--   q / esc : Exit management mode
-- **************************************************

local vimOps = require('modules.window.vim-operations')
local Logger = require('modules.core.logger')

local log = Logger.new('WindowManager')

-- Create window management modal
local windowModal = hs.hotkey.modal.new({'alt'}, 'r')

-- Help display timer
local helpTimer = nil

-- Show help information
local function showHelp()
  if helpTimer then helpTimer:stop() helpTimer = nil end
  hs.alert.show(vimOps.helpMessage, 5)
end

-- Prompt when entering mode
function windowModal:entered()
  hs.alert.show('Window Management Mode', 1)
  log.debug('Entered window management mode')
end

function windowModal:exited()
  hs.alert.show('Exit Window Management', 1)
  log.debug('Exited window management mode')
end

-- Bind window operation keys
windowModal:bind('', 'h', vimOps.operations.halfLeft)
windowModal:bind('', 'l', vimOps.operations.halfRight)
windowModal:bind('', 'j', vimOps.operations.halfBottom)
windowModal:bind('', 'k', vimOps.operations.halfTop)

windowModal:bind('', 'y', vimOps.operations.quarterLT)
windowModal:bind('', 'u', vimOps.operations.quarterLB)
windowModal:bind('', 'i', vimOps.operations.quarterRT)
windowModal:bind('', 'o', vimOps.operations.quarterRB)

-- Left/Right 2/3 bindings (using uppercase H / L)
windowModal:bind('', 'H', vimOps.operations.twoThirdLeft)
windowModal:bind('', 'L', vimOps.operations.twoThirdRight)

windowModal:bind('', 'f', vimOps.operations.maximize)
windowModal:bind('', 'c', vimOps.operations.close)

windowModal:bind('', 'tab', showHelp)
windowModal:bind('', 'q', function() windowModal:exit() end)
windowModal:bind('', 'escape', function() windowModal:exit() end)

-- Create command mode (reserved, not implemented yet)
local commandModal = hs.hotkey.modal.new({'alt'}, 'v')

function commandModal:entered()
  hs.alert.show('Command Mode (Not Implemented)', 1)
  -- Exit immediately since not implemented
  hs.timer.doAfter(1, function()
    commandModal:exit()
  end)
end

function commandModal:exited()
  hs.alert.show('Exit Command Mode', 1)
end

-- Lifecycle functions
local function init()
  log.info('Initializing window manager')
  return true
end

local function start()
  log.info('Starting window manager')
  return true
end

local function stop()
  log.info('Stopping window manager')
end

local function cleanup()
  log.info('Cleaning up window manager')
  -- Clean up timers
  if helpTimer then
    helpTimer:stop()
    helpTimer = nil
  end
end

-- Export module
return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup,
  windowModal = windowModal,
  commandModal = commandModal
}
