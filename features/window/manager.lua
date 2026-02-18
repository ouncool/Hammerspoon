local Operations = require('features.window.operations')

local M = {}

local ctx = nil
local log = nil
local modal = nil
local ops = nil

local function ensureModal()
  if modal then
    return
  end

  modal = hs.hotkey.modal.new(nil, nil)

  function modal:entered()
    hs.alert.show('Window mode', 0.6)
  end

  function modal:exited()
  end

  modal:bind('', 'h', ops.halfLeft)
  modal:bind('', 'l', ops.halfRight)
  modal:bind('', 'j', ops.halfBottom)
  modal:bind('', 'k', ops.halfTop)

  modal:bind('', 'y', ops.quarterLT)
  modal:bind('', 'u', ops.quarterLB)
  modal:bind('', 'i', ops.quarterRT)
  modal:bind('', 'o', ops.quarterRB)

  modal:bind({'shift'}, 'h', ops.twoThirdLeft)
  modal:bind({'shift'}, 'l', ops.twoThirdRight)

  modal:bind('', 'f', ops.maximize)
  modal:bind('', 'c', ops.close)

  modal:bind('', 'tab', function()
    hs.alert.show(ops.helpMessage, 4)
  end)

  modal:bind('', 'q', function()
    modal:exit()
  end)

  modal:bind('', 'escape', function()
    modal:exit()
  end)
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('WindowManager')
  ops = Operations.new(ctx)
  ensureModal()
  return true
end

function M.start()
  local modeKey = ctx.config.hotkeys.windowMode
  local mods = ctx.config.hotkeys.hyperMods

  ctx.hotkeys.bind({
    id = 'window.mode.enter',
    group = 'window',
    mods = mods,
    key = modeKey.key,
    desc = 'Enter window mode',
    action = function()
      modal:enter()
    end,
  })

  log.info('Window manager started')
  return true
end

function M.stop()
  ctx.hotkeys.unbindGroup('window')
  if modal then
    modal:exit()
  end
  return true
end

function M.dispose()
  M.stop()

  modal = nil

  ops = nil
  ctx = nil
  log = nil
end

return M
