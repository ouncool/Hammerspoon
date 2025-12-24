-- **************************************************
-- Vim-style window operation logic
-- Provides various window layout adjustment functions
-- **************************************************

local config = nil
pcall(function() config = require('modules.utils.config') end)

-- Cache for screen frames to improve performance
local screenCache = {}
local cacheTime = 0
local CACHE_DURATION = 1 -- seconds

local function getCachedScreenFrame(win)
  local now = hs.timer.absoluteTime()
  if now - cacheTime > CACHE_DURATION * 1000000000 then -- convert to nanoseconds
    screenCache = {}
    cacheTime = now
  end
  
  local screen = win:screen()
  local screenId = screen:id()
  if not screenCache[screenId] then
    screenCache[screenId] = screen:frame()
  end
  return screenCache[screenId]
end

-- Safely get current focused window
local function safeFocusWindow()
  local win = hs.window.frontmostWindow()
  if not win then
    hs.alert.show('No focused window')
    return nil
  end
  -- Additional check: ensure window is valid
  if not win:isVisible() or not win:frame() then
    hs.alert.show('Window is not valid')
    return nil
  end
  return win
end

-- Set window frame with error handling
local function setFrame(win, rect)
  if not win then 
    print('Error: No window provided to setFrame')
    return 
  end
  if not rect or type(rect) ~= 'table' then
    print('Error: Invalid rect provided to setFrame')
    return
  end
  pcall(function() win:setFrame(rect) end)
end

-- Window operation functions
local operations = {
  -- Half screen operations
  halfLeft = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h })
  end,

  halfRight = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h })
  end,

  halfTop = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2 })
  end,

  halfBottom = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2 })
  end,

  -- Quarter screen operations
  quarterLT = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterLB = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterRT = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterRB = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
  end,

  -- 2/3 screen operations
  twoThirdLeft = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    local ratio = (config and config.window and config.window.twoThirdRatio) or (2/3)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w * ratio, h = screen.h })
  end,

  twoThirdRight = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    local ratio = (config and config.window and config.window.twoThirdRatio) or (2/3)
    setFrame(win, { x = screen.x + screen.w * (1 - ratio), y = screen.y, w = screen.w * ratio, h = screen.h })
  end,

  -- Other operations
  maximize = function()
    local win = safeFocusWindow()
    if win then win:maximize() end
  end,

  close = function()
    local win = safeFocusWindow()
    if win then win:close() end
  end
}

-- Help message
local helpMessage = [[
Window Management (Press q or Esc to exit)

h: Left half    l: Right half
j: Bottom half  k: Top half
y: Top-left quarter  u: Bottom-left quarter
i: Top-right quarter o: Bottom-right quarter
H: Left two-thirds   L: Right two-thirds
f: Maximize     c: Close window
tab: Show help
]]

-- Return operations module
return {
  operations = operations,
  helpMessage = helpMessage,
  safeFocusWindow = safeFocusWindow
}