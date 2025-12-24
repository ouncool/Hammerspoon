-- **************************************************
-- Vim-style window operation logic
-- Provides various window layout adjustment functions
-- **************************************************

local config = nil
pcall(function() config = require('modules.utils.config') end)
local EventBus = require('modules.core.event-bus')
local Logger = require('modules.core.logger')

local log = Logger.new('WindowOps')

-- Cache for screen frames to improve performance
local screenCache = {}
local cacheTime = 0
local CACHE_DURATION = 1 -- seconds

-- Cache for focused window to reduce repeated validation
local focusedWindowCache = {
  window = nil,
  timestamp = 0,
  isValid = false
}
local WINDOW_CACHE_DURATION = 0.1 -- 100ms

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

-- Safely get current focused window with caching
local function safeFocusWindow()
  local now = hs.timer.absoluteTime()
  
  -- Check cache first
  if focusedWindowCache.window and 
     focusedWindowCache.isValid and
     (now - focusedWindowCache.timestamp) < WINDOW_CACHE_DURATION * 1000000000 then
    
    -- Verify window is still valid
    local win = focusedWindowCache.window
    if win:isVisible() and win:frame() then
      return win
    else
      -- Cache invalid, clear it
      focusedWindowCache.window = nil
      focusedWindowCache.isValid = false
    end
  end
  
  -- Cache miss or expired, get new window
  local win = hs.window.frontmostWindow()
  if not win then
    log.debug('No focused window')
    return nil
  end
  
  -- Validate window
  if not win:isVisible() or not win:frame() then
    log.debug('Window is not valid')
    return nil
  end
  
  -- Update cache
  focusedWindowCache.window = win
  focusedWindowCache.timestamp = now
  focusedWindowCache.isValid = true
  
  -- Emit window focused event
  EventBus.emit(EventBus.EVENTS.WINDOW_FOCUSED, {
    window = win,
    title = win:title(),
    app = win:application():name()
  })
  
  return win
end

-- Invalidate window cache (call after window operations)
local function invalidateWindowCache()
  focusedWindowCache.isValid = false
end

-- Set window frame with error handling and event emission
local function setFrame(win, rect)
  if not win then 
    log.error('No window provided to setFrame')
    return 
  end
  if not rect or type(rect) ~= 'table' then
    log.error('Invalid rect provided to setFrame', { rect = rect })
    return
  end
  
  local oldFrame = win:frame()
  local ok, err = pcall(function() win:setFrame(rect) end)
  
  if not ok then
    log.error('Failed to set window frame', { error = err })
    return
  end
  
  -- Invalidate cache after operation
  invalidateWindowCache()
  
  -- Emit window resized event
  EventBus.emit(EventBus.EVENTS.WINDOW_RESIZED, {
    window = win,
    oldFrame = oldFrame,
    newFrame = rect
  })
end

-- Window operation functions
local operations = {
  -- Half screen operations
  halfLeft = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h })
    log.debug('Window moved to left half')
  end,

  halfRight = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h })
    log.debug('Window moved to right half')
  end,

  halfTop = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2 })
    log.debug('Window moved to top half')
  end,

  halfBottom = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = getCachedScreenFrame(win)
    setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2 })
    log.debug('Window moved to bottom half')
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
    if win then 
      win:maximize()
      invalidateWindowCache()
      log.debug('Window maximized')
      EventBus.emit(EventBus.EVENTS.WINDOW_RESIZED, {
        window = win,
        action = 'maximize'
      })
    end
  end,

  close = function()
    local win = safeFocusWindow()
    if win then 
      win:close()
      invalidateWindowCache()
      log.debug('Window closed')
      EventBus.emit(EventBus.EVENTS.WINDOW_DESTROYED, {
        window = win
      })
    end
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