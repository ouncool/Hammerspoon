local Operations = require('features.window.operations')

local M = {}

local ctx = nil
local log = nil
local modal = nil
local ops = nil

-- HUD helper (uses hs.canvas) to show a nicer, localized panel
local hud = nil
local hudTimer = nil

local function hideHud()
  if hudTimer then hudTimer:stop() hudTimer = nil end
  if hud then hud:delete() hud = nil end
end

local function showHud(title, lines, secs)
  hideHud()
  local screen = hs.screen.mainScreen()
  if not screen then return end
  local f = screen:frame()
  local w = 560
  local lineHeight = 22
  local titleHeight = 34
  local padding = 20
  local h = titleHeight + padding + (#lines * lineHeight) + padding
  local x = f.x + math.floor((f.w - w) / 2)
  local y = f.y + math.floor(f.h * 0.12)

  hud = hs.canvas.new({x = x, y = y, w = w, h = h})
  -- shadow (slightly offset, larger, more rounded)
  hud[1] = {
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0, green = 0, blue = 0, alpha = 0.22},
    roundedRectRadii = {xRadius = 18, yRadius = 18},
    frame = {x = 6, y = 6, w = w - 12, h = h - 12},
  }
  -- main background
  hud[2] = {
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0.12, green = 0.12, blue = 0.12, alpha = 0.95},
    roundedRectRadii = {xRadius = 16, yRadius = 16},
  }
  -- title with icon
  hud[3] = {
    type = 'text',
    text = '🪟 ' .. title,
    textFont = 'Helvetica-Bold',
    textSize = 20,
    textColor = {white = 1, alpha = 1},
    frame = {x = padding, y = padding/2, w = w - padding*2, h = titleHeight},
    paragraphStyle = {alignment = 'left'},
  }

  for i, ln in ipairs(lines) do
    hud[#hud + 1] = {
      type = 'text',
      text = ln,
      textFont = 'Helvetica',
      textSize = 16,
      textColor = {white = 1, alpha = 0.95},
      frame = {x = padding, y = padding/2 + titleHeight + (i - 1) * lineHeight, w = w - padding*2, h = lineHeight},
      paragraphStyle = {alignment = 'left'},
    }
  end

  hud:show()
  hudTimer = hs.timer.doAfter(secs or 3, hideHud)
end

local function splitLines(s)
  if not s then return {} end
  local t = {}
  for line in s:gmatch('[^\n]+') do table.insert(t, line) end
  return t
end

local function ensureModal()
  if modal then
    return
  end

  modal = hs.hotkey.modal.new(nil, nil)

  function modal:entered()
    local lines = {
      '进入窗口管理模式 — 可使用下列快捷键调整窗口布局：',
    }
    local help = splitLines(ops.helpMessage)
    for i = 1, math.min(#help, 6) do table.insert(lines, help[i]) end
    showHud('窗口管理', lines, 2.5)
  end

  function modal:exited()
    showHud('已退出窗口模式', {'按 Tab 可查看窗口布局帮助'}, 1.6)
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
    local lines = splitLines(ops.helpMessage)
    showHud('窗口管理帮助', lines, 6)
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
